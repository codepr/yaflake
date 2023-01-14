defmodule Yaflake.IDTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Yaflake.ID

  describe "ID feature" do
    test "generates a new ID" do
      worker_id = 21
      sequence_number = 67
      timestamp = 168_989
      assert 708_791_324_739 = ID.generate(worker_id, timestamp, sequence_number)
    end

    test "generates a new ID that can be deconstructed succesfully" do
      worker_id = 21
      sequence_number = 67
      timestamp = 168_989
      expected_timestamp = timestamp + ID.epoch()
      id = ID.generate(worker_id, timestamp, sequence_number)

      assert %{machine_id: ^worker_id, seq: ^sequence_number, timestamp: ^expected_timestamp} =
               ID.deconstruct(id)
    end

    test "can extract sequence number succesfully from an ID" do
      worker_id = 21
      sequence_number = 67
      timestamp = 168_989
      id = ID.generate(worker_id, timestamp, sequence_number)

      assert ^sequence_number = ID.sequence_number(id)
    end

    test "can extract machine ID succesfully from an ID" do
      worker_id = 21
      sequence_number = 67
      timestamp = 168_989
      id = ID.generate(worker_id, timestamp, sequence_number)

      assert ^worker_id = ID.machine_id(id)
    end

    test "can extract timestamp succesfully from an ID" do
      worker_id = 21
      sequence_number = 67
      timestamp = 168_989
      expected_timestamp = timestamp + ID.epoch()
      id = ID.generate(worker_id, timestamp, sequence_number)

      assert ^expected_timestamp = ID.timestamp(id)
    end
  end

  test "can extract original timestamp succesfully (without custom epoch start) from an ID" do
    worker_id = 21
    sequence_number = 67
    timestamp = 168_989
    id = ID.generate(worker_id, timestamp, sequence_number)

    assert ^timestamp = ID.internal_timestamp(id)
  end
end
