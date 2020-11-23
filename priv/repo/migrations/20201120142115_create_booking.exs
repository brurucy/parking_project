defmodule Parkingproject.Repo.Migrations.CreateBooking do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :status, :string, default: "open"
      add :destination, :string
      add :user_id, references(:users)
      timestamps()
    end

  end
end
