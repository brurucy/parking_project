defmodule Parkingproject.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :status, :string, default: "open"
      add :destination, :string
      add :duration, :float
      timestamps()
    end

  end
end
