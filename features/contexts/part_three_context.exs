defmodule PartThreeContext do
  use WhiteBread.Context
  use Hound.Helpers
  import Ecto.Query, only: [from: 2]


  alias ParkingProject.{Repo}
  alias ParkingProject.{UserManagement.User, ParkingSpace.Parking, ParkingSpace.Booking, ParkingSpace.Allocation, PaymentManagement.Wallet}
  alias Ecto.Changeset

  feature_starting_state fn ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(ParkingProject.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ParkingProject.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(ParkingProject.Repo)
    Hound.end_session
  end

  then_ ~r/^I click on "(?<argument_one>[^"]+)"$/, fn state, %{argument_one: _argument_one} ->

    extend = find_element(:id, "Extend")

    :timer.sleep(500)

    click extend

    {:ok, state}
  end

  and_ ~r/^select real-time$/, fn state ->
    :timer.sleep(250)

    yes_element = find_element(:id, "no")

    click yes_element

    {:ok, state}
  end

  and_ ~r/^select hourly$/, fn state ->

    :timer.sleep(250)

    yes_element = find_element(:id, "yes")

    click yes_element

    {:ok, state}

  end

  when_ ~r/^I click "(?<book>[^"]+)"$/, fn state, %{book: book} ->

    :timer.sleep(250)

    yes_element = find_element(:id, book)

    :timer.sleep(250)

    user_query = from u in User, where: u.email == "bruno98@ut.ee"

    user_with_email = Repo.one!(user_query)

    wallet_changeset = Wallet.changeset(%Wallet{}, %{})
                       |> Changeset.put_change(:amount, 1000)
                       |> Changeset.put_change(:user, user_with_email)

    case Repo.insert(wallet_changeset) do

      {:ok, _} ->

        :timer.sleep(250)

        click yes_element

        {:ok, state}

      _ ->
    end
  end

  then_ ~r/^I should get a confirmation$/, fn state ->

    :timer.sleep(750)
    assert visible_in_page? ~r/Parking confirmed Vabriku 1/
    :timer.sleep(750)
    {:ok, state}
  end

  and_ ~r/^I see the booking on "(?<spot>[^"]+)"$/, fn state, %{spot: spot} ->

    :timer.sleep(1500)
    assert visible_in_page? ~r/Vabriku/
    {:ok, state}

  end

  and_ ~r/^I extend it by an hour$/, fn state ->

    :timer.sleep(500)

    hour_element = find_element(:id, "end_hour")
    input_into_field(hour_element, "12")

    :timer.sleep(500)

    {:ok, state}
  end

  then_ ~r/^I should see the end date extended by one hour and the fee by 200 cents$/, fn state ->

    assert visible_in_page? ~r/12:10:00/
    assert visible_in_page? ~r/400/

    {:ok, state}
  end

end