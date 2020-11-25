alias ParkingProject.Repo
alias ParkingProject.UserManagement.User

alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking}


User.changeset(%User{},
        %{name: "RUcy",
          email: "bruno98@ut.ee",
          password: "parool",
          license_plate: "666SATYR"}) |> Repo.insert()


[%{spot: "Vabriku", category: "B", places: 3, latitude: 58.37681, longitude: 26.70399},
%{spot: "Lossi", category: "A", places: 30, latitude: 58.37927, longitude: 26.71754},
%{spot: "Jakobi", category: "A", places: 50, latitude: 58.38237, longitude: 26.71489}]
|> Enum.map(fn parking_data -> Parking.changeset(%Parking{}, parking_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)



        