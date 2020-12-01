defmodule ParkingProjectWeb.WalletControllerTest do
  use ParkingProjectWeb.ConnCase

  import Ecto.Query, only: [from: 2]

  alias Parkingproject.PaymentManagement.{Wallet, Invoice}
  alias ParkingProject.UserManagement.User
  alias ParkingProject.Repo
  alias Ecto.Changeset


  test "Charging the wallet with amount equal to 0", %{conn: conn} do

    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    get conn, redirected_to(conn)

    conn = post conn, "/wallet", %{wallet: [amount: "0"]}
    conn = get conn, redirected_to(conn)

    assert html_response(conn, 200) =~ ~r/The amount should be greater than 0/

  end


  test "Charging the wallet with amount less than 0", %{conn: conn} do

    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    get conn, redirected_to(conn)

    conn = post conn, "/wallet", %{wallet: [amount: "-10.6"]}
    conn = get conn, redirected_to(conn)

    assert html_response(conn, 200) =~ ~r/The amount should be greater than 0/

  end


  test "Charging the wallet with amounts 120.7", %{conn: conn} do

    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    get conn, redirected_to(conn)

    conn = post conn, "/wallet", %{wallet: [amount: "120.7"]}
    conn = get conn, redirected_to(conn)

    assert html_response(conn, 200) =~ ~r/Your amount successfully added/


    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    query_wallet = from w in Wallet,
                    where: w.user_id == ^current_user.id,
                    select: w

    wallet = Repo.one!(query_wallet)

    query_invoices = from i in Invoice,
        where: i.wallet_id == ^wallet.id,
        select: sum(i.amount)

    assert Repo.one(query_invoices) == 120.7

  end


  test "Charging the wallet twice with amounts 100 and 200 and check the balance and invoices", %{conn: conn} do

    conn = post conn, "/sessions", %{session: [email: "bruno98@ut.ee", password: "parool"]}
    get conn, redirected_to(conn)


    conn = post conn, "/wallet", %{wallet: [amount: "100"]}
    conn = get conn, redirected_to(conn)

    assert html_response(conn, 200) =~ ~r/Your amount successfully added/


    conn = post conn, "/wallet", %{wallet: [amount: "200"]}
    conn = get conn, redirected_to(conn)

    assert html_response(conn, 200) =~ ~r/Your amount successfully added/



    current_user = Repo.get_by(User, email: "bruno98@ut.ee")
    query_wallet = from w in Wallet,
                    where: w.user_id == ^current_user.id,
                    select: w

    wallet = Repo.one!(query_wallet)


    query_invoices = from i in Invoice,
        where: i.wallet_id == ^wallet.id,
        select: sum(i.amount)

    assert Repo.one(query_invoices) == 300

  end


end
