defmodule PartTwoContext do
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

  and_ ~r/^click on "(?<Submit>[^"]+)"$/, fn state, %{Submit: submit_button_id} ->
    button_element = find_element(:id, submit_button_id)
    click button_element
    :timer.sleep(100)
    {:ok, state}
  end

  given_ ~r/^that I am logged in with the following credentials "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
         fn state, %{email: email_value, password: password_value} ->
           navigate_to "/"
           button_element = find_element(:id, "sign_in_button")
           :timer.sleep(100)
           click button_element
           :timer.sleep(500)
           email_field = find_element(:id, "email")
           input_into_field(email_field, email_value)
           :timer.sleep(500)
           password_field = find_element(:id, "password")
           input_into_field(password_field, password_value)
           :timer.sleep(250)
           button_element = find_element(:id, "Submit")
           :timer.sleep(500)
           click button_element
           :timer.sleep(500)
           {:ok, state
                 |> Map.put(:email, email_value)
                 |> Map.put(:password, password_value)}
         end

  and_ ~r/^I am on the App$/, fn state ->
    :timer.sleep(750)
    assert visible_in_page? ~r/Welcome #{state[:email_value]}/
    :timer.sleep(750)
    {:ok, state}
  end

  then_ ~r/^I click on the "(?<search>[^"]+)" button$/, fn state, %{search: search_button_id} ->
    search_button = find_element(:id, search_button_id)
    IO.inspect search_button, label: "is it here"
    :timer.sleep(250)
    click search_button
    :timer.sleep(150)
    {:ok, state}
  end

  and_ ~r/^it takes me to the search form$/, fn state ->
    :timer.sleep(250)
    assert visible_in_page? ~r/Search for parking spots!/
    {:ok, state}
  end

  given_ ~r/^that I want to go to "(?<destination>[^"]+)"$/, fn state, %{destination: destination} ->

    :timer.sleep(250)
    destination_form = find_element(:id, "destination")
    clear_field destination_form
    :timer.sleep(250)
    input_into_field(destination_form, destination)

    {:ok, state
          |> Map.put(:destination, destination)}
  end

  and_ ~r/^I dont want to park more than "(?<radius>[^"]+)" metres away from it$/, fn state, %{radius: radius} ->

    :timer.sleep(250)
    radius_form = find_element(:id, "radius")
    clear_field radius_form
    :timer.sleep(250)
    input_into_field(radius_form, radius)

    {:ok, state
          |> Map.put(:radius, radius)}

  end

  given_ ~r/^that I select year "(?<year>[^"]+)" month "(?<month>[^"]+)" day "(?<day>[^"]+)" hour "(?<hour>[^"]+)" minute "(?<minute>[^"]+)"$/,
         fn state, %{year: year,month: month,day: day,hour: hour,minute: minute} ->
           :timer.sleep(250)
           year_form = find_element(:id, "start_year")
           :timer.sleep(250)
           input_into_field(year_form, year)

           :timer.sleep(250)
           month_form = find_element(:id, "start_month")
           :timer.sleep(250)
           input_into_field(month_form, month)

           :timer.sleep(250)
           day_form = find_element(:id, "start_day")
           :timer.sleep(250)
           input_into_field(day_form, day)

           :timer.sleep(250)
           hour_form = find_element(:id, "start_hour")
           :timer.sleep(250)
           input_into_field(hour_form, hour)

           :timer.sleep(250)
           minute_form = find_element(:id, "start_minute")
           :timer.sleep(250)
           input_into_field(minute_form, minute)

           {:ok, state}
         end

  given_ ~r/^the following parking spaces are available$/, fn state, %{table_data: table} ->
    {:ok, Enum.map(table, fn x -> Map.put(state, x."Spot", x) end)}
  end

  and_ ~r/^submit it$/, fn state ->
    button_element = find_element(:id, "Submit")
    :timer.sleep(5000)
    click button_element
    :timer.sleep(5000)
    {:ok, state}
  end

  then_ ~r/^I should see the available parking places with the given Radius constraint$/, fn state ->

    :timer.sleep(500)

    assert visible_in_page? ~r/Jakobi/

    assert visible_in_page? ~r/Lossi/

    refute visible_in_page? ~r/Vabriku/

    :timer.sleep(500)

    {:ok, state}
  end

  given_ ~r/^that I select year "(?<year>[^"]+)" month "(?<month>[^"]+)" day "(?<day>[^"]+)" hour "(?<hour>[^"]+)" minute "(?<minute>[^"]+)" as end date$/,
         fn state, %{year: year,month: month,day: day,hour: hour,minute: minute} ->

           year_form = find_element(:id, "end_year")
           :timer.sleep(250)
           input_into_field(year_form, year)

           :timer.sleep(250)
           month_form = find_element(:id, "end_month")
           :timer.sleep(250)
           input_into_field(month_form, month)

           :timer.sleep(250)
           day_form = find_element(:id, "end_day")
           :timer.sleep(250)
           input_into_field(day_form, day)

           :timer.sleep(250)
           hour_form = find_element(:id, "end_hour")
           :timer.sleep(250)
           input_into_field(hour_form, hour)

           :timer.sleep(250)
           minute_form = find_element(:id, "end_minute")
           :timer.sleep(250)
           input_into_field(minute_form, minute)

           {:ok, state}
         end

  then_ ~r/^I should see the price, zone and availability$/, fn state ->

    :timer.sleep(500)

    # Category A

    assert visible_in_page? ~r/A/

                              # Category B

    assert visible_in_page? ~r/B/

    :timer.sleep(500)

    # Availability one

    assert visible_in_page? ~r/50/

                              # Availability two

    assert visible_in_page? ~r/30/

                              # Availability three

    assert visible_in_page? ~r/3/

                              # Because the two zones are the same

                              # Price one

    assert visible_in_page? ~r/100/

                              # Price two

    assert visible_in_page? ~r/200/

    {:ok, state}

  end

  and_ ~r/^know that my payment scheme is hourly$/, fn state ->

    query = from u in User, where: u.email == "bruno98@ut.ee"

    user_with_email = Repo.one!(query)

    user_params = %{is_hourly: true}

    changeset = User.changeset(user_with_email, user_params)

    IO.inspect changeset, label: "user_changeset"

    case Repo.update(changeset) do

      {:ok, user_new} ->

        IO.inspect user_new, label: "testib"

        assert user_new.is_hourly

        {:ok, state}

      {:error, "yikes"} ->

        {:error, state}

    end
  end

  and_ ~r/^know that my payment scheme is real-time$/, fn state ->

    query = from u in User, where: u.email == "bruno98@ut.ee"

    user_with_email = Repo.one!(query)

    user_params = %{is_hourly: false}

    changeset = User.changeset(user_with_email, user_params)

    IO.inspect changeset, label: "user_changeset"

    case Repo.update(changeset) do

      {:ok, user_new} ->

        refute user_new.is_hourly

        {:ok, state}

      {:error, "yikes"} ->

        {:error, state}

    end

  end

  then_ ~r/^I should see the estimated hourly fee$/, fn state ->

    assert visible_in_page? ~r/100/

    assert visible_in_page? ~r/200/

    {:ok, state}

  end

  then_ ~r/^I should see the estimated real-time fee$/, fn state ->

    assert visible_in_page? ~r/96/

    assert visible_in_page? ~r/192/

    {:ok, state}

  end

end