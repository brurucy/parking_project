defmodule ParkingProject.Repo.Migrations.AddStartdateEnddateToBooking do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :startdate, :utc_datetime
      add :enddate, :utc_datetime
    end
  end
end
