defmodule ParkingProjectWeb.UserControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, UserMgmt.User}
  alias Ecto.{Changeset}

  test "GET /", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "brurucy@protonmail.ch", password: "parool"]}
    assert html_response(conn, 200) =~ ~r/Yeehaw/
  end




end