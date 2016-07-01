defmodule BakeOff.PieController do
  use BakeOff.Web, :controller
  alias BakeOff.Pie
  alias BakeOff.Pies

  def index(conn, _params) do
    render conn, "index.html", pies: BakeOff.Pies.get_all
  end

  # for the record, elixir style says this route should be
  # /api/pies/<id> rather than /pies/<id>.json. That is why this
  # is so gross looking.
  def show(conn, %{ "format" => "json", "pie_id" => pie_id }) do
    pie_response = Path.rootname(pie_id)
    |> String.to_integer
    |> Pies.get

    case pie_response do
      { :ok, pie } ->
        json conn, pie
      { :error } ->
        render_404(conn)
    end
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    # this should go in a model module but I'm not sure how to create
    # one properly without any db connections since everything I see
    # is based off of Ectp
    pie_response = pie_id
    |> String.to_integer # TODO: breaks if not integer
    |> Pies.get

    case pie_response do
      { :ok, pie } ->
        render conn, :show, pie: pie # works for /api/pies/<id> too!
      { :error } ->
        render_404(conn)
    end
  end

  def purchases(conn, params) do
    case Pie.purchase(params) do
      { :ok, response } -> conn |> send_resp(response, "")
      { :error, response } -> conn |> send_resp(response, "")
    end
  end

  def recommend(conn, params) do
    # TODO: better validation
    labels = String.split(to_string(params["labels"]), ",")
    username = params["username"]
    budget = params["budget"]

    candidates = Pies.get_all
      |> Enum.filter(fn(pie) -> BakeOff.Pie.has_labels?(pie, labels) end)
      |> Enum.reject(fn(pie) -> BakeOff.Pie.unavailable?(pie, username) end)

    chosen = case budget do
      "cheap" -> List.first(candidates)
      "premium" -> List.last(candidates)
      _ -> List.first(candidates) # TODO:  actually raise an error
    end

    json conn, %{
      pie_url: chosen # TODO: route helper for generating /pies/42
    }
  end

  defp render_404(conn) do
    conn
    |> put_status(:not_found)
    |> render(BakeOff.ErrorView, "404.html")
  end
end
