defmodule BakeOff.Pies do
  use GenServer

  @s3 Application.fetch_env!(:bake_off, :s3)

  # API
  def start do
    GenServer.start(__MODULE__, nil, name: name)
  end

  def get_all do
    GenServer.call(name, :get)
  end

  def get(id) do
    pie = GenServer.call(name, :get)
    |> Enum.find(fn item -> item["id"] == id end)
    if pie do
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
    |> Enum.sort(&(&1["price_per_slice"] < &2["price_per_slice"]))
    { :ok, pies }
  end

  def handle_call(:get, _from, current_state) do
    { :reply, current_state, current_state }
  end

  defp name do
    {:global, :pies}
  end
end
