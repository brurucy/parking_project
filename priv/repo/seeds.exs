alias ParkingProject.Repo
alias ParkingProject.UserManagement.User

alias ParkingProject.ParkingSpace.{Booking, Allocation, Parking, ParkingFee}
alias ParkingProject.PaymentManagement.Wallet


bruno = User.changeset(%User{},
  %{name: "RUcy",
    email: "bruno98@ut.ee",
    password: "parool",
    license_plate: "666SATYR"}) |> Repo.insert()

fee_a =  %ParkingFee{}
         |> ParkingFee.changeset(%{category: "A", pph: 2, ppfm: 16})
         |> Repo.insert!

fee_b = %ParkingFee{}
        |> ParkingFee.changeset(%{category: "B", pph: 1, ppfm: 8})
        |> Repo.insert!

[%{spot: "Vabriku 1", parking_fee_id: fee_a.id, places: 3, latitude: 58.37681, longitude: 26.70399},
%{spot: "Lossi 21", parking_fee_id: fee_b.id, places: 30, latitude: 58.37927, longitude: 26.71754},
%{spot: "Jakobi 2", parking_fee_id: fee_b.id, places: 0, latitude: 58.38237, longitude: 26.71489}]
|> Enum.map(fn parking_data -> Parking.changeset(%Parking{}, parking_data) end)
|> Enum.each(fn changeset -> Repo.insert!(changeset) end)

Wallet.changeset(%Wallet{}, %{user_id: 1, amount: 3333333}) |> Repo.insert()






        