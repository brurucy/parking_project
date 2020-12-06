defmodule ParkingProject.Repo.Migrations.AddParkingFeesToParkings do
  use Ecto.Migration

  def change do
    alter table(:parkings) do
      add :parking_fee_id, references(:parking_fees)
    end
  end

end
