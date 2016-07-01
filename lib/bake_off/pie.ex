defmodule BakeOff.Pie do
  def has_labels?(pie, labels) do
    Enum.all?(labels, fn(label) -> Enum.member?(pie["labels"], label) end)
  end

  def unavailable?(pie, username) do
    purchases = BakeOff.Purchases.get(pie["id"])
    consumed_slices = Map.values(purchases) |> Enum.sum
    consumed_by_user = purchases[username]

    empty? = pie["slices"] - consumed_slices == 0
    user_stuffed? = consumed_by_user == 3

    empty? || user_stuffed?
  end
end