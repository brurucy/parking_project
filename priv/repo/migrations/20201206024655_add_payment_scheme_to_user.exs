defmodule ParkingProject.Repo.Migrations.AddPaymentSchemeToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_hourly, :boolean
    end
  end
end
