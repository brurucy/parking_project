use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :parkingproject, ParkingProject.Repo,
  username: "postgres",
  password: "postgres",
  database: "parkingproject_test#{System.get_env("MIX_TEST_PARTITION")}",
  #hostname: "localhost",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :parkingproject, ParkingProjectWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn, backends: [:console], compile_time_purge_level: :debug
config :hound, driver: "chrome_driver", host: "wdriver", port: 4444
config :parkingproject, sql_sandbox: true
