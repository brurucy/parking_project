defmodule ParkingProject.ParkingSpace.Zone do
  use Ecto.Schema
  import Ecto.Changeset

  schema "zones" do
    field :name, :string
    field :pricePerHour, :integer
    field :pricePer5mins, :integer

    timestamps()
  end

  @doc false
  def changeset(zone, attrs \\ %{}) do
    zone
    |> cast(attrs, [:name, :pricePerHour, :pricePer5mins])
    |> validate_required([:name, :pricePerHour, :pricePer5mins])
  end
end
