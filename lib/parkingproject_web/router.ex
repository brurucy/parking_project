defmodule ParkingProjectWeb.Router do
  use ParkingProjectWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug ParkingProject.AuthPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ParkingProjectWeb do
    pipe_through :browser
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", ParkingProjectWeb do
    pipe_through [:browser, :browser_auth]
    get "/", PageController, :index
  end

  scope "/", ParkingProjectWeb do
    pipe_through [:browser, :browser_auth, :ensure_auth]
    resources "/users", UserController
    resources "/bookings", BookingController
    resources "/parkings", ParkingController
    #post "/parkings/search", ParkingController, :search
    resources "/wallet", WalletController
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ParkingProjectWeb.Telemetry
    end
  end
end