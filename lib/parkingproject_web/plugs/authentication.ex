defmodule ParkingProject.Authentication do
  import Plug.Conn
  alias ParkingProject.Guardian

  def check_credentials(user, plain_text_password) do
    if user && Pbkdf2.verify_pass(plain_text_password, user.hashed_password) do
      {:ok, user}
    else
      IO.inspect plain_text_password
      IO.inspect user.hashed_password
      {:error, :unauthorized_user}
    end
  end

  def login(conn, user) do
    Guardian.Plug.sign_in(conn, user)
  end

  def logout(conn) do
    Guardian.Plug.sign_out(conn)
  end

  def load_current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end


end
