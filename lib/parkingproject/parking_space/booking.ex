defmodule ParkingProject.ParkingSpace.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :destination, :string
    field :status, :string
    field :duration, :float
    field :distance, :float
    belongs_to :user, ParkingProject.UserManagement.User
    timestamps()
  end

  @doc false
  def changeset(booking, attrs \\ %{}) do
    booking
    |> cast(attrs, [:destination, :duration, :distance])
    |> validate_required([:destination, :duration])
  end
end
