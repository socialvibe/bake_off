defmodule BakeOff.Purchases do
  def store(pie_id, username, slices \\ 1) do
    # Redis hash:
    #  - hash name is the pie_id
    #  - the keys are the usernames
    #  - the values are the number of slices consumed by each username
    BakeOff.Redix.command(~w(HINCRBY #{pie_id} #{username} #{slices}))
  end

  def get(pie_id) do
    # Example pipeline:
    #   flat_purchases => ["chris", "3", "david", "1"]
    #   => [["chris", "3"], ["david", "1"]]  # Enum.chunk
    #   => [{"chris", "3"}, {"david", "1"}]  # Enum.map
    #   => %{"chris" => "3", "david" => "1"} # Enum.into
    {:ok, flat_purchases} = BakeOff.Redix.command(~w(HGETALL #{pie_id}))
    Enum.chunk(flat_purchases, 2)
      |> Enum.map(fn([x,y]) -> {x,y} end)
      |> Enum.into(%{})
  end
end