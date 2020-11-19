alias ParkingProject.Repo
alias ParkingProject.UserManagement.User

bruno = User.changeset(%User{},
        %{name: "RUcy",
          email: "bruno98@ut.ee",
          password: "parool",
          license_plate: "666SATYR"})
        |> Repo.insert!