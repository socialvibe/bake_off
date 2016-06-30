defmodule BakeOff.PieController do
  use BakeOff.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{ "pie_id" => pie_id }) do
    # there's almost definitely a better way to do this.
    # unfortunately, pattern matching on string concatenation
    # doesn't allow for the unkown bit to be at the beginning
    # e.g. %{ "pie_id" => pie_id <> ".json" } won't work,
    # and you can't use ends_with?/2 in a guard, e.g.
    # def show(conn %{ "pie_id" => pie_id }) when ends_with?(pie_id, ".json") do
    # anyway, this works for responding to pie_id and pie_id.json
    # for now.
    match = Regex.run(~r/(.+)\.json/, pie_id)
    if is_nil(match) do
      render conn, "show.html", pie_id: pie_id
    else
      [_|[id]] = match
      json conn, as_json(id)
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
