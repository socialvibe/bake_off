defmodule BakeOff.Pies do
  use GenServer

  @s3 Application.fetch_env!(:bake_off, :s3)

  # API
  def start_link do
    {:ok, _pid} = GenServer.start_link(__MODULE__, nil, name: name)
  end

  def start do
    GenServer.start(__MODULE__, nil, name: name)
  end

  def get_all do
    case :ets.lookup(:pies_table, "sorted") do
      [{"sorted", sorted_pie_list}] -> sorted_pie_list
      [] -> :error
    end
  end

  def get(id) do
    case :ets.lookup(:pies_table, "indexed") do
      [] -> {:error}
      [{"indexed", pie_map}] -> get_pie_by_id(pie_map, id)
    end
  end

  # GenServer callbacks
  def init(_) do
    { :ok, %{ body: pie_json } } = HTTPoison.get(@s3)
    pies = Poison.Parser.parse!(pie_json)
      |> Map.get("pies")
    sorted = pies
      |> Enum.sort(&(&1["price_per_slice"] < &2["price_per_slice"]))
    indexed = pies
      |> Enum.reduce(%{}, fn(pie, map) -> Map.put(map, pie["id"], pie) end)

    pies_table = :ets.new(:pies_table, [:set, :protected, :named_table, read_concurrency: true])
    :ets.insert(pies_table, {"sorted", sorted})
    :ets.insert(pies_table, {"indexed", indexed})

    { :ok, %{ pie_map: indexed, sorted_pie_list: sorted, pies_ets: pies_table } }
  end

  defp name do
    BakeOff.Pies
  end

  defp get_pie_by_id(pie_map, id) do
    pie = Map.get(pie_map, id)
    if pie do # TODO: if/else code smell
      { :ok, pie }
    else
      { :error }
    end
  end
end
