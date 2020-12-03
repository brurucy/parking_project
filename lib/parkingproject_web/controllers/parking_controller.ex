defmodule ParkingProjectWeb.ParkingController do
    use ParkingProjectWeb, :controller
  
    import Ecto.Query, only: [from: 2]
  
    alias ParkingProject.Repo
    alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
    alias Ecto.{Changeset, Multi}
    alias ParkingProjectWeb.Geolocation

    def new(conn, _params) do
      changeset = Parking.changeset(%Parking{}, %{})
      render conn, "new.html", changeset: changeset
    end

    def create(conn, %{"parking" => booking_params}) do

      booking_struct = Enum.map(booking_params, fn({key, value}) -> {String.to_atom(key), value} end)
      |> Enum.into(%{})

      IO.inspect booking_struct, label: "Booking struct"
    
        query = from p in Parking,
                select: p
        parkings = Repo.all(query)

        available_parkings_with_distance = []

        available_parkings_with_distance = Enum.reduce parkings, [], fn parking, parkings ->
            add_with_availability_check(parkings, parking, booking_struct.destination)
        end
        IO.inspect available_parkings_with_distance, label: "ho ho ho"
        render conn, "index.html", parkings: available_parkings_with_distance
      end

      def add_with_availability_check(parkings, parking, destination) do
        ## parkings is a list
        IO.inspect parkings, label: "Parkings list"
        IO.inspect parking, label: "Just parking"
        allocated_spots = number_of_allocated_spots(parking.id)
        case allocated_spots < parking.places do
            true -> 
              IO.inspect [add_distance(parking, destination) | parkings], label: "what happened"
              [add_distance(parking, destination) | parkings]
            false -> parkings
        end
      end

      def number_of_allocated_spots(parking_id) do
        query = from a in Allocation,
            where: a.parking_id == ^parking_id and a.status != "free",
            group_by: a.parking_id,
            select: count(a)
        
          case Repo.one(query) != nil do
            true -> Repo.all(query)
            false -> 0
        end
      end

      def add_distance(parking, destination) do
        # parking is a map
        IO.inspect Map.put(parking, :distance, List.first(Geolocation.distance(destination, parking.spot))), label: "Add distance"
        Map.put(parking, :distance, List.first(Geolocation.distance(destination, parking.spot)))
      end
end  