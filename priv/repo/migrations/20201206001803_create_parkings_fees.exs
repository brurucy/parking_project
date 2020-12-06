defmodule Parkingproject.Repo.Migrations.CreateParkingFees do
  use Ecto.Migration

  def change do
    create table(:parking_fees) do
      add :category, :string
      add :pph, :integer
      add :ppfm, :integer

      timestamps()
    end

  end
end
