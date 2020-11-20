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
    resources "/users", UserController
  end

  scope "/", ParkingProjectWeb do
    pipe_through [:browser, :browser_auth]
    get "/", PageController, :index
    resources "/parkings", ParkingController
  end

  #scope "/", ParkingProjectWeb do
  #  pipe_through :browser
#
  #  get "/", PageController, :index
  #  resources "/users", UserController
  #  resources "/sessions", SessionController, only: [:new, :create, :delete]
  #end

  # Other scopes may use custom stacks.
  # scope "/api", ParkingProjectWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ParkingProjectWeb.Telemetry
    end
  end
end
