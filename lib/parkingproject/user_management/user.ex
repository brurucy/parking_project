defmodule ParkingProject.UserManagement.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :license_plate, :string
    field :name, :string
    has_many :parkings, ParkingProject.ParkingSpace.Parking

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :license_plate, :password])
    |> validate_required([:name, :email,:license_plate, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(password))
  end
  defp hash_password(changeset), do: changeset

end
