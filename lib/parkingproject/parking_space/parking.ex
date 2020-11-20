defmodule ParkingProject.ParkingSpace.Parking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parking" do
    field :destination, :string
    field :status, :string
    belongs_to :user, ParkingProject.UserManagement.User
    timestamps()
  end

  @doc false
  def changeset(parking, attrs) do
    parking
    |> cast(attrs, [:destination, :status])
    |> validate_required([:destination, :status])
  end
end
