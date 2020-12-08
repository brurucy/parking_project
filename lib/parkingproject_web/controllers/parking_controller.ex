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

    case params["destination"] do
      "" ->
        conn
        |> put_flash(:error, "Destination cannot be nil")
        |> redirect(to: Routes.parking_path(conn, :index))
      _ ->
    end

    case params["radius"] do
      "0" ->
        conn
        |> put_flash(:error, "Radius cannot be 0 meters")
        |> redirect(to: Routes.parking_path(conn, :index))
      _ ->
    end

    case Ecto.Type.cast(:utc_datetime, params["startdate"]) do
      {:error, _} -> 
        conn
        |> put_flash(:error, "Please provide a start date")
        |> redirect(to: Routes.parking_path(conn, :index))

      {:ok, nil} ->
        conn
        |> put_flash(:error, "Please provide a start date")
        |> redirect(to: Routes.parking_path(conn, :index))

      _ ->
    end

    case Enum.member?(Map.values(params["startdate"]), "") do
      true ->
        conn
        |> put_flash(:error, "no field in start date can be empty")
        |> redirect(to: Routes.parking_path(conn, :index))
      _ ->
    end

    enddate_values = Map.values(params["enddate"])

    {:ok, startdate} = Ecto.Type.cast(:utc_datetime, params["startdate"])

    {:ok, now} = DateTime.now("Etc/UTC") ## THIS IS NOT OUR TIMEZONE - PROBLEM?
    IO.inspect now, label: "now"

    # Cannot book 2 years in advance =|

    case DateTime.diff(startdate, now) < 0 do
      true ->
        conn
        |> put_flash(:error, "Start date cannot be in the past")
        |> redirect(to: Routes.parking_path(conn, :index))
      false ->
    end

    query = from p in Parking, select: p

    all_spots = Repo.all(query)
    destination = params["destination"]

    name_to_spot = all_spots |> Enum.map(fn parking -> {String.to_atom(parking.spot), parking} end)

    spots_ids = all_spots |> Enum.map(fn spot -> spot.id end)

    cat_query = Repo.all(from p in ParkingProject.ParkingSpace.Parking,
                         join: pf in ParkingProject.ParkingSpace.ParkingFee,
                         on: [id: p.parking_fee_id],
                         select: [pf.category, pf.pph, pf.ppfm])

    spot_categories = Enum.map(cat_query, fn l -> Enum.at(l, 0) end)

    spot_pph = Enum.map(cat_query, fn l -> Enum.at(l, 1) end)

    spot_ppfm = Enum.map(cat_query, fn l -> Enum.at(l, 2) end)

    spot_free_spots = all_spots |> Enum.map(fn spot -> spot.places end)

    spot_taken_spots = spots_ids |> Enum.map(fn spot -> number_of_allocated_spots(spot) end)

    spot_names = name_to_spot |> Enum.map(fn {k, v} -> k end)

    spot_distances = nil

    case BetterGeolocation.get_coords(destination) do
      {:ok, origin_coords} ->

        # Whole grain
        spot_distances = spot_names
                         |> Enum.map(fn spot -> Atom.to_string(spot) end)
                         |> Enum.map(fn spot -> BetterGeolocation.get_distance_with_origin_coords(origin_coords, spot) end)

        # Basil + white sauce
        spot_distances = spot_distances
                         |> Enum.map(fn {k, v} -> v end)
                         |> Enum.zip(spots_ids)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :id, v) end)
                         |> Enum.zip(spot_names |> Enum.map(fn spot_name -> Atom.to_string(spot_name) end))
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :spot, v) end)
                         |> Enum.zip(spot_taken_spots)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :taken, v) end)
                         |> Enum.zip(spot_free_spots)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :free, v) end)
                         |> Enum.zip(spot_categories)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :category, v) end)
                         |> Enum.zip(spot_pph)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :pph, v) end)
                         |> Enum.zip(spot_ppfm)
                         |> Enum.map(fn {k, v} -> Map.put_new(k, :ppfm, v) end)

        spot_distances = spot_distances
                         |> Enum.sort_by(fn k -> k.distance end)
                         |> Enum.map(fn k -> Map.update!(k, :distance, fn dist -> round(dist) end) end)
                         |> Enum.map(fn k -> Map.update!(k, :duration, fn dur -> round(dur) end) end)
                         |> Enum.map(fn k -> Map.put_new(k, :destination, destination) end)
                         |> Enum.map(fn k -> Map.put_new(k, :startdate, params["startdate"]) end)

        case Enum.member?(enddate_values, "") do
          true ->
            case length(MapSet.to_list(MapSet.new(enddate_values))) == 1 do
              true ->
                #IO.inspect spot_distances, label: "spotty"

                spot_distances = spot_distances
                                 |> Enum.filter(fn k -> k.distance <= String.to_integer(params["radius"]) end)
                                 |> Enum.map(fn k -> Map.put_new(k, :enddate, nil) end)
                                 |> Enum.map(fn k -> Map.put_new(k, :fee, nil) end)

                render conn, "index.html", data: %{
                  changeset: Booking.changeset(%Booking{}, %{}),
                  spots: spot_distances
                }
              false ->
                conn
                |> put_flash(:error , "if you wanna supply an end date at least fill all values")
                |> redirect(to: Routes.parking_path(conn, :index))
            end
          _ ->

            spot_distances = spot_distances
                             |> Enum.sort_by(fn k -> k.distance end)
                             |> Enum.map(fn k -> Map.update!(k, :distance, fn dist -> round(dist) end) end)
                             |> Enum.map(fn k -> Map.update!(k, :duration, fn dur -> round(dur) end) end)
                             |> Enum.map(fn k -> Map.put_new(k, :destination, destination) end)
                             |> Enum.map(fn k -> Map.put_new(k, :startdate, params["startdate"]) end)
                             |> Enum.map(fn k -> Map.put_new(k, :enddate, params["enddate"]) end)


            {:ok, enddate} = Ecto.Type.cast(:utc_datetime, params["enddate"])

            parking_time = DateTime.diff(enddate, startdate) / 60 ## in minutes

            case parking_time < 1 do
              true ->
                conn
                |> put_flash(:error, "End date must be later than start date")
                |> redirect(to: Routes.parking_path(conn, :index))
              false ->
            end

            user = ParkingProject.Authentication.load_current_user(conn)

            case user.is_hourly do
              true ->
                spot_distances = spot_distances
                                 |> Enum.map(fn k -> Map.put_new(k, :fee, (k.pph * ceil(parking_time / 60)) * 100) end)
                                 |> Enum.filter(fn k -> k.distance <= String.to_integer(params["radius"]) end)

                render conn, "index.html", data: %{
                  changeset: Booking.changeset(%Booking{}, %{}),
                  spots: spot_distances
                }
              _ ->
                spot_distances = spot_distances
                                 |> Enum.map(fn k -> Map.put_new(k, :fee, ceil(k.ppfm * parking_time / 5)) end)
                                 |> Enum.filter(fn k -> k.distance <= String.to_integer(params["radius"]) end)

                render conn, "index.html", data: %{
                  changeset: Booking.changeset(%Booking{}, %{}),
                  spots: spot_distances
                }
            end

        end

      {:error, _} ->
        conn
        |> put_flash(:error, "Destination is invalid")
        |> redirect(to: Routes.parking_path(conn, :index))

    end

  end

  def add_with_availability_check(parkings, parking, destination, parking_time) do

    allocated_spots = number_of_allocated_spots(parking.id)
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

    case Repo.all(query) do
      [] -> 0
      [not_nil] -> not_nil
    end

  end

  def add_distance(parking, destination, parking_time) do
    {:ok, res} = BetterGeolocation.get_distance(destination, parking.spot)
    parking 
    |> Map.put(:distance, res.distance)
    |> Map.put(:time, res.duration)
    |> Map.put(:parking_time, parking_time)
  end
end  