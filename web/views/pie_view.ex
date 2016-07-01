defmodule BakeOff.PieView do
  use BakeOff.Web, :view

  def get_href(pie), do: "http://localhost:4000/pies/#{pie["id"]}"

  def get_price(pie), do: "$#{pie["price_per_slice"]}"

  # TODO: subtract slices already eaten
  def get_slices(pie), do: pie["slices"]
end

