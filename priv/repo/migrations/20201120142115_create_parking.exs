defmodule Parkingproject.Repo.Migrations.CreateParking do
  use Ecto.Migration

  def change do
    create table(:parking) do
      add :destination, :string
      add :status, :string

      timestamps()
    end

  end
end
