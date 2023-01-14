defmodule Yaflake.ID do
  @moduledoc false

  import Bitwise

  @type t :: non_neg_integer()

  # 2022/04/01 21:41
  @epoch 1_672_868_454_297
  @yaflake_id_size 64
  @timestamp_bits 42
  @sequence_bits 12
  @machine_id_bits @yaflake_id_size - @timestamp_bits - @sequence_bits
  @max_seq_number (1 <<< @sequence_bits) - 1

  @spec epoch() :: non_neg_integer()
  def epoch, do: @epoch

  @spec max_seq_number() :: non_neg_integer()
  def max_seq_number, do: @max_seq_number

  @spec generate(
          worker_id :: non_neg_integer(),
          timestamp :: non_neg_integer(),
          seq :: non_neg_integer()
        ) :: t()
  def generate(worker_id, timestamp, seq) do
    timestamp
    |> Bitwise.<<<(@machine_id_bits + @sequence_bits)
    |> Bitwise.|||(worker_id <<< @sequence_bits)
    |> Bitwise.|||(seq)
  end

  @doc """
  Returns milliseconds passed since epoch when ID was generated.
  """
  @spec internal_timestamp(t()) :: non_neg_integer()
  def internal_timestamp(id), do: id >>> 22

  @spec timestamp(t()) :: non_neg_integer()
  def timestamp(id) do
    internal_timestamp(id) + @epoch
  end

  # starts at @sequence_bits
  @spec machine_id(t()) :: non_neg_integer()
  def machine_id(id) do
    (1 <<< @machine_id_bits) - 1 &&& id >>> @sequence_bits
  end

  @spec sequence_number(t()) :: non_neg_integer()
  def sequence_number(id) do
    mask_machine_id = (1 <<< @sequence_bits) - 1
    id &&& mask_machine_id
  end

  @spec deconstruct(t()) :: %{
          timestamp: non_neg_integer(),
          seq: non_neg_integer(),
          machine_id: non_neg_integer()
        }
  def deconstruct(id) do
    %{
      timestamp: timestamp(id),
      seq: sequence_number(id),
      machine_id: machine_id(id)
    }
  end
end
