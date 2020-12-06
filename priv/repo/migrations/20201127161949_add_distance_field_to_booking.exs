defmodule ParkingProject.Repo.Migrations.AddDistanceFieldToBooking do
  use Ecto.Migration

  
  def change do
    alter table(:bookings) do
      add :distance, :float
    end
  end
  
end
