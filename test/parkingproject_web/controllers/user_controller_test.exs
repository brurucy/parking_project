defmodule ParkingProjectWeb.UserControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, UserManagement.User}
  alias Ecto.{Changeset}

  test "register", %{conn: conn} do
    conn = post conn, "/users", %{user: [email: "bruno98@ut.ee",
      password: "parool",
      license_plate: "666SATYR",
      name: "Rucy"]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Please log in./
  end

  test "email validation", %{conn: conn} do
    conn = post conn, "/users", %{user: [email: "bruno98",
      password: "parool",
      license_plate: "666SATYR",
      name: "Rucy"]}
    assert html_response(conn, 200) =~ ~r/Oops, something went wrong! Please check the errors below./
  end

  test "password validation", %{conn: conn} do
    conn = post conn, "/users", %{user: [email: "bruno98@ut.ee",
      password: nil,
      license_plate: "666SATYR",
      name: "Rucy"]}
    assert html_response(conn, 200) =~ ~r/Oops, something went wrong! Please check the errors below./
  end

end