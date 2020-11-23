defmodule Parkingproject.Repo.Migrations.CreateAllocations do
  use Ecto.Migration

  def change do
    create table(:allocations) do
      add :status, :string
      add :booking_id, references(:bookings)
      add :parking_id, references(:parkings)

      timestamps()
    end
    create unique_index(:allocations, [:booking_id, :parking_id])
  end
end
