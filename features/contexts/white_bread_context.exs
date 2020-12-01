defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias ParkingProject.{Repo}
  alias ParkingProject.{UserManagement.User, ParkingSpace.Parking, ParkingSpace.Booking, ParkingSpace.Allocation}
  alias Ecto.Changeset

  feature_starting_state fn ->
    Application.ensure_all_started(:hound)
    %{}
  end

  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(ParkingProject.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(ParkingProject.Repo, {:shared, self()})
  end

  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(ParkingProject.Repo)
    Hound.end_session
  end


  given_ ~r/^that I am logged in with the following credentials "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
  fn state, %{email: email,password: password} ->
    navigate_to "/"
    button_element = find_element(:id, "sign_in_button")
    :timer.sleep(500)
    click button_element
    :timer.sleep(500)
    email_field = find_element(:id, "email")
    input_into_field(email_field, email)
    :timer.sleep(500)
    password_field = find_element(:id, "password")
    input_into_field(password_field, password)
    :timer.sleep(500)
    button_element = find_element(:id, "Submit")
    :timer.sleep(500)
    click button_element
    :timer.sleep(500)
    {:ok, state}
  end


  and_ ~r/^I am on the App$/, fn state ->
    :timer.sleep(750)
    assert visible_in_page? ~r/Welcome bruno98@ut.ee/
    :timer.sleep(750)
    {:ok, state}
  end


  then_ ~r/^I click on "(?<my_wallet_button>[^"]+)" button$/,
  fn state, %{my_wallet_button: my_wallet_button} ->
    wallet_button = find_element(:id, my_wallet_button)
    :timer.sleep(500)
    click wallet_button
    :timer.sleep(500)
    {:ok, state}
  end



  and_ ~r/^My initial balance "(?<ibalance>[^"]+)" is added$/,
  fn state, %{ibalance: ibalance} ->
    :timer.sleep(500)
    amount_field = find_element(:id, "amount")
    :timer.sleep(500)
    input_into_field(amount_field, ibalance)
    :timer.sleep(500)
    submit_button = find_element(:id, "button_Submit")
    :timer.sleep(500)
    click submit_button
    :timer.sleep(500)
    assert visible_in_page? ~r/Your amount successfully added/
    :timer.sleep(500)

    {:ok, state}
  end



  when_ ~r/^I fill the form with "(?<amount>[^"]+)" as the amount$/,
  fn state, %{amount: amount} ->
    :timer.sleep(500)
    amount_field = find_element(:id, "amount")
    :timer.sleep(500)
    input_into_field(amount_field, amount)

    {:ok, state}
  end



  and_ ~r/^submit it$/, fn state ->
    :timer.sleep(500)
    submit_button = find_element(:id, "button_Submit")
    :timer.sleep(500)
    click submit_button

    {:ok, state}
  end


  then_ ~r/^it should show me "(?<balance>[^"]+)" as my balance$/,
  fn state, %{balance: balance} ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Your current balance is: #{balance}/
    :timer.sleep(500)

    {:ok, state}
  end


  then_ ~r/^I click to log-out$/, fn state ->
    :timer.sleep(500)
    log_out_button_element = find_element(:id, "logout_button")
    :timer.sleep(500)
    click log_out_button_element

    {:ok, state}
  end


  # --------- the second scenario (some parts are in common with the first scenario)

  and_ ~r/^it takes me to the index of the wallet$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Wallet index!/
    {:ok, state}
  end


  and_ ~r/^I charge my wallet two times with amounts "(?<amount1>[^"]+)" and "(?<amount2>[^"]+)"$/,
  fn state, %{amount1: amount1,amount2: amount2} ->
    :timer.sleep(500)
    amount_field = find_element(:id, "amount")
    :timer.sleep(500)
    input_into_field(amount_field, amount1)
    :timer.sleep(500)
    submit_button = find_element(:id, "button_Submit")
    :timer.sleep(500)
    click submit_button
    :timer.sleep(500)
    assert visible_in_page? ~r/Your amount successfully added/
    :timer.sleep(500)

    :timer.sleep(500)
    amount_field = find_element(:id, "amount")
    :timer.sleep(500)
    input_into_field(amount_field, amount2)
    :timer.sleep(500)
    submit_button = find_element(:id, "button_Submit")
    :timer.sleep(500)
    click submit_button
    :timer.sleep(500)
    assert visible_in_page? ~r/Your amount successfully added/
    :timer.sleep(500)

    {:ok, state}
  end



  then_ ~r/^it should show me two transactions with amounts of "(?<amount1>[^"]+)" and "(?<amount2>[^"]+)"$/,
  fn state, %{amount1: amount1,amount2: amount2} ->
    assert visible_in_page? ~r/#{amount1}/
    :timer.sleep(500)
    assert visible_in_page? ~r/#{amount2}/
    :timer.sleep(500)
    {:ok, state}
  end


end
