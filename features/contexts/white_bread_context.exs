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
    :timer.sleep(100)
    click button_element
    :timer.sleep(500)
    email_field = find_element(:id, "email")
    input_into_field(email_field, email)
    :timer.sleep(500)
    password_field = find_element(:id, "password")
    input_into_field(password_field, password)
    :timer.sleep(250)
    button_element = find_element(:id, "Submit")
    :timer.sleep(500)
    click button_element
    :timer.sleep(500)
    {:ok, state}
  end


  and_ ~r/^I am on the App$/, fn state ->
    navigate_to "/"
    :timer.sleep(750)
    assert visible_in_page? ~r/Welcome #{state[:email]}/
    :timer.sleep(750)
    {:ok, state}
  end


  then_ ~r/^I click on "(?<my_wallet_button>[^"]+)" button$/,
  fn state, %{my_wallet_button: my_wallet_button} ->
    park_button = find_element(:id, my_wallet_button)
    :timer.sleep(250)
    click park_button
    :timer.sleep(150)
    {:ok, state}
  end


  and_ ~r/^My current balance is "(?<current_balance>[^"]+)"$/,
  fn state, %{current_balance: current_balance} ->
    {:ok, state}
  end


  when_ ~r/^I fill the form with "(?<amount>[^"]+)" as the amount$/,
  fn state, %{amount: amount} ->
    {:ok, state}
  end


  and_ ~r/^submit it$/, fn state ->
    {:ok, state}
  end


  then_ ~r/^it should charge my wallet and show me "(?<balance>[^"]+)" as my balance$/,
  fn state, %{balance: balance} ->
    {:ok, state}
  end


  then_ ~r/^I click to log-out$/, fn state ->
    {:ok, state}
  end




  and_ ~r/^it takes me to the index of the wallet$/, fn state ->
    {:ok, state}
  end


  then_ ~r/^it shows me all of the transactions for charging my wallet$/, fn state ->
    {:ok, state}
  end


end
