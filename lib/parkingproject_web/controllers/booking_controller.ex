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

  def create(conn, search_params) do
    IO.inspect search_params, label: "search params"
    user = ParkingProject.Authentication.load_current_user(conn)
    booking_changeset = %Booking{}
                        |> Booking.changeset(search_params)
                        |> Changeset.put_change(:user, user)
                        |> Changeset.put_change(:status, "taken")
    case Repo.insert(booking_changeset) do
      {:ok, booking_insertion} ->
        Multi.new
        |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "active"}) |> Changeset.put_change(:booking_id, booking_insertion.id))
        |> Multi.update(:booking, Booking.changeset(booking_insertion, %{}) |> Changeset.put_change(:status, "open"))
        |> Repo.transaction
        conn
        |> put_flash(:info, "Parking confirmed #{search_params.spot}")
        |> redirect(to: Routes.booking_path(conn, :index))
      {:error, changeset} ->
        conn
        |> flashTheChangeset(changeset, "Duration")
        |> render("new.html", changeset: changeset)
    end
  end

  #def fast_sert(conn, search_params) do
#
  #  IO.inspect search_params, label: "search params"
#
  #  user = ParkingProject.Authentication.load_current_user(conn)
#
  #  booking_changeset = %Booking{}
  #                      |> Booking.changeset(search_params)
  #                      |> Changeset.put_change(:user, user)
  #                      |> Changeset.put_change(:status, "taken")
#
  #  case Repo.insert(booking_changeset) do
  #    {:ok, booking_insertion} ->
  #      Multi.new
  #      |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "active"}) |> Changeset.put_change(:booking_id, booking_insertion.id))
  #      |> Multi.update(:booking, Booking.changeset(booking_insertion, %{}) |> Changeset.put_change(:status, "open"))
  #      |> Repo.transaction
#
  #      conn
  #      |> put_flash(:info, "Parking confirmed #{search_params.spot}")
  #      |> redirect(to: Routes.booking_path(conn, :index))
#
  #    {:error, changeset} ->
  #      conn
  #      |> flashTheChangeset(changeset, "Duration")
  #      |> render("new.html", changeset: changeset)
  #  end
  #end


  #def create(conn, %{"booking" => booking_params}) do
#
  #  user = ParkingProject.Authentication.load_current_user(conn)
#
  #  booking_struct = Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end)
  #                   |> Enum.into(%{})
#
  #  booking_struct = Map.delete(booking_struct, :user)
#
  #  booking_changeset = %Booking{}
  #              |> Booking.changeset(booking_struct)
  #              |> Changeset.put_change(:user, user)
  #              |> Changeset.put_change(:status, "taken")
#
  #  ## get all parking spots
  #  query = from p in Parking, select: p
#
  #  # Getting all spots
  #  all_spots = Repo.all(query)
  #  destination = booking_params["destination"]
#
  #  name_to_spot = all_spots
  #                 |> Enum.map(fn parking -> {String.to_atom(parking.spot), parking} end)
#
  #  spot_names = name_to_spot
  #               |> Enum.map(fn {k, v} -> k end)
#
  #  case BetterGeolocation.get_coords(destination) do
  #    {:ok, origin_coords} ->
  #      spot_distances = spot_names
  #                       |> Enum.map(fn spot -> Atom.to_string(spot) end)
  #                       |> Enum.map(fn spot -> BetterGeolocation.get_distance_with_origin_coords(origin_coords, spot) end)
  #                       |> Enum.map(fn {k, v} -> v end)
#
  #      spot_to_distance = spot_names
  #                         |> Enum.zip(spot_distances)
  #                         |> Map.new()
#
  #      case Repo.insert(booking_changeset) do
  #        {:ok, booking_insertion} ->
#
  #          closest_parking_place = spot_to_distance
  #                                  |> Enum.sort_by(fn {k, v} -> v.distance end)
  #                                  |> List.first
  #                                  |> elem(0)
#
  #          closest_parking_place = name_to_spot[closest_parking_place]
#
  #          query = from a in Allocation,
  #                       join: p in Parking,
  #                       on: a.parking_id == p.id,
  #                       where: p.spot == ^closest_parking_place.spot,
  #                       group_by: p.id,
  #                       select: {count(a), p.id}
#
  #          ## if allocation query is nil,  closest_parking_space_occupied_spots is 0. Else it is the nr of occupied spots
  #          closest_parking_space_occupied_spots = case_func(query)
#
  #          case closest_parking_space_occupied_spots < closest_parking_place.places do
  #            true ->
  #              distance = spot_to_distance[String.to_existing_atom(closest_parking_place.spot)].distance
#
  #              Multi.new
  #              |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "active"}) |> Changeset.put_change(:booking_id, booking_insertion.id) |> Changeset.put_change(:parking_id, closest_parking_place.id))
  #              |> Multi.update(:booking, Booking.changeset(booking_insertion, %{}) |> Changeset.put_change(:status, "open") |> Changeset.put_change(:distance, distance))
  #              |> Repo.transaction
#
  #              conn
  #              |> put_flash(:info, "Parking confirmed #{closest_parking_place.spot}")
  #              |> redirect(to: Routes.booking_path(conn, :index))
  #            _ ->
  #          end
#
  #        {:error, changeset} ->
  #          conn
  #          |> flashTheChangeset(changeset, "Duration")
  #          |> render("new.html", changeset: changeset)
  #      end
#
  #    {:error, _} ->
  #      conn
  #      |> put_flash(:error, "Destination is invalid")
  #      |> redirect(to: Routes.booking_path(conn, :new))
  #  end
#
  #end

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
