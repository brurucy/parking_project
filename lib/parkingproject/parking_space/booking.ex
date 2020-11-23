defmodule ParkingProject.ParkingSpace.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "booking" do
    field :destination, :string
    field :status, :string
    belongs_to :user, ParkingProject.UserManagement.User
    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:destination, :status])
    |> validate_required([:destination, :status])
  end
end
