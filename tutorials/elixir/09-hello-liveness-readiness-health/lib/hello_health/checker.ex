defmodule HelloHealth.Checker do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def check_all do
    GenServer.call(__MODULE__, :check_all)
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  def set_dependency(name, status) when status in [:ok, :error] do
    GenServer.call(__MODULE__, {:set_dependency, name, status})
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    {:ok, %{database: :ok, cache: :ok}}
  end

  @impl true
  def handle_call(:check_all, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:status, _from, state) do
    result =
      if Enum.all?(state, fn {_k, v} -> v == :ok end),
        do: :ok,
        else: :degraded

    {:reply, result, state}
  end

  def handle_call({:set_dependency, name, status}, _from, state) do
    new_state = Map.put(state, name, status)
    {:reply, :ok, new_state}
  end
end
