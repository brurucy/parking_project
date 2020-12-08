defmodule ParkingProject.ParkingSpace.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :destination, :string
    field :status, :string
    field :duration, :float
    field :startdate, :utc_datetime
    field :enddate, :utc_datetime
    field :distance, :float
    field :fee, :integer
    belongs_to :user, ParkingProject.UserManagement.User
    timestamps()
  end

  @doc false
  def changeset(booking, attrs \\ %{}) do
    booking
    |> cast(attrs, [:destination, :duration, :distance, :fee, :startdate, :enddate])
    |> validate_required([:destination, :startdate])
    |> validate_not_equal
  end

  def validate_not_equal(changeset) do
    startdate = get_field(changeset, :startdate)
    enddate = get_field(changeset, :enddate)
    case startdate == enddate do
      true ->
        add_error(changeset, :enddate, "must be different than startdate")
      _ ->
        changeset
    end
  end


end
