defmodule BakeOff.PageController do
  use BakeOff.Web, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render(BakeOff.ErrorView, "404.html")
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def hello_world(conn, _params) do
    text conn, "Hello, world!"
  end
end
