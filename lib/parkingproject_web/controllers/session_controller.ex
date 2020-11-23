defmodule ParkingProjectWeb.SessionController do
  use ParkingProjectWeb, :controller

  alias ParkingProject.Repo
  alias ParkingProject.UserManagement.User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    IO.puts "EEEEE1"
    user = Repo.get_by(User, email: email)
    Repo.preload(user, :bookings)
    case ParkingProject.Authentication.check_credentials(user, password) do
      {:ok, _} ->
        conn
        |> ParkingProject.Authentication.login(user)
        |> put_flash(:info, "Welcome #{email}")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Bad Credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    IO.puts "EEEEE2"
    conn
    |> ParkingProject.Authentication.logout()
    |> put_flash(:info, "Fine, leave then.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

end