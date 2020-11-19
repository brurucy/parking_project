defmodule ParkingProjectWeb.UserControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, UserManagement.User}
  alias Ecto.{Changeset}

  test "GET /", %{conn: conn} do
    conn = post conn, "/users", %{user: [email: "bruno98@ut.ee",
      password: "parool",
      license_plate: "666SATYR",
      name: "Rucy"]}
    assert html_response(conn, 200) =~ ~r/Please log-in/
  end




end