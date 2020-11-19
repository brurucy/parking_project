defmodule ParkingProjectWeb.SessionControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, UserManagement.User}
  alias Ecto.{Changeset}

  test "log-in", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Welcome #{"bruno98@ut.ee"}/
  end



end