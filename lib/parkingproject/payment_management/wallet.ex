defmodule Parkingproject.PaymentManagement.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :amount, :float
    belongs_to :user, ParkingProject.UserManagement.User
    has_many :invoices, Parkingproject.PaymentManagement.Invoice

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
