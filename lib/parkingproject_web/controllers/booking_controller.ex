defmodule ParkingProjectWeb.BookingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.BookingSpace.{Booking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.Geolocation


  def index(conn, _params) do
    user = ParkingProject.Authentication.load_current_user(conn)
    bookings = Repo.all(from b in Booking, where: b.user_id == ^user.id)
    render conn, "index.html", bookings: bookings
  end

  def new(conn, _params) do
    changeset = BOoking.changeset(%Booking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"parking" => parking_params}) do
    user = ParkingProject.Authentication.load_current_user(conn)

    parking_struct = Ecto.build_assoc(user, :parking, Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end))
    changeset = Booking.changeset(parking_struct, %{})
                |> Changeset.put_change(:status, "taken")

    case Repo.insert(changeset) do
      {:ok, _} ->

        foundParkingArea = "Narva maantee 18, 51009, Tartu"
        [dis, dur] = Geolocation.distance(booking_params.destination, foundParkingArea)

        conn
        |> put_flash(:info, "BOoking confirmed, distance: #{dis}, duration: #{dur}")
        |> redirect(to: Routes.booking_path(conn, :index))

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
