defmodule ParkingProjectWeb.BetterGeolocation do

  def aaaaa(aaa) do
    try do
      List.first(aaa)
    rescue
      FunctionClauseError -> nil
    end
  end

  def get_coords(address) do
    address = URI.encode("#{address}, Tartu linn, Tartu linn")
    uri = "https://us1.locationiq.com/v1/search.php?key=pk.21344d765de5552d2e33794fe76e8f26&q=#{address}&viewbox=026.667075%2C%20026.798042%2C058.410940%2C058.339020&limit=1&countrycodes=EE&format=json"
    with {:ok, responses} <- HTTPoison.get(uri),
         {:ok, responses_bodies} <- Poison.decode(responses.body) do
      case aaaaa(responses_bodies) do
        nil ->
          {:error, nil}
        _ ->
          response_dictionary = Enum.at(responses_bodies, 0)
          response_atomized = response_dictionary |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
          {:ok, %{lon: response_atomized[:lon], lat: response_atomized[:lat]}}
      end
    else
      nil -> "shit"
      {:error, message} -> {:error, message}
    end
  end

  defp sleep_time(sleep_duration_milliseconds) do
    sleep_duration_milliseconds
  end

  def get_distance(origin, dest) do
    with {:ok, origin_coords} <- get_coords(origin),
         :timer.sleep(sleep_time(750)),
         {:ok, dest_coords} <- get_coords(dest),
         :timer.sleep(sleep_time(750)),
         {:ok, responses} <- HTTPoison.get("https://us1.locationiq.com/v1/directions/driving/#{origin_coords[:lon]},#{origin_coords[:lat]};#{dest_coords[:lon]},#{dest_coords[:lat]}?key=pk.21344d765de5552d2e33794fe76e8f26&overview=full"),
         :timer.sleep(sleep_time(750)),
         {:ok, response_bodies} <- Poison.decode(responses.body),
         response_routes <- response_bodies["routes"],
         first_route = List.first(response_routes),
         first_route_atomized <- first_route |> Map.new(fn {k, v} -> {String.to_atom(k), v} end) do
      {:ok, %{duration: first_route_atomized[:duration], distance: first_route_atomized[:distance]}}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  def get_distance_with_origin_coords(origin_coords, dest) do
    with {:ok, dest_coords} <- get_coords(dest),
         :timer.sleep(sleep_time(750)),
         {:ok, responses} <- HTTPoison.get("https://us1.locationiq.com/v1/directions/driving/#{origin_coords[:lon]},#{origin_coords[:lat]};#{dest_coords[:lon]},#{dest_coords[:lat]}?key=pk.21344d765de5552d2e33794fe76e8f26&overview=full"),
         :timer.sleep(sleep_time(750)),
         {:ok, response_bodies} <- Poison.decode(responses.body),
         response_routes <- response_bodies["routes"],
         first_route = List.first(response_routes),
         first_route_atomized <- first_route |> Map.new(fn {k, v} -> {String.to_atom(k), v} end) do
      {:ok, %{duration: first_route_atomized[:duration], distance: first_route_atomized[:distance]}}
    else
      {:error, message} ->
        {:error, message}
    end
  end

end