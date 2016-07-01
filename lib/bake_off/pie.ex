defmodule BakeOff.Pie do
  alias BakeOff.Purchases
  alias BakeOff.Pies

  def has_labels?(pie, labels) do
    Enum.all?(labels, fn(label) -> Enum.member?(pie["labels"], label) end)
  end

  def unavailable?(pie, username) do
    purchases = Purchases.get(pie["id"])
    consumed_slices = Map.values(purchases) |> Enum.sum
    consumed_by_user = purchases[username]

    empty? = pie["slices"] - consumed_slices == 0
    user_stuffed? = consumed_by_user == 3

    empty? || user_stuffed?
  end

  def purchase(params) do
    pie_response = String.to_integer(params["pie_id"])
    |> Pies.get

    case pie_response do
      { :error } ->
        { :error, :not_found }
      { :ok, pie } ->
        attempt_purchase(pie, params)
    end
  end

  defp attempt_purchase(pie, params) do
    buyer = params["username"]
    slices_to_buy = String.to_integer(params["slices"])
    bought_slices = Purchases.get(pie["id"])[buyer]

    cond do
      bought_slices >= 3 ->
        { :error, :too_many_requests }
      pie["slices"] - slices_to_buy < 0 ->
        { :error, :gone }
      true ->
        Purchases.store(pie["id"], buyer, slices_to_buy)
        { :ok, :created }
    end
  end
end
