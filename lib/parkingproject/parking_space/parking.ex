defmodule ParkingProject.ParkingSpace.Parking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parkings" do
    field :category, :string
    field :latitude, :float
    field :longitude, :float
    field :places, :integer
    field :spot, :string

    timestamps()
  end

  @doc false
  def changeset(parking, attrs) do
    parking
    |> cast(attrs, [:spot, :category, :places, :latitude, :longitude])
    |> validate_required([:spot, :category, :places, :latitude, :longitude])
  end
end
