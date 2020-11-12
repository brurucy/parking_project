defmodule ParkingProjectWeb.PageController do
  use ParkingProjectWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
