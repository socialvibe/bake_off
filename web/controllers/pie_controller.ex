defmodule BakeOff.PieController do
  use BakeOff.Web, :controller
  alias BakeOff.Pie
  alias BakeOff.Pies

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
          { :json, { :error } } ->
            conn |> put_status(:not_found) |> json %{error: "not found"}
        end
    end
  end

  def purchases(conn, params) do
    validate_required_parameters(conn, ["username", "amount", "slices"])
    case Pie.purchase(params) do
      { :ok, response } ->
        conn |> send_resp(response, "")
      { :error, response, message } ->
        conn |> put_status(response) |> json(%{error: message})
    end
  end

  def recommend(conn, params) do
    validate_required_parameters(conn, ["username"])
    labels = String.split(to_string(params["labels"]), ",")
    username = params["username"]
    budget = params["budget"]

    candidates = Pies.get_all
      |> Enum.filter(fn(pie) -> Pie.has_labels?(pie, labels) end)
      |> Enum.reject(fn(pie) -> Pie.unavailable?(pie, username) end)

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
