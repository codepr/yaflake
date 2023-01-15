defmodule Yaflake.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = [{Yaflake.Worker, opts}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
