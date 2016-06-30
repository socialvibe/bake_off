defmodule BakeOff.PageController do
  use BakeOff.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
