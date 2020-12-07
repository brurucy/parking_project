defmodule ParkingProject.PaymentManagement.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :amount, :integer#, default: 1
    belongs_to :wallet, ParkingProject.PaymentManagement.Wallet
    belongs_to :booking, ParkingProject.ParkingSpace.Booking

    timestamps()
  end

  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:amount, :wallet_id, :booking_id])
    #|> validate_number(:amount, greater_than: 0, message: "The amount should be greater than 0")

  end
end
