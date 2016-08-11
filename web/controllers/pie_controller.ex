defmodule BakeOff.PieController do
  use BakeOff.Web, :controller
  alias BakeOff.Pie
  alias BakeOff.Pies

  @pies [%{"id" => 1,
   "image_url" => "http://stash.truex.com/tech/bakeoff/apple_pie.jpg",
   "labels" => ["vegetarian", "vegan", "sweet"], "name" => "Apple Pie",
   "price_per_slice" => 1.5, "slices" => 10},
 %{"id" => 2,
   "image_url" => "http://stash.truex.com/tech/bakeoff/pecan_pie.jpg",
   "labels" => ["vegetarian", "vegan", "sweet"], "name" => "Pecan Pie",
   "price_per_slice" => 2.25, "slices" => 14},
 %{"id" => 3,
   "image_url" => "http://stash.truex.com/tech/bakeoff/shepherds_pie.jpg",
   "labels" => ["gluten_free", "savory"], "name" => "Shepherd's Pie",
   "price_per_slice" => 8.95, "slices" => 8}]

  @sorted  @pies |> Enum.sort(&(&1["price_per_slice"] < &2["price_per_slice"]))

  @indexed  @pies |> Enum.reduce(%{}, fn(pie, map) -> Map.put(map, pie["id"], pie) end)

  def index(conn, _params) do
    render conn, "index.html", pies: BakeOff.Pies.get_all
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    case get_id_and_format(pie_id) do
      { :error } ->
        render_404(conn)
      { format, id } ->
        pie_response = id
        |> String.to_integer
        |> Pies.get

        case { format, pie_response } do
          { :html, { :ok, pie } } -> render conn, :show, pie: pie
          { :json, { :ok, pie } } -> json conn, pie_json(pie)
          { :html, { :error } } -> render_404(conn)
          { :json, { :error } } -> render_404_json(conn)
        end
    end
  end

  def purchases(conn, params) do
    validate_required_parameters(conn, ["username", "amount", "slices"])
    case Pie.purchase(params) do
      { :ok, response } -> conn |> send_resp(response, "")
      { :error, :not_found } -> render_404_json(conn)
      { :error, response, message } ->
        conn |> put_status(response) |> json(%{error: message})
    end
  end

  def recommend(conn, params) do
    validate_required_parameters(conn, ["username"])
    labels = String.split(to_string(params["labels"]), ",")
    username = params["username"]
    budget = params["budget"] || "cheap"

    candidates = @sorted
      |> Stream.filter(fn(pie) -> Pie.has_labels?(pie, labels) end)
      |> Stream.reject(fn(pie) -> Pie.unavailable?(pie, username) end)

    chosen = case budget do
      "cheap" -> Enum.at(candidates, 0)
      "premium" -> Enum.at(candidates, -1)
    end

    if chosen == nil do
      render_404_json(conn)
    else
      json conn, %{ pie_url: pie_url(conn, :show, chosen["id"]) }
    end
  end

  defp render_404(conn) do
    conn
    |> put_status(:not_found)
    |> render(BakeOff.ErrorView, "404.html")
  end

  defp render_404_json(conn) do
    error_message = """
    Sorry we don’t have what you’re looking for.
    Come back early tomorrow before the crowds come from the best pie selection.
    """
    conn |> put_status(:not_found) |> json(%{error: error_message})
  end

  defp get_id_and_format(pie_id) do
    case Regex.run(~r/\A([0-9]+)(\.json)?\z/, pie_id) do
      nil ->
        { :error }
      [_, id, ".json" | _ ] ->
        { :json, id }
      [_, id | _] ->
        { :html, id }
    end
  end

  defp pie_json(pie) do
    %{
      name: pie["name"],
      image_url: pie["image_url"],
      price_per_slice: pie["price_per_slice"],
      remaining_slices: Pie.remaining_slices(pie),
      purchases: Pie.buyers_map(pie)
    }
  end

  defp validate_required_parameters(conn, required_list) do
    try do
      Enum.each(required_list, fn(required_param) -> scrub_params(conn, required_param) end)
    rescue
      Phoenix.MissingParamError ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing required parameters"})
    end
  end
end
