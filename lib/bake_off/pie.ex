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
    |> Enum.map(fn({ username, slices }) -> %{ username: username, slices: slices } end)
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
      pie["slices"] - slices_to_buy < 0 ->
        { :error, :gone, "No more of that pie.  Try something else." }
      bought_slices && bought_slices >= 3 ->
        { :error, :too_many_requests, "Gluttony is discouraged." }
      String.to_float(params["amount"]) != (pie["price_per_slice"] * slices_to_buy) ->
        { :error, :payment_required, "You did math wrong." }
      true ->
        Purchases.store(pie["id"], buyer, slices_to_buy)
        { :ok, :created }
    end
  end
end
