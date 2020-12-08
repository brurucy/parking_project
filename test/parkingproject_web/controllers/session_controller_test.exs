defmodule ParkingProjectWeb.SessionControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, UserManagement.User}
  alias Ecto.{Changeset}

  # All of these are 1.1
  test "log-in", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Welcome #{"bruno98@ut.ee"}/
  end

  test "log-in incorrect", %{conn: conn} do
    unregistered_user = Repo.get_by(User, email: "amir@ut.ee")
    assert unregistered_user == nil
    conn = post conn, "/sessions", %{session: [email: "amir@ut.ee", password: "parool"]}
    assert html_response(conn, 200) =~ ~r/Bad Credentials/
  end

  test "log-out", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = delete conn, "/sessions/#{current_user.id}"
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Fine, leave then./
  end


end