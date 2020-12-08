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

  import_steps_from PartThreeContext

  IO.inspect "oim erre", label: "Should be here first"
  :timer.sleep(5000)

  import_steps_from PartTwoContext
  IO.inspect "oim erre", label: "Should be here second"

  :timer.sleep(5000)

  IO.inspect "oim erre", label: "Should be here third"
  import_steps_from PartOneContext

end