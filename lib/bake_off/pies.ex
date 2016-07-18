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
    GenServer.call(name, :get_all)
  end

  def get(id) do
    pie = GenServer.call(name, :get)
      |> Map.get(id)
    if pie do # TODO: if/else code smell
      { :ok, pie }
    else
      { :error }
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

    { :ok, %{ pie_map: indexed, sorted_pie_list: sorted } }
  end

  def handle_call(:get, _from, state) do
    { :reply, state.pie_map, state }
  end

  def handle_call(:get_all, _from, state) do
    { :reply, state.sorted_pie_list, state }
  end

  defp name do
    BakeOff.Pies
  end
end
