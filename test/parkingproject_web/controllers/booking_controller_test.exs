defmodule ParkingProjectWeb.ParkingControllerTest do
  use ParkingProjectWeb.ConnCase

  alias ParkingProject.{Repo, ParkingSpace.Booking, UserManagement.User}
  alias Ecto.{Changeset}

  test "search - only available parking spots are shown", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")

    conn = post conn, "/parkings", %{"destination" => "Raatuse 22",
      "enddate" => %{
        "day" => "15",
        "hour" => "15",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      },
      "radius" => "3000",
      "startdate" => %{
        "day" => "13",
        "hour" => "12",
        "minute" => "26",
        "month" => "9",
        "year" => "2021"
      }
    }
    
    assert html_response(conn, 200) =~ ~r/Vabriku 1/
    assert html_response(conn, 200) =~ ~r/Lossi 21/
    assert !String.contains?(html_response(conn, 200), "Jakobi")

  end

  test "search - only spots in the range are shwon", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")

    conn = post conn, "/parkings", %{"destination" => "Raatuse 22",
      "enddate" => %{
        "day" => "15",
        "hour" => "15",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      },
      "radius" => "2000",
      "startdate" => %{
        "day" => "13",
        "hour" => "12",
        "minute" => "26",
        "month" => "9",
        "year" => "2021"
      }
    }
    
    # Must only show Lossi. Must not Jakobi and Vabriku
    assert html_response(conn, 200) =~ ~r/Lossi 21/
    assert !String.contains?(html_response(conn, 200), "Jakobi")
    
    assert !String.contains?(html_response(conn, 200), "Vabriku")

  end

  test "search - price corresponds to zone", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    changeset = User.changeset(current_user,  %{"is_hourly" => "true"})

    Repo.update!(changeset)

    conn = post conn, "/parkings", %{"destination" => "Raatuse 22",
      "enddate" => %{
        "day" => "15",
        "hour" => "15",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      },
      "radius" => "3000",
      "startdate" => %{
        "day" => "15",
        "hour" => "14",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      }
    }
    
    assert html_response(conn, 200) =~ ~r/Lossi 21/
    assert html_response(conn, 200) =~ ~r/B/
    assert html_response(conn, 200) =~ ~r/<td>100<\/td>/

    assert html_response(conn, 200) =~ ~r/Vabriku 1/
    assert html_response(conn, 200) =~ ~r/A/
    assert html_response(conn, 200) =~ ~r/<td>200<\/td>/
  end

  test "search - real time correct price", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")

    changeset = User.changeset(current_user,  %{"is_hourly" => "false"})

    Repo.update!(changeset)

    conn = post conn, "/parkings", %{"destination" => "Raatuse 22",
      "enddate" => %{
        "day" => "15",
        "hour" => "15",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      },
      "radius" => "3000",
      "startdate" => %{
        "day" => "15",
        "hour" => "14",
        "minute" => "12",
        "month" => "10",
        "year" => "2021"
      }
    }
    
    assert html_response(conn, 200) =~ ~r/Lossi 21/
    assert html_response(conn, 200) =~ ~r/B/
    assert html_response(conn, 200) =~ ~r/<td>96<\/td>/

    assert html_response(conn, 200) =~ ~r/Vabriku 1/
    assert html_response(conn, 200) =~ ~r/A/
    assert html_response(conn, 200) =~ ~r/<td>192<\/td>/
  end

  test "search - payment method is updated in the db", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")

    IO.inspect current_user.id, label: "current user"
    IO.inspect "/users/" <> current_user.id, label: "WHAT"

    conn = put conn, "/users/" <> String.to_integer(current_user.id), %{"id" => current_user.id, "user" => %{"is_hourly" => "false"}}
    false_hourly_user = Repo.get_by(User, email: "bruno98@ut.ee")

    assert !false_hourly_user.is_hourly

    conn = put conn, "/users/" <> String.to_integer(current_user.id), %{"id" => current_user.id, "user" => %{"is_hourly" => "true"}}
    true_hourly_user = Repo.get_by(User, email: "bruno98@ut.ee")

    assert true_hourly_user.is_hourly
  end
  
  """
  test "book a parking place", %{conn: conn} do
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
    assert html_response(conn, 200) =~ ~r/Jakobi 2/
    assert html_response(conn, 200) =~ ~r/Raatuse 23/
    assert html_response(conn, 200) =~ ~r/50.0/
    assert html_response(conn, 200) =~ ~r/1660.7/
    assert html_response(conn, 200) =~ ~r/A/
  end

  test "closest location", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: 50.0]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Jakobi 2/
  end

  test "invalid destination", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "cdsbchjbdjf", duration: 50.0]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Destination is invalid/
  end

  test "invalid duration (negative number)", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: -50.0]}
    assert html_response(conn, 200) =~ ~r/Duration must be greater than 0/
  end

  test "invalid duration (string instead of number)", %{conn: conn} do
    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    conn = get conn, redirected_to(conn)
    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    conn = post conn, "/bookings", %{booking: [user: current_user, destination: "Raatuse 23", duration: "csjblhebl"]}
    assert html_response(conn, 200) =~ ~r/Duration is invalid/
  end
  """


end