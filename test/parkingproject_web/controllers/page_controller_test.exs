defmodule ParkingProjectWeb.PageControllerTest do
  use ParkingProjectWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Tartu Parking System!"
  end
end
