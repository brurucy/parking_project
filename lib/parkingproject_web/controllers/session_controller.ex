defmodule ParkingProjectWeb.SessionController do
  use ParkingProjectWeb, :controller

  alias ParkingProject.Repo
  alias ParkingProject.UserManagement.User, as: User

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    user = Repo.get_by(User, username: username)
    case ParkingProject.Authentication.check_credentials(user, password) do
      {:ok, _} ->
        conn
        |> ParkingProject.Authentication.login(user)
        |> put_flash(:info, "Welcome #{username}")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Bad Credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> ParkingProject.Authentication.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end

end