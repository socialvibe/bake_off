defmodule BakeOff.PieController do
  use BakeOff.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", pies: BakeOff.Pies.get_all
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    # this should go in a model module but I'm not sure how to create
    # one properly without any db connections since everything I see
    # is based off of Ectp
    { pie_id_int, _ } = Integer.parse(pie_id)
    pie = BakeOff.Server.get(pie_id_int)
    # do redis stuff
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
    json conn, %{
      username: params["username"],
      budget: params["budget"],
      labels: params["labels"]
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
