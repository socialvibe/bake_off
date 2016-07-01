defmodule BakeOff.PieView do
  use BakeOff.Web, :view

  def get_href(pie), do: "http://localhost:4000/pies/#{pie["id"]}"

  def get_price(pie), do: "$#{pie["price_per_slice"]}"

  def remaining_slices(pie) do
    pie["slices"] -
      Enum.reduce(
        BakeOff.Purchases.get(pie["id"]),
        0,
        fn({_k,v}, acc) -> v + acc  end
      )
  end

  def buyers_map(pie) do
    BakeOff.Purchases.get(pie["id"])
  end
end
