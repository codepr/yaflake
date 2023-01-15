defmodule Yaflake.Worker do
  @moduledoc false

  use GenServer
  alias Yaflake.ID
  alias Yaflake.ID.Generator
  alias Yaflake.Node.MachineID

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def generate do
    GenServer.call(__MODULE__, :generate_id)
  end

  @impl true
  def init(opts) do
    epoch = Keyword.get(opts, :epoch, ID.epoch())
    worker_id = Keyword.get(opts, :worker_id, MachineID.generate())

    with :ok <- MachineID.validate!(worker_id) do
      {:ok, Generator.new_state(epoch, worker_id, 0)}
    end
  end

  @impl true
  def handle_call(:generate_id, from, state) do
    case Generator.generate(state) do
      {:ok, id, new_state} ->
        {:reply, {:ok, id}, new_state}

      {:error, :backward_time} = error ->
        {:reply, error, state}

      {:error, :max_seq_reached} ->
        :timer.sleep(1)
        handle_call(:generate_id, from, state)
    end
  end
end
