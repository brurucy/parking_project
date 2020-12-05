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
    IO.inspect params, label: "search params"

    IO.inspect params["startdate"], label: "startdate"
    {:ok, startdate} = Ecto.Type.cast(:utc_datetime, params["startdate"])
    {:ok, enddate} = Ecto.Type.cast(:utc_datetime, params["enddate"])

    case startdate == nil or enddate == nil do
      true ->
        conn
        |> put_flash(:error, "Please provide both a start and an end time")
        |> redirect(to: Routes.parking_path(conn, :index))
      false ->
    end

    IO.inspect DateTime.diff(enddate, startdate), label: "Diff"

    parking_time = DateTime.diff(enddate, startdate) ## in minutes

    {:ok, now} = DateTime.now("Etc/UTC") ## THIS IS NOT OUR TIMEZONE - PROBLEM?
    IO.inspect now, label: "now"

    case DateTime.diff(startdate, now) < 0 do
      true ->
        
        conn
        |> put_flash(:error, "Start date cannot be in the past")
        |> redirect(to: Routes.parking_path(conn, :index))
      false ->
      end


    case parking_time < 1 do
      true ->   
        conn
        |> put_flash(:error, "Minimum duration is 1 min")
        |> redirect(to: Routes.parking_path(conn, :index))
      false ->
    end

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

  def add_with_availability_check(parkings, parking, destination, parking_time) do
    ## parkings is a list

    allocated_spots = number_of_allocated_spots(parking.id)
    #IO.inspect parkings, label: "parkings"
    #IO.inspect parking, label: "one parking"
    #IO.inspect allocated_spots, label: "allocated spots"
    case allocated_spots < parking.places do
      true -> [add_distance(parking, destination, parking_time) | parkings]
      false -> parkings
    end
  end

  def number_of_allocated_spots(parking_id) do
    query = from a in Allocation,
                 where: a.parking_id == ^parking_id,
                 group_by: a.parking_id,
                 select: count(a)

    case Repo.all(query) != nil do
      true -> length(Repo.all(query))
      false -> 0
    end
  end

  def add_distance(parking, destination, parking_time) do
    # parking is a map
    {:ok, res} = BetterGeolocation.get_distance(destination, parking.spot)
    parking 
    |> Map.put(:distance, res.distance)
    |> Map.put(:time, res.duration)
    |> Map.put(:parking_time, parking_time)
  end
end  