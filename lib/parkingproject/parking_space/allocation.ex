defmodule ParkingProject.ParkingSpace.Allocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allocations" do
    field :status, :string
    belongs_to :booking, ParkingProject.ParkingSpace.Booking
    belongs_to :parking, ParkingProject.ParkingSpace.Parking
    timestamps()
  end

  @doc false
  def changeset(allocation, attrs \\ %{}) do
    allocation
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
