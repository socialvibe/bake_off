defmodule BakeOff.PieView do
  use BakeOff.Web, :view
  alias BakeOff.Pie

  def get_href(pie), do: "http://localhost:4000/pies/#{pie["id"]}"

  def get_price(pie), do: "$#{pie["price_per_slice"]}"

  def remaining_slices(pie) do
    Pie.remaining_slices(pie)
  end

  def buyers_map(pie) do
    Pie.buyers_map(pie)
  end

  def render("show.json", params) do
    params.pie
  end
end
