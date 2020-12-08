defmodule ParkingProject.PaymentManagement.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :amount, :integer#, default: 1
    belongs_to :user, ParkingProject.UserManagement.User
    has_many :invoices, ParkingProject.PaymentManagement.Invoice
    timestamps()
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:amount, :user_id])
    #|> validate_number(:amount, greater_than: 0, message: "The amount should be greater than 0")
  end
end
