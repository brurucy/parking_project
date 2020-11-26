defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias ParkingProject.{Repo}
  alias ParkingProject.{UserManagement.User, ParkingSpace.Parking}

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
    #Hound.end_session
  end

  given_ ~r/^that I am logged in$/, fn state ->
    navigate_to "/"
    button_element = find_element(:id, "sign_in_button")
    :timer.sleep(100)
    click button_element
    :timer.sleep(500)
    email_field = find_element(:id, "email")
    input_into_field(email_field, "bruno98@ut.ee")
    :timer.sleep(500)
    password_field = find_element(:id, "password")
    input_into_field(password_field, "parool")
    :timer.sleep(250)
    button_element = find_element(:id, "Submit")
    :timer.sleep(500)
    click button_element
    :timer.sleep(500)
    {:ok, state}
  end

  given_ ~r/^that I am logged in with the following credentials "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
    fn state, %{email: email, password: password} ->
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
    :timer.sleep(250)
    assert visible_in_page? ~r/Welcome #{state[:email]}/
    :timer.sleep(250)
    {:ok, state}
  end

  then_ ~r/^I click on the "(?<park>[^"]+)" button$/, fn state, %{park: park_button_id} ->
    park_button = find_element(:id, park_button_id)
    :timer.sleep(250)
    click park_button
    :timer.sleep(150)
    {:ok, state}
  end

  and_ ~r/^it takes me to the parking form$/, fn state ->
    :timer.sleep(250)
    assert visible_in_page? ~r/Book your parking!/
    {:ok, state}
  end

  and_ ~r/^the following parking spaces are available$/, fn state ->

    parking_spots = ["Vabriku, Tartu", "Lossi, Tartu", "Jakobi, Tartu"]

    parking_spots_get = parking_spots
      |> Enum.map(fn parking_spot -> Repo.get_by(Parking, spot: parking_spot) end)
      |> Enum.map(fn parking_spot -> assert parking_spot != nil end)

    {:ok, state}
  end

  when_ ~r/^I fill the form with "(?<destination>[^"]+)" as the destination and "(?<duration>[^"]+)" as duration$/,
  fn state, %{destination: destination_location,duration: duration_time} ->
    destination_field = find_element(:id, "destination")
    :timer.sleep(250)
    input_into_field(destination_field, destination_location)
    :timer.sleep(250)
    duration_field = find_element(:id, "duration")
    :timer.sleep(250)
    input_into_field(duration_field, duration_time)
    :timer.sleep(250)

    {:ok, state}
  end

  and_ ~r/^submit it$/, fn state ->
    button_element = find_element(:id, "Submit")
    :timer.sleep(250)
    click button_element
    :timer.sleep(250)
    {:ok, state}
  end

  then_ ~r/^it should give me the closest parking space$/, fn state ->
    :timer.sleep(2000)

    {:ok, state}
  end

end