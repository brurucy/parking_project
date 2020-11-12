defmodule ParkingProject.Repo do
  use Ecto.Repo,
    otp_app: :parkingproject,
    adapter: Ecto.Adapters.Postgres
end
