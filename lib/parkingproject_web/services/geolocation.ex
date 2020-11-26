defmodule ParkingProjectWeb.Geolocation do

  def find_location(address) do
    IO.inspect URI.encode(address), label: "checking the encoded address"
    #uri = "http://dev.virtualearth.net/REST/v1/Locations/?q=1#{URI.encode(address)}%&key=#{"AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"}"
    uri = "http://dev.virtualearth.net/REST/v1/Locations?countryRegion=EE&adminDistrict=Tartu&addressLine=#{URI.encode(address)}?maxResults=1&key=#{"AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"}"
    response = HTTPoison.get! uri
    matches = Regex.named_captures(~r/coordinates\D+(?<lat>-?\d+.\d+)\D+(?<long>-?\d+.\d+)/, response.body)
    [{v1, _}, {v2, _}] = [matches["lat"] |> Float.parse, matches["long"] |> Float.parse]
    [v1, v2]
  end

  def distance(origin, destination) do
    [o1, o2] = find_location(origin)
    IO.inspect [o1, o2], label: "coords_origin"
    [d1, d2] = find_location(destination)
    IO.inspect [d1, d2], label: "coords_dest"
    uri = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins=#{o1},#{o2}&destinations=#{d1},#{d2}&travelMode=driving&timeUnit=seconds&distanceUnit=km&key=#{"AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"}"
    response = HTTPoison.get! uri

    IO.inspect response, label: "Response"

    matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/, response.body)
    [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
    [v1, v2]
 end

  #defp get_key(), do: "AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"
end
