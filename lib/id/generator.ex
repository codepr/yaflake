defmodule Yaflake.ID.Generator do
  @moduledoc false

  alias Yaflake.ID

  @type state :: %{
          epoch: non_neg_integer(),
          worker_id: non_neg_integer(),
          timestamp: non_neg_integer(),
          seq: non_neg_integer()
        }

  @spec new_state(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: state()
  def new_state(epoch, worker_id, seq),
    do: %{epoch: epoch, worker_id: worker_id, timestamp: timestamp(epoch), seq: seq}

  @spec generate(state()) :: {:ok, ID.t(), state()} | {:error, atom()}
  def generate(%{epoch: epoch, worker_id: worker_id, timestamp: prev_timestamp, seq: seq} = state) do
    case next_timestamp(epoch, prev_timestamp, seq) do
      {:ok, new_timestamp, new_seq} ->
        id = generate_id(worker_id, new_timestamp, new_seq)
        {:ok, id, %{state | timestamp: new_timestamp, seq: new_seq}}

      error ->
        error
    end
  end

  defp generate_id(worker_id, timestamp, seq), do: ID.generate(worker_id, timestamp, seq)

  defp next_timestamp(epoch, previous_timestamp, seq) do
    case timestamp(epoch) do
      ^previous_timestamp ->
        if seq + 1 >= ID.max_seq_number(),
          do: {:error, :max_seq_reached},
          else: {:ok, previous_timestamp, seq + 1}

      past_timestamp when past_timestamp < previous_timestamp ->
        {:error, :backward_time}

      new_timestamp ->
        {:ok, new_timestamp, 0}
    end
  end

  defp timestamp(epoch), do: :os.system_time(:milli_seconds) - epoch
end
