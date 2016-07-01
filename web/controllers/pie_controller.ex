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
    pie = String.to_integer(pie_id)
    |> BakeOff.Pies.get

    render(conn, "show.html", pie: pie)
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

    candidates = Pies.get_all # TODO: sorted by price per pie
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

  defp as_json(pie) do
    %{
      name: "pie #{pie}",
      image_url: "http://imgur.com/#{pie}",
      price_per_slice: "$1",
      remaining_slices: 10,
      purchases: [%{ user_name: "nathan", slices: 1 }]
    }
  end
end
