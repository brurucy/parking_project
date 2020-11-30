defmodule ParkingProjectWeb.Geolocation do

  def find_location(address) do
    uri = "http://dev.virtualearth.net/REST/v1/Locations?countryRegion=EE&adminDistrict=Tartu&addressLine=#{URI.encode(address)}?maxResults=1&key=#{"AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"}"
    case HTTPoison.get uri do
      {:ok, response} ->
        matches = Regex.named_captures(~r/coordinates\D+(?<lat>-?\d+.\d+)\D+(?<long>-?\d+.\d+)/, response.body)
        [{v1, _}, {v2, _}] = [matches["lat"] |> Float.parse, matches["long"] |> Float.parse]
        [v1, v2]
      {:error, problemo} ->
        IO.inspect problemo, label: "problemo =("
        [problemo, problemo]
    end
  end

  def distance(origin, destination) do
    [o1, o2] = find_location(origin)
    [d1, d2] = find_location(destination)
    uri = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix?origins=#{o1},#{o2}&destinations=#{d1},#{d2}&travelMode=driving&timeUnit=seconds&distanceUnit=km&key=#{"AgALHCclAx-Vi1A0plbxmW0mxCpUO78S_PXWiZUILKn8BUv_AWSikExy49tFb0RC"}"
    response = HTTPoison.get! uri

    case HTTPoison.get uri do
      {:ok, response} ->
        matches = Regex.named_captures(~r/travelD\D+(?<dist>\d+.\d+)\D+(?<dur>\d+.\d+)/, response.body)

        case matches do
          nil ->
            {:error, "Destination is invalid"}
          _ ->
            [{v1, _}, {v2, _}] = [matches["dist"] |> Float.parse, matches["dur"] |> Float.parse]
            [v1, v2]
        end
      {:error, problemo} ->
        [problemo, problemo]
    end

 end

end
