defmodule ParkingProjectWeb.parkingController do
  use ParkingProjectWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias ParkingProject.Repo
  alias ParkingProject.Sales.{Taxi, parking, Allocation}
  alias Ecto.{Changeset, Multi}

  def index(conn, _params) do
    user = ParkingProject.Authentication.load_current_user(conn)
    parkings = Repo.all(from b in parking, where: b.user_id == ^user.id)
    render conn, "index.html", parkings: parkings
  end

  def new(conn, _params) do
    changeset = parking.changeset(%parking{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"parking" => parking_params}) do
    user = ParkingProject.Authentication.load_current_user(conn)

    parking_struct = Enum.map(parking_params, fn({key, value}) -> {String.to_atom(key), value} end)
                     |> Enum.into(%{})

    IO.inspect parking_struct

    changeset = %parking{}
                |> parking.changeset(parking_struct)
                |> Changeset.put_change(:user, user)
                |> Changeset.put_change(:status, "taken")

    case Repo.insert(changeset) do
      {:ok, _} -> ?
      nil ->
    end

    end
  end

end