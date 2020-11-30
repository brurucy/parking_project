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
    #Hound.end_session
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
      #IO.inspect email, label: "e_post_one"
      #IO.inspect state |> Map.put(:email, email), label: "Statehood"
      {:ok, state}
  end

  and_ ~r/^I am on the App$/, fn state ->
    #IO.inspect state[:email], label: "e_post_two"
    #:timer.sleep(750)
    #navigate_to "/"
    :timer.sleep(750)
    #assert visible_in_page? ~r/Welcome #{state[:email]}/
    assert visible_in_page? ~r/Welcome bruno98@ut.ee/
    :timer.sleep(750)
    {:ok, state}
  end

  then_ ~r/^I click on the "(?<park>[^"]+)" button$/, fn state, %{park: park_button_id} ->
    park_button = find_element(:id, park_button_id)
    IO.inspect park_button, label: "is it here"
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

  then_ ~r/^it should give me the closest parking space "(?<closest_parking_place>[^"]+)" and a confirmation$/,
  fn state, %{closest_parking_place: closest_parking_place} ->
    :timer.sleep(2000)
    assert visible_in_page? ~r/Parking confirmed #{closest_parking_place}/
    {:ok, state}
  end

  then_ ~r/^I click to log-out$/, fn state ->
    :timer.sleep(500)
    log_out_button_element = find_element(:id, "logout_button")
    :timer.sleep(500)
    click log_out_button_element
    :timer.sleep(500)
    {:ok, state}
  end

  # here starts display parking space details

  then_ ~r/^I click on "(?<my_parking_button>[^"]+)" button$/, fn state, %{my_parking_button: my_parking_button} ->
    my_parking_button = find_element(:id, "my_parking_button")
    click my_parking_button
    {:ok, state}
  end

  and_ ~r/^it takes me to the index of parkings$/, fn state ->
    user = Repo.get(User, 1)
    booking = %Booking{}
              |> Booking.changeset(%{duration: 10.0, destination: "Raatuse 23", distance: 5.0})
              |> Changeset.put_change(:user, user)
              |> Changeset.put_change(:status, "taken")
              |> Repo.insert!
              #|> Repo.preload(:user)

    IO.inspect booking, label: "yikes"

    parking = Repo.get(Parking, 1)

    allocation = %Allocation{}
                 |> Allocation.changeset(%{status: "active"})
                 |> Changeset.put_change(:booking_id, booking.id)
                 |> Changeset.put_change(:parking_id, parking.id)
                 |> Repo.insert!
                # |> Repo.preload(:user, :booking)

    IO.inspect allocation, label: "yikes2"

    assert visible_in_page? ~r/Listing bookings/
    {:ok, state}
  end

  then_ ~r/^it shows me all my past parkings info$/, fn state ->
    navigate_to "/bookings"
    assert visible_in_page? ~r/Vabriku, Tartu/
    assert visible_in_page? ~r/Raatuse 23/
    assert visible_in_page? ~r/10.0/
    assert visible_in_page? ~r/B/
    assert visible_in_page? ~r/5.0/
    {:ok, state}
  end

end