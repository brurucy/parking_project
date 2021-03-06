# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :parkingproject,
  ecto_repos: [ParkingProject.Repo]

# Configures the endpoint
config :parkingproject, ParkingProjectWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dq/psd86+fmmo0x3QxrwbavqrCYjjzYGdo9NPBwo6q9kGpXG0Y2e6ah28wMAJTfE",
  render_errors: [view: ParkingProjectWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ParkingProject.PubSub,
  live_view: [signing_salt: "h5zhnEo9"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :parkingproject, ParkingProject.Guardian,
  issuer: "parkingproject",
  secret_key: "hnBIlgb6IhfXChBBSj6P/y64gDxuD8eiQVDcGXBsCT1+omX+Xy8K/6lZyaJs2ezV"
