defmodule ParkingProjectWeb.BookingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.{Geolocation, BetterGeolocation}

  #To test in iex
  #ParkingProject.Repo.all(Ecto.Query.from a in ParkingProject.ParkingSpace.Allocation, join: p in ParkingProject.ParkingSpace.Parking, on: a.parking_id == p.id, join: b in ParkingProject.ParkingSpace.Booking, on: a.booking_id == b.id, where: a.booking_id == 13, select: {p.spot, b.destination, b.duration})

  def index(conn, _params) do
    user = ParkingProject.Authentication.load_current_user(conn)
    booking_query = from b in Booking,
                    where: b.user_id == ^user.id
    bookings = Repo.all(booking_query)

    IO.inspect(bookings, label: "testimine")

    query_pspot = from a in Allocation,
                  join: p in Parking,
                  on: a.parking_id == p.id,
                  join: b in Booking,
                  on: a.booking_id == b.id,
                  where: a.booking_id in ^(bookings |> Enum.map(fn x -> x.id end)) ,
                  select: {p.spot, b.destination, b.duration, p.category, b.distance}
    parking_sl = Repo.all(query_pspot)

    render conn, "index.html", bookings: parking_sl
  end

  def new(conn, _params) do
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

  def create(conn, %{"search" => search_params}) do
    IO.inspect search_params, label: "search params one"
    user = ParkingProject.Authentication.load_current_user(conn)

    parking_id = String.to_integer(search_params["id"])
    spot = search_params["spot"]

    search_params = search_params
                    |> Map.delete(:spot)
                    |> Map.delete(:id)

    IO.inspect search_params, label: "search params two"

    booking_changeset = Booking.changeset(%Booking{}, search_params)
                        |> Changeset.put_change(:user, user)
                        |> Changeset.put_change(:status, "taken")
    case Repo.insert(booking_changeset) do
      {:ok, booking_insertion} ->
        Multi.new
        |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "active"}) |> Changeset.put_change(:booking_id, booking_insertion.id) |> Changeset.put_change(:parking_id, parking_id))
        |> Multi.update(:booking, Booking.changeset(booking_insertion, %{}) |> Changeset.put_change(:status, "open"))
        |> Repo.transaction
        conn
        |> put_flash(:info, "Parking confirmed #{spot}")
        |> redirect(to: Routes.booking_path(conn, :index))
      {:error, changeset} ->
        IO.inspect changeset, label: "blerp"
        conn
        |> flashTheChangeset(changeset, "Duration")
        |> render("new.html", changeset: changeset)
    end
  end

  defp flashTheChangeset(conn, changeset, noun) do
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
    |> put_flash(:error, noun <> " " <> error_msg)
  end

end
