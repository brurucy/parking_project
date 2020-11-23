defmodule ParkingProjectWeb.BookingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.ParkingSpace.{Booking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.Geolocation


  def index(conn, _params) do
    user = ParkingProject.Authentication.load_current_user(conn)
    bookings = Repo.all(from b in Booking, where: b.user_id == ^user.id)
    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    changeset = Booking.changeset(%Booking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"booking" => booking_params}) do
    user = ParkingProject.Authentication.load_current_user(conn)

    booking_struct = Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end)
                     |> Enum.into(%{})

    IO.inspect booking_struct

    changeset = %Booking{}
                |> Booking.changeset(booking_struct)
                |> Changeset.put_change(:user, user)
                |> Changeset.put_change(:status, "taken")

    case Repo.insert(changeset) do
      {:ok, _} ->
        ## get all parking spots
        query = nil
        ## iterate over them and get their distance from there to booking_params.destination
        distances_parking_spots_to_destination = nil
        ## get the closest one
        closest_parking_place = nil
        ## I do not know what amir meant by duration?
        # [dist, duration] = Geolocation.distance(booking_params.destination, foundParkingArea)
        ## !! We also need to check IF the count of how many bookings with the given parking spot does not except the number of spots
        ## do a query on the db
        closest_parking_space_spots = nil
        case closest_parking_space_spots < closest_parking_place.spots do
          true ->
            Multi.new
            |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "taken"}) |> Changeset.put_change(:booking_id, struct.id) |> Changeset.put_change(:taxi_id, taxi.id))
            |> Multi.update(:booking, Booking.changeset(struct, %{}) |> Changeset.put_change(:status, "allocated"))
            |> Repo.transaction

            conn
            |> put_flash(:info, "BOoking confirmed, distance: #{dis}, duration: #{dur}")
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
