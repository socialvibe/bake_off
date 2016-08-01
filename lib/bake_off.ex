defmodule BakeOff do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Create the redix children list of workers:
    pool_size = 50
    redix_workers = for i <- 0..(pool_size - 1) do
      worker(Redix, [[], [name: :"redix_#{i}"]], id: {Redix, i})
    end

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BakeOff.Endpoint, []),

      # Start and supervise the Pies GenServer
      worker(BakeOff.Pies, [])

      # Start your own worker by calling: BakeOff.Worker.start_link(arg1, arg2, arg3)
      # worker(BakeOff.Worker, [arg1, arg2, arg3]),
    ] ++ redix_workers

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BakeOff.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BakeOff.Endpoint.config_change(changed, removed)
    :ok
  end
end
