defmodule ParkingProject.Repo.Migrations.InvoiceAddAmount do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :amount, :float
    end
  end
end
