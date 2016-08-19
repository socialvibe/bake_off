defmodule BakeOff.Pies do
  use GenServer

  @s3 Application.fetch_env!(:bake_off, :s3)

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def get_all do
    GenServer.call(__MODULE__, :get_all)
  end

  def get(id) do
    pie = GenServer.call(__MODULE__, :get)
      |> Map.get(id)
    if pie do # TODO: if/else code smell
      { :ok, pie }
    else
      { :error }
    end
  end

  # GenServer callbacks
  def init(_) do
  #  { :ok, %{ body: pie_json } } = HTTPoison.get(@s3)
  #  pies = Poison.Parser.parse!(pie_json)
  #    |> Map.get("pies")
  pies = [%{"id" => 1,
   "image_url" => "http://stash.truex.com/tech/bakeoff/apple_pie.jpg",
   "labels" => ["vegetarian", "vegan", "sweet"], "name" => "Apple Pie",
   "price_per_slice" => 1.5, "slices" => 10},
 %{"id" => 2,
   "image_url" => "http://stash.truex.com/tech/bakeoff/pecan_pie.jpg",
   "labels" => ["vegetarian", "vegan", "sweet"], "name" => "Pecan Pie",
   "price_per_slice" => 2.25, "slices" => 14},
 %{"id" => 3,
   "image_url" => "http://stash.truex.com/tech/bakeoff/shepherds_pie.jpg",
   "labels" => ["gluten_free", "savory"], "name" => "Shepherd's Pie",
   "price_per_slice" => 8.95, "slices" => 8}]

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
