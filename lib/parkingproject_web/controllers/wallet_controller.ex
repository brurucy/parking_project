defmodule ParkingProjectWeb.WalletController do
  use ParkingProjectWeb, :controller

  import Ecto.Query, only: [from: 2]

  alias Parkingproject.PaymentManagement.{Wallet, Invoice}
  alias ParkingProject.Repo
  alias Ecto.Changeset


  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do

    changeset = Wallet.changeset(%Wallet{}, %{})


    wallet_original = getWallet(conn)
    walletExists = wallet_original != nil
    balance = getUserBalance(conn, wallet_original)


    id = if walletExists, do: wallet_original.id, else: -1
    query_invoices = from i in Invoice,
                    where: i.wallet_id == ^id,
                    order_by: [desc: i.inserted_at],
                    select: %{amount: i.amount, date: i.inserted_at}


    render conn, "index.html", data: %{
        balance: balance,
        changeset: changeset,
        invoices: Repo.all(query_invoices)
    }

  end

  def create(conn, %{"wallet" => wallet_params}) do

    user = ParkingProject.Authentication.load_current_user(conn)

    wallet_original = getWallet(conn)
    walletExists = wallet_original != nil

    {amount, _} = Float.parse(wallet_params["amount"])


    if(amount <= 0) do

      conn
      |> put_flash(:error, "The amount should be greater than 0")
      |> redirect(to: Routes.wallet_path(conn, :index))

    else

        case walletExists do
          true ->

            balance = getUserBalance(conn, wallet_original)

            wallet_changeset = Repo.get!(Wallet, wallet_original.id)
              |> Wallet.changeset(%{amount: balance + amount})

            case Repo.update(wallet_changeset) do
              {:ok, wallet} ->

                invoice_changeset = %Invoice{}
                  |> Invoice.changeset(%{amount: amount})
                  |> Changeset.put_change(:wallet, wallet)

                Repo.insert!(invoice_changeset)

            end

          _ ->

            wallet_struct = Enum.map(wallet_params, fn({key, value}) -> {String.to_atom(key), value} end)
              |> Enum.into(%{})

            wallet_changeset = %Wallet{}
              |> Wallet.changeset(wallet_struct)
              |> Changeset.put_change(:amount, amount)
              |> Changeset.put_change(:user, user)

            case Repo.insert(wallet_changeset) do
              {:ok, wallet} ->

                invoice_changeset = %Invoice{}
                  |> Invoice.changeset(%{amount: amount})
                  |> Changeset.put_change(:wallet, wallet)

              Repo.insert!(invoice_changeset)

            end

        end

        redirect(conn, to: Routes.wallet_path(conn, :index))

      end

  end


  # ------------------------------------- private members

  defp getUserBalance(conn, wallet) do

    wallet = if wallet == nil, do: getWallet(conn), else: wallet
    if wallet == nil, do: 0, else: wallet.amount

  end

  defp getWallet(conn) do

    user = ParkingProject.Authentication.load_current_user(conn)
    query_wallet = from w in Wallet,
                    where: w.user_id == ^user.id,
                    select: w

    if Repo.exists?(query_wallet), do: Repo.one!(query_wallet), else: nil

  end

end
