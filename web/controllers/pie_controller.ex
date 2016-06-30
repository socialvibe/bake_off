defmodule BakeOff.PieController do
  use BakeOff.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    render conn, "show.html", pie_id: pie_id 
  end
end
