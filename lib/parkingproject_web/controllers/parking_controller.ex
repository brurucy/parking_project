defmodule ParkingProjectWeb.ParkingController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
  alias Ecto.{Changeset, Multi}
  alias ParkingProjectWeb.Geolocation
  alias ParkingProjectWeb.BetterGeolocation

  def index(conn, _params) do

    render conn, "index.html", data: %{distance: nil, spots: %{}, changeset: nil}
  end

  def display(conn, spots) do

    render conn, "display.html", spots: spots

  end

  def search(conn, params) do

    query = from p in Parking, select: p

    all_spots = Repo.all(query)
    destination = params["destination"]

    name_to_spot = all_spots |> Enum.map(fn parking -> {String.to_atom(parking.spot), parking} end)

    spots_ids = all_spots |> Enum.map(fn spot -> spot.id end)

    spot_names = name_to_spot |> Enum.map(fn {k, v} -> k end)

    case BetterGeolocation.get_coords(destination) do
      {:ok, origin_coords} ->
        spot_distances = spot_names
                         |> Enum.map(fn spot -> Atom.to_string(spot) end)
                         |> Enum.map(fn spot -> BetterGeolocation.get_distance_with_origin_coords(origin_coords, spot) end)
                         |> Enum.map(fn {k, v} -> v end)
                         |> Enum.zip(spots_ids)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :id, v) end)
                         |> Enum.zip(spot_names |> Enum.map(fn spot_name -> Atom.to_string(spot_name) end))
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :spot, v) end)
                         |> Enum.sort_by(fn k -> k.distance end)
                         |> Enum.map(fn k -> Map.update!(k, :distance, fn dist -> round(dist) end) end)
                         |> Enum.map(fn k -> Map.update!(k, :duration, fn dur -> round(dur) end) end)
                         |> Enum.map(fn k -> Map.put_new(k, :destination, destination) end)

        render conn, "index.html", data: %{
          changeset: Booking.changeset(%Booking{}, %{}),
          spots: spot_distances
        }

      {:error, _} ->
        conn
        |> put_flash(:error, "Destination is invalid")
        |> redirect(to: Routes.parking_path(conn, :index))

    end

  end

  def add_with_availability_check(parkings, parking, destination) do
    ## parkings is a list
    allocated_spots = number_of_allocated_spots(parking.id)
    case allocated_spots < parking.places do
      true -> List.insert_at(parkings, add_distance(parking, destination), 0)
      false -> parkings
    end
  end

  def number_of_allocated_spots(parking_id) do
    query = from a in Allocation,
                 where: a.parking_id == ^parking_id,
                 group_by: a.parking_id,
                 select: count(a)

    case query do
      true -> Repo.all(query)
      false -> 0
    end
  end

  def add_distance(parking, destination) do
    # parking is a map
    Map.put(parking, "distance", Geolocation.distance(destination, parking.spot))
  end
end  