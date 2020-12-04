defmodule ParkingProjectWeb.ParkingFeeFunctions do

  import Ecto.Query, only: [from: 2]

  alias ParkingProject.ParkingSpace.Zone
  alias ParkingProject.Repo

  def getZoneFeeAmount(zone, isPerHour) do

    query_zones = from i in Zone,
                  where: i.name == ^zone,
                  select: i

    zone = Repo.one!(query_zones)
    if isPerHour, do: zone.pricePerHour, else: zone.pricePer5mins

  end

  # startDatetime, endDatetime : DateTime
  # zone : "A", "B"
  # isPerHour : Boolean
  def getEstimation(startDatetime, endDatetime, zone, isPerHour) do

    # 1h 27m = 5220s
    # DateTime.diff(DateTime.add(DateTime.utc_now(), 5220), DateTime.utc_now())

    diffInSeconds = DateTime.diff(endDatetime, startDatetime)
    diffInMinutes = diffInSeconds / 60
    duration = Float.ceil(if isPerHour, do: diffInMinutes/60, else: diffInMinutes/5)
    fee = getZoneFeeAmount(zone, isPerHour)
    duration * fee

  end

end
