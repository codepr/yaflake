defmodule Yaflake.ID.GeneratorTest do
  @moduledoc false
  use ExUnit.Case, async: false
  import Mox, only: [stub: 3]

  alias Yaflake.ID
  alias Yaflake.ID.Generator
  alias Yaflake.Node.InterfaceMock

  setup do
    stub(InterfaceMock, :getifaddrs, fn -> [en1: [100, 86, 99, 156, 204, 19]] end)
    :ok
  end

  describe "generate/1" do
    test "generates a new initial state" do
      epoch = 100_000
      worker_id = 150
      seq = 0

      assert %{epoch: ^epoch, worker_id: ^worker_id, seq: ^seq} =
               Generator.new_state(epoch, worker_id, seq)
    end

    test "generates a valid ID" do
      epoch = 1_672_868_454_297
      timestamp = 1_673_799_643_095 - epoch
      expected_seq = 0
      expected_worker_id = 15

      assert {:ok, id,
              %{
                epoch: ^epoch,
                seq: ^expected_seq,
                worker_id: ^expected_worker_id
              }} =
               Generator.generate(%{epoch: epoch, worker_id: 15, timestamp: timestamp, seq: 0})

      assert %{seq: 0, machine_id: 15} = ID.deconstruct(id)
    end

    test "resets seq number to 0 when a new timestamp is correctly forged" do
      epoch = 1_672_868_454_297
      timestamp = :os.system_time(:milli_seconds) - epoch

      :timer.sleep(1)

      assert {:ok, _id, %{seq: 0}} =
               Generator.generate(%{epoch: epoch, worker_id: 15, timestamp: timestamp, seq: 3989})
    end

    test "returns a backward_time error when the new timestamp is prior to the current" do
      epoch = 1_672_868_454_297
      timestamp = 1_673_799_643_095 + epoch

      assert {:error, :backward_time} =
               Generator.generate(%{epoch: epoch, worker_id: 15, timestamp: timestamp, seq: 0})
    end

    test "returns a max_seq_reached error when the seq overflow occur (maximum number of IDs in a given ms)" do
      epoch = 1_672_868_454_297
      timestamp = :os.system_time(:milli_seconds) - epoch

      assert {:error, :max_seq_reached} =
               Generator.generate(%{epoch: epoch, worker_id: 15, timestamp: timestamp, seq: 4095})
    end
  end
end
