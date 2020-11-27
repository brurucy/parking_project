defmodule ParkingProjectWeb.BookingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.Geolocation

  #To test in iex
  #ParkingProject.Repo.all(Ecto.Query.from a in ParkingProject.ParkingSpace.Allocation, join: p in ParkingProject.ParkingSpace.Parking, on: a.parking_id == p.id, join: b in ParkingProject.ParkingSpace.Booking, on: a.booking_id == b.id, where: a.booking_id == 13, select: {p.spot, b.destination, b.duration})

  def index(conn, _params) do
    IO.puts "HMMMMM2"
    user = ParkingProject.Authentication.load_current_user(conn)
    booking_query = from b in Booking,
                    where: b.user_id == ^user.id
    bookings = Repo.all(booking_query)
    query_pspot = from a in Allocation,
                  join: p in Parking,
                  on: a.parking_id == p.id,
                  join: b in Booking,
                  on: a.booking_id == b.id,
                  where: a.booking_id in ^(bookings |> Enum.map(fn x -> x.id end)) ,
                  select: {p.spot, b.destination, b.duration}
    parking_sl = Repo.all(query_pspot)

    IO.inspect bookings, label: "yeeeet"
    IO.inspect parking_sl, label: "gucci gang, ooh, yuh, lil pump"

    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    IO.puts "HMMMMM1"
    changeset = Booking.changeset(%Booking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def case_func(query) do
    case Repo.one(query) != nil do
      true ->
        elem(Repo.one(query), 0)
      false ->
        0
      end
  end

  def create(conn, %{"booking" => booking_params}) do
    IO.puts "HMMMMM3"
    user = ParkingProject.Authentication.load_current_user(conn)

    booking_struct = Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end)
                     |> Enum.into(%{})

    
    booking_struct = Map.delete(booking_struct, :user)
    IO.inspect booking_struct
    

    booking_changeset = %Booking{}
                |> Booking.changeset(booking_struct)
                |> Changeset.put_change(:user, user)
                |> Changeset.put_change(:status, "taken")

    IO.puts "test1"
    case Repo.insert(booking_changeset) do
      {:ok, booking_insertion} ->
        IO.puts "test2"
        ## get all parking spots
        query = from p in Parking, select: p
        all_spots = Repo.all(query)
        spot_to_distance = %{}
        name_to_spot = %{}

        name_to_spot = Enum.reduce all_spots, %{}, fn x, acc ->
          Map.put(acc, x.spot, x) 
        end

        IO.inspect name_to_spot, label: "name_to_spot"
        ## iterate over them and get their distance from there to booking_params.destination
        IO.inspect all_spots, label: "all spots"
        IO.inspect booking_params, label: "booking params"
        spot_to_distance = Enum.reduce all_spots, %{}, fn x, acc ->
          Map.put(acc, x.spot, List.first(Geolocation.distance(booking_params["destination"], x.spot)))
        end
                            ## get the closest one
        IO.inspect spot_to_distance, label: "spot to distance"
        closest_parking_place_name = spot_to_distance
        |> Enum.min_by(fn {_k, v} -> v end)
        |> elem(0)

        IO.inspect closest_parking_place_name, label: "closest parking place"
        closest_parking_place = name_to_spot[closest_parking_place_name]
        ## I do not know what amir meant by duration?
        # [dist, duration] = Geolocation.distance(booking_params.destination, foundParkingArea)
        ## !! We also need to check IF the count of how many bookings with the given parking spot does not except the number of spots
        ## do a query on the db
        query = from a in Allocation, 
          join: p in Parking,
          on: a.parking_id == p.id,
          where: p.spot == ^closest_parking_place.spot,
          group_by: p.id,
          select: {count(a), p.id}

        closest_parking_space_occupied_spots = case_func(query)

        IO.inspect Repo.one(query), label: "query"
        IO.inspect closest_parking_space_occupied_spots, label: "IDK"
        IO.inspect closest_parking_place.id, label: "parking id"
        IO.inspect booking_insertion.id, label: "booking id"
        case closest_parking_space_occupied_spots < closest_parking_place.places do
          true ->
            distance = spot_to_distance[closest_parking_place.spot]

            Multi.new
            |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "active"}) |> Changeset.put_change(:booking_id, booking_insertion.id) |> Changeset.put_change(:parking_id, closest_parking_place.id))
            |> Multi.update(:booking, Booking.changeset(booking_insertion, %{}) |> Changeset.put_change(:status, "open"))
            |> Repo.transaction

            conn
            #|> put_flash(:info, "Booking confirmed, distance: #{distance}")
            |> put_flash(:info, "Parking confirmed")
            |> redirect(to: Routes.booking_path(conn, :index))
          _ ->
        end

      {:error, changeset} ->
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
