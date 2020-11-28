defmodule Parkingproject.Repo.Migrations.CreateZones do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :pricePerHour, :integer
      add :pricePer5mins, :integer

      timestamps()
    end

  end
end
