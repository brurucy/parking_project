defmodule ParkingProjectWeb.ParkingController do
    use ParkingProjectWeb, :controller
  
    import Ecto.Query, only: [from: 2]
  
    alias ParkingProject.Repo
    alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}
    alias Ecto.{Changeset, Multi}
    alias ParkingProjectWeb.Geolocation

    def index(conn, %{"parking" => %{"destination": destination}}) do
      

        query = from p in Parking,
                select: p
        parkings = Repo.all(query)

        available_parkings_with_distance = %{}

        available_parkings_with_distance = Enum.reduce parkings, %{}, fn parking, parkings ->
            add_with_availability_check(parkings, parking, destination)
        end
    
        render conn, "index.html", parkings: available_parkings_with_distance
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