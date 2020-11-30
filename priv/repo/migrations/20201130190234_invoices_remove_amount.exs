defmodule ParkingProject.Repo.Migrations.UpdateInvoiceAmount do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      remove :amount, :string
    end
  end
end
