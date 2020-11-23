defmodule Parkingproject.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :license_plate, :string
      add :hashed_password, :string
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
