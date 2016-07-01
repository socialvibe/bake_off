defmodule BakeOff.Server do
  use GenServer

  @s3 Application.fetch_env!(:bake_off, :s3)

  def start do
    { :ok, pid } = GenServer.start(__MODULE__, nil)
    pid
  end

  def get_all(pid) do
    GenServer.call(pid, :get)
  end

  def get(pid, id) do
    GenServer.call(pid, :get)
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
end
