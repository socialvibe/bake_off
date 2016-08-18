defmodule BakeOff.PieController do
  use BakeOff.Web, :controller
  alias BakeOff.Pie
  alias BakeOff.Pies

  def index(conn, _params) do
    render conn, "index.html", pies: Pies.get_all
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    get_id_and_format(pie_id)
    |> render_response(conn)
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

    candidates = Pies.get_all
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

  defp render_response({ :error }, conn) do
    render_404(conn)
  end

  defp render_response({ format, id }, conn) do
    pie_response = id |> String.to_integer |> Pies.get
    render_pie(format, pie_response, conn)
  end

  defp render_pie(:html, { :ok, pie }, conn) do
    render conn, :show, pie: pie
  end

  defp render_pie(:html, { :error }, conn) do
    render_404(conn)
  end

  defp render_pie(:json, { :ok, pie }, conn) do
    json conn, pie_json(pie)
  end

  defp render_pie(:json, { :error }, conn) do
    conn |> put_status(:not_found) |> json(%{ error: "not found" })
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
