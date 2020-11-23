defmodule Parkingproject.Repo.Migrations.CreateParkings do
  use Ecto.Migration

  def change do
    create table(:parkings) do
      add :spot, :string
      add :category, :string
      add :places, :integer
      add :latitude, :float
      add :longitude, :float
      timestamps()
    end

  end
end
