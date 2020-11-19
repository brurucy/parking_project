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

  then_ ~r/^I see the button "(?<button_value>[^"]+)"$/,
        fn state, %{button_value: button_value} ->
          {:ok, state}
        end

end