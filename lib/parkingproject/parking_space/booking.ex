defmodule ParkingProject.ParkingSpace.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :destination, :string
    field :status, :string
    field :duration, :float
    #field :startdate, :datetime
    #field :enddate, :datetime
    field :distance, :float
    belongs_to :user, ParkingProject.UserManagement.User
    has_one :invoice, Parkingproject.PaymentManagement.Invoice

    timestamps()
  end

  @doc false
  def changeset(booking, attrs \\ %{}) do
    booking
    |> cast(attrs, [:destination, :duration, :distance])
    |> validate_required([:destination, :duration])
    #|> calculate_fee
  end

  #similar to hash_password
  #defp calculate_fee()
end
