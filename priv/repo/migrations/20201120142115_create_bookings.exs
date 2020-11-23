defmodule Parkingproject.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :status, :string, default: "open"
      add :destination, :string
      add :duration, :float
      add :user_id, references(:users)
      timestamps()
    end

  end
end
