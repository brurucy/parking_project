defmodule ParkingProjectWeb.BookingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.Geolocation


  def index(conn, _params) do
    IO.puts "HMMMMM2"
    user = ParkingProject.Authentication.load_current_user(conn)
    bookings = Repo.all(from b in Booking, where: b.user_id == ^user.id)
    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    IO.puts "HMMMMM1"
    changeset = Booking.changeset(%Booking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"booking" => booking_params}) do
    IO.puts "HMMMMM3"
    user = ParkingProject.Authentication.load_current_user(conn)

    booking_struct = Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end)
                     |> Enum.into(%{})

    IO.inspect booking_struct

    changeset = %Booking{}
                |> Booking.changeset(booking_struct)
                |> Changeset.put_change(:user, user)
                |> Changeset.put_change(:status, "taken")

    IO.puts "test1"
    case Repo.insert(changeset) do
      {:ok, _} ->
        IO.puts "test2"
        ## get all parking spots
        query = from p in Parking, select: p
        all_spots = Repo.all(query)
        spot_to_distance = %{}
        name_to_spot = %{}

        all_spots |> Enum.each(fn(s) -> Map.put(name_to_spot, s.spot, s) end)
        ## iterate over them and get their distance from there to booking_params.destination
        IO.inspect all_spots, label: "all spots"
        IO.inspect booking_params, label: "booking params"
        all_spots 
          |> Enum.each(fn(s) -> Map.put(spot_to_distance, s.spot, Geolocation.distance(booking_params["destination"], s.spot)) end)
                  
                          ## get the closest one
        closest_parking_place = all_spots
        |> Enum.min_by(fn {_k, v} -> length(v) end)
        |> elem(0)

        IO.inspect closest_parking_place, label: "closest parking place"
        ## I do not know what amir meant by duration?
        # [dist, duration] = Geolocation.distance(booking_params.destination, foundParkingArea)
        ## !! We also need to check IF the count of how many bookings with the given parking spot does not except the number of spots
        ## do a query on the db
        query = from a in Allocation, 
        join: p in Parking, on: a.parking == p,
        where: p.spot == ^closest_parking_place.spot, select: {count(a), p.id}

        closest_parking_space_occupied_spots = elem(Repo.one(query), 0)
        parking_id = elem(Repo.one(query), 1)
        IO.inspect closest_parking_space_occupied_spots, label: "IDK"
        case closest_parking_space_occupied_spots < closest_parking_place.spots do
          true ->
            distance = spot_to_distance[closest_parking_place]
            Multi.new
            |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "taken"}) |> Changeset.put_change(:booking_id, booking_struct.id) |> Changeset.put_change(:parking_id, parking_id))
            |> Multi.update(:booking, Booking.changeset(booking_struct, %{}) |> Changeset.put_change(:status, "allocated"))
            |> Repo.transaction

            conn
            |> put_flash(:info, "Booking confirmed, distance: #{distance}")
            |> redirect(to: Routes.booking_path(conn, :index))
          _ ->
        end

      _ ->

        conn
        |> flashTheChangeset(changeset)
        |> render("new.html", changeset: changeset)
      end

  end

  defp flashTheChangeset(conn, changeset) do
    IO.puts "HMMMMM4"
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

    error_msg =
      errors
      |> Enum.map(fn {_key, errors} -> "#{Enum.join(errors, ", ")}" end)
      |> Enum.join("\n")

    conn
    |> put_flash(:error, error_msg)
  end

end
