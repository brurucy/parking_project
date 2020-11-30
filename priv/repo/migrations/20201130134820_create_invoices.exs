defmodule Parkingproject.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :amount, :string
      add :wallet_id, references(:wallets)
      add :booking_id, references(:bookings)

      timestamps()
    end

  end
end
