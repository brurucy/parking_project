defmodule ParkingProjectWeb.ParkingFee do

  alias Parkingproject.PaymentManagement.Invoice
  alias ParkingProject.ParkingSpace.Booking
  alias ParkingProject.Repo
  alias Ecto.Changeset


  def issueInvoice(booking_id, amount) do

    # I wanted to calculate the amount here in this function, but I need 'startDate' and
    # 'endDate' defined in Booking table. Since I'm working in another branch these fields
    # has been defined in 'parking_space' branch. So, the only way for me is receiving the
    # 'amount' and save it in the 'invoice' table! :( so I think this function is kind of useless

    bookingObject = Repo.get!(Booking, booking_id)

    invoice_changeset = %Invoice{}
        |> Invoice.changeset(%{amount: amount})
        |> Changeset.put_change(:booking, bookingObject)

    Repo.insert(invoice_changeset)

  end

end
