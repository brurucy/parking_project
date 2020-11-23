defmodule ParkingProject.Repo.Migrations.AddBookingsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :booking_id, references(:bookings)
    end
  end
end
