defmodule Yaflake do
  @moduledoc """
  Yaflak - Yet Another Flake is a library to generate decentralized, unique and
  sortable by time 64 bits IDs
  """

  @doc """
  Hello world.

  ## Examples

      iex(1)> Yaflake.generate()
      {:ok, 3918968889032704}
      iex(2)> Yaflake.sequence_number(3918968889032704)
      0
      iex(3)> Yaflake.machine_id(3918968889032704)
      68
      iex(4)> Yaflake.timestamp(3918968889032704)
      1673802809291
      iex(5)> Yaflake.internal_timestamp(3918968889032704)
      934354994
  """
  use Application

  alias Yaflake.ID
  alias Yaflake.Worker

  @impl true
  def start(_type, _args) do
    Yaflake.Supervisor.start_link([])
  end

  defdelegate generate, to: Worker
  defdelegate sequence_number(id), to: ID
  defdelegate machine_id(id), to: ID
  defdelegate timestamp(id), to: ID
  defdelegate internal_timestamp(id), to: ID
end
