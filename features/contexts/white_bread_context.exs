defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers

  alias ParkingProject.{Repo}
  alias ParkingProject.UserManagement.User

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

  given_ ~r/^that I am near "(?<location>[^"]+)"$/,
         fn state, %{location: _location} ->
           {:ok, state}
         end

  and_ ~r/^about to park$/, fn state ->
    {:ok, state}
  end

  then_ ~r/^I should go to the website first$/, fn state ->
    {:ok, state}
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

  and_ ~r/^I see the button Log out$/, fn state ->
    :timer.sleep(500)
    assert visible_in_page? ~r/Log out/
    :timer.sleep(500)
    {:ok, state}
  end

  when_ ~r/^I click on the button Log out$/, fn state ->
    {:ok, state}
  end

end