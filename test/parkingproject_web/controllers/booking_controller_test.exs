defmodule ParkingProjectWeb.ParkingControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, ParkingSpace.Booking, UserManagement.User}
  alias Ecto.{Changeset}

  test "search parking place", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")

    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: 50.0]}
  #  :timer.sleep(2500)
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Parking confirmed/
  end

  test "display parking place details", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: 50.0]}
  #  :timer.sleep(2500)
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Jakobi, Tartu/
    assert html_response(conn, 200) =~ ~r/Raatuse 23/
    assert html_response(conn, 200) =~ ~r/50.0/
    assert html_response(conn, 200) =~ ~r/1.773/
    assert html_response(conn, 200) =~ ~r/A/
  end

  test "closest location", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: 50.0]}
  #  :timer.sleep(3000)
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Jakobi, Tartu/
  end

  test "invalid destination", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "cdsbchjbdjf", duration: 50.0]}
    #:timer.sleep(3000)
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Destination is invalid/
  end

  test "display parking place details", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: 50.0]}
    #  :timer.sleep(2500)
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Jakobi, Tartu/
    assert html_response(conn, 200) =~ ~r/Raatuse 23/
    assert html_response(conn, 200) =~ ~r/50.0/
    assert html_response(conn, 200) =~ ~r/1.773/
    assert html_response(conn, 200) =~ ~r/A/
  end


end