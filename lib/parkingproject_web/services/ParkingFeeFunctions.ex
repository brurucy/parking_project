defmodule ParkingProjectWeb.ParkingFeeFunctions do

  def getZoneFeeAmount(zone, isPerHour) do

    feeStructure = %ParkingProjectWeb.ParkingFee{}
    selectedZone = if zone == "A", do: feeStructure."ZoneA", else: feeStructure."ZoneB"
    if isPerHour, do: selectedZone."AmountPerHour", else: selectedZone."AmountPer5mins"

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
