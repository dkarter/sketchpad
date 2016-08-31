defmodule Sketchpad.PageController do
  use Sketchpad.Web, :controller

  plug :require_user when not action in [:signin]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def signin(conn, %{"user" => %{"username" => user_id}})
    when not user_id in ["", nil] do

    conn
    |> put_session(:user_id, user_id)
    |> redirect(to: page_path(conn, :index))
  end

  def signin(conn, _) do
    conn
    |> put_flash(:error, "Please provide a username")
    |> redirect(to: page_path(conn, :index))
  end

  defp require_user(conn, _) do
    if user_id = get_session(conn, :user_id) do
      # caveat there is no way to expire all issued tokens
      token = Phoenix.Token.sign(conn, "crazy random salt", user_id)

      conn
      |> assign(:user_id, user_id) # is this where the cookie is injected??
      |> assign(:user_token, token) # is this where the cookie is injected??
      
    else
      conn
      |> put_flash(:info, "Heyy, signin")
      |> render("signin.html")
      |> halt()
    end
  end
end
