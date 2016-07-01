defmodule BakeOff.Server do
  use GenServer

  @s3 Application.fetch_env!(:bake_off, :s3)

  def start do
    GenServer.start(__MODULE__, nil, name: name)
  end

  def get_all do
    GenServer.call(name, :get)
  end

  def get(id) do
    GenServer.call(name, :get)
    |> Enum.find(fn item -> item["id"] == id end)
  end

  # GenServer callbacks
  def init(_) do
    { :ok, %{ body: pie_json } } = HTTPoison.get(@s3)
    { :ok, Map.get(Poison.Parser.parse!(pie_json), "pies") }
  end

  def handle_call(:get, _from, current_state) do
    { :reply, current_state, current_state }
  end

  defp name do
    {:global, :server}
  end
end
