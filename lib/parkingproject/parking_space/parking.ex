defmodule ParkingProject.ParkingSpace.Parking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parkings" do
    field :latitude, :float
    field :longitude, :float
    field :places, :integer
    field :spot, :string
    belongs_to :parking_fee, ParkingProject.ParkingSpace.ParkingFee
    timestamps()
  end

  @doc false
  def changeset(parking, attrs \\ %{}) do
    parking
    |> cast(attrs, [:spot, :places, :latitude, :longitude, :parking_fee_id])
    |> validate_required([:spot, :places, :latitude, :longitude, :parking_fee_id])
  end
end
