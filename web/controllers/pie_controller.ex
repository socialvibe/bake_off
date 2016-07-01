defmodule BakeOff.PieController do
  use BakeOff.Web, :controller
  alias BakeOff.Pie
  alias BakeOff.Pies

  def index(conn, _params) do
    render conn, "index.html", pies: BakeOff.Pies.get_all
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    # this should go in a model module but I'm not sure how to create
    # one properly without any db connections since everything I see
    # is based off of Ectp
    pie = Path.rootname(pie_id)
    |> String.to_integer
    |> Pies.get # TODO: probably need error handling here (or in Pies)

    case Path.extname(pie_id) do
      ".json" ->
        json conn, pie
      "" ->
        render conn, "show.html", pie: pie # TODO: add purchases to map first
      _ ->
        render conn, "show.html", pie: pie # TODO: 404
    end
  end

  def purchase(conn, params) do
    json conn, %{
      pie_id: params["pie_id"],
      username: params["username"],
      amount: params["amount"],
      slices: params["slices"]
    }
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
end
