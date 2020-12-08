defmodule WhiteBreadContext do
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
    #Hound.end_session
  end

  given_ ~r/^that I do not already have an account with email "(?<email>[^"]+)"$/,
         fn state, %{email: email} ->
           case Repo.get_by(User, email: email) do
             nil -> {:ok, state |> Map.put(:email, email)}
             _ -> {:error, state}
           end
         end

  when_ ~r/^I open the app$/, fn state ->
    navigate_to "/"
    {:ok, state}
  end

  then_ ~r/^I see the button "(?<button_value>[^"]+)"$/, fn state, %{button_value: button_value} ->

    :timer.sleep(500)

    assert visible_in_page? ~r/#{button_value}/
    {:ok, state}
  end

  when_ ~r/^I click on sign up$/, fn state  ->
    button_element = find_element(:id, "sign_up_button")
    :timer.sleep(100)
    click button_element
    :timer.sleep(100)
    {:ok, state}
  end

  then_ ~r/^I see an empty registration form$/, fn state ->
    :timer.sleep(250)
    name_field = find_element(:id, "name")
    assert attribute_value(name_field, "value") == ""

    :timer.sleep(250)
    email_field = find_element(:id, "email")
    assert attribute_value(email_field, "value") == ""

    :timer.sleep(250)
    license_plate_field = find_element(:id, "license_plate")
    assert attribute_value(license_plate_field, "value") == ""

    :timer.sleep(250)
    password_field = find_element(:id, "password")
    assert attribute_value(password_field, "value") == ""

    {:ok, state}
  end

  and_ ~r/^my name is "(?<name>[^"]+)", email "(?<email>[^"]+)", license plate "(?<license_plate>[^"]+)" and desired password "(?<password>[^"]+)"$/,
       fn state, %{name: name, email: email,license_plate: license_plate,password: password} ->
         {:ok, state |> Map.put(:name, name)
               |> Map.put(:license_plate, license_plate)
               |> Map.put(:password, password)}
       end

  and_ ~r/^my name is "(?<name>[^"]+)", wrong email "(?<email>[^"]+)", license plate "(?<license_plate>[^"]+)" and desired password "(?<password>[^"]+)"$/,
       fn state, %{name: name, wrong_email: email,license_plate: license_plate,password: password} ->
         {:ok, state |> Map.put(:name, name)
               |> Map.put(:license_plate, license_plate)
               |> Map.put(:password, password)}
       end

  and_ ~r/^I fill the form with my information$/, fn state ->
    :timer.sleep(100)
    name_field = find_element(:id, "name")
    input_into_field(name_field, state[:name])
    :timer.sleep(100)
    email_field = find_element(:id, "email")
    input_into_field(email_field, state[:email])
    :timer.sleep(100)
    license_plate_field = find_element(:id, "license_plate")
    input_into_field(license_plate_field, state[:license_plate])
    :timer.sleep(100)
    password_field = find_element(:id, "password")
    input_into_field(password_field, state[:password])
    :timer.sleep(100)
    {:ok, state}
  end

  and_ ~r/^click on "(?<Submit>[^"]+)"$/, fn state, %{Submit: submit_button_id} ->
    button_element = find_element(:id, submit_button_id)
    click button_element
    :timer.sleep(100)
    {:ok, state}
  end

  then_ ~r/^I am shown a confirmation of registration$/, fn state ->
    :timer.sleep(100)
    assert visible_in_page? ~r/Please log in/
    {:ok, state}
  end

  ## Login stuff

  given_ ~r/^that I have an account with the following credentials: email "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
         fn state, %{email: email, password: password} ->
           {:ok, state |> Map.put(:email, email) |> Map.put(:password, password)}
         end

  when_ ~r/^I click on sign in$/, fn state ->
    button_element = find_element(:id, "sign_in_button")
    :timer.sleep(100)
    click button_element
    :timer.sleep(100)
    {:ok, state}
  end

  and_ ~r/^enter the credentials$/, fn state ->
    :timer.sleep(500)
    email_field = find_element(:id, "email")
    input_into_field(email_field, state[:email])
    :timer.sleep(500)
    password_field = find_element(:id, "password")
    input_into_field(password_field, state[:password])
    :timer.sleep(250)
    {:ok, state}
  end

  and_ ~r/^I triple double quadruple check their correctness$/, fn state ->

    :timer.sleep(100)
    email_field = find_element(:id, "email")
    assert attribute_value(email_field, "value") == state[:email]

    :timer.sleep(100)
    password_field = find_element(:id, "password")
    assert attribute_value(password_field, "value") == state[:password]

    {:ok, state}
  end

  then_ ~r/^I am logged into my account$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Welcome #{state[:email]}/
    :timer.sleep(250)
    {:ok, state}
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

  and_ ~r/^I have the application open$/, fn state ->
    navigate_to "/"
    {:ok, state}
  end

  and_ ~r/^I see the button Log Out$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Log Out/
    :timer.sleep(500)
    {:ok, state}
  end

  when_ ~r/^I click on the button Log out$/, fn state ->
    :timer.sleep(250)
    button_element = find_element(:id, "logout_button")
    :timer.sleep(250)
    click button_element
    :timer.sleep(250)
    {:ok, state}
  end

  then_ ~r/^I am logged out of my account$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Fine, leave then./
    :timer.sleep(500)
    {:ok, state}
  end

  then_ ~r/^I am shown a confirmation of not registration$/, fn state ->

    :timer.sleep(500)
    assert visible_in_page? ~r/Oops, something went wrong! Please check the errors below./
    {:ok, state}
  end

  then_ ~r/^I am shown a confirmation of unsuccessful log-in$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Bad Credentials/
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
    #IO.inspect search_button, label: "is it here"
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

  then_ ~r/^I should see the estimated hourly fee$/, fn state ->

    # Hourly price for B

    assert visible_in_page? ~r/100/

    # Hourly price for A

    assert visible_in_page? ~r/200/

    {:ok, state}

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

  then_ ~r/^I should see the estimated real-time fee$/, fn state ->
    # Real-time price for B

    assert visible_in_page? ~r/96/

    # Real-time price for A

    assert visible_in_page? ~r/192/

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

  and_ ~r/^select real-time$/, fn state ->
    :timer.sleep(250)

    yes_element = find_element(:id, "no")

    click yes_element

    {:ok, state}
  end

  and_ ~r/^I see the booking on "(?<spot>[^"]+)"$/, fn state, %{spot: spot} ->

    :timer.sleep(1500)
    assert visible_in_page? ~r/Vabriku/
    {:ok, state}

  end

  then_ ~r/^I click on "(?<argument_one>[^"]+)"$/, fn state, %{argument_one: _argument_one} ->

    extend = find_element(:id, "Extend")

    :timer.sleep(500)

    click extend

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

  ### Wallet

  and_ ~r/^it takes me to the wallet form$/, fn state ->
    :timer.sleep(250)

    assert visible_in_page? ~r/Wallet index!/

    {:ok, state}
  end

  then_ ~r/^I add "(?<manyie>[^"]+)" cents to my wallet$/,
        fn state, %{manyie: manyie} ->

          hour_element = find_element(:id, "amount")
          input_into_field(hour_element, manyie)

          :timer.sleep(500)

          submit_button = find_element(:id, "Submit")
          click submit_button

          :timer.sleep(500)

          {:ok, state}
        end

  and_ ~r/^I get a confirmation of adding "(?<manyie>[^"]+)" cents$/,
       fn state, %{manyie: manyie} ->

         assert visible_in_page? ~r/Successfully added #{manyie} cents/

         {:ok, state}
       end

  and_ ~r/^I see an invoice showing "(?<money>[^"]+)" cents$/,
       fn state, %{money: money} ->

         assert visible_in_page? ~r/#{money}/

         {:ok, state}
       end

  when_ ~r/^I click to "(?<book_button>[^"]+)"$/,
        fn state, %{book_button: book_button} ->

          :timer.sleep(1000)

          book_element = find_element(:id, book_button)

          IO.inspect book_element, label: "book element"

          :timer.sleep(1000)

          click book_element

          :timer.sleep(1000)

          {:ok, state}
        end

end