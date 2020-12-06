defmodule ParkingProject.Repo.Migrations.AddFeeToBooking do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :fee, :integer
    end
  end
end
