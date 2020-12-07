defmodule Parkingproject.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :amount, :integer
      add :user_id, references(:users)
      timestamps()
    end

    create unique_index(:wallets, [:user_id])

  end
end
