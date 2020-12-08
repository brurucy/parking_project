defmodule ParkingProject.ParkingSpace.ParkingFee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking_fees" do
    field :category, :string
    field :ppfm, :integer
    field :pph, :integer
    has_many :parkings, ParkingProject.ParkingSpace.Parking
    timestamps()
  end

  @doc false
  def changeset(parking_fee, attrs) do
    parking_fee
    |> cast(attrs, [:category, :pph, :ppfm])
    |> validate_required([:category, :pph, :ppfm])
  end
end
