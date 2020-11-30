defmodule Parkingproject.PaymentManagement.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :amount, :float
    belongs_to :wallet, Parkingproject.PaymentManagement.Wallet
    belongs_to :booking, ParkingProject.ParkingSpace.Booking

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs \\ %{}) do
    invoice
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
