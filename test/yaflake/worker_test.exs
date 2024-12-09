defmodule Yaflake.WorkerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  import Mox, only: [stub: 3, set_mox_global: 1]

  alias Yaflake.Node.InterfaceMock
  alias Yaflake.Worker

  setup :set_mox_global

  setup do
    stub(InterfaceMock, :getifaddrs, fn -> [en1: [100, 86, 99, 156, 204, 19]] end)
    start_supervised!({Worker, worker_id: 10, worker_name: :test_worker})
    :ok
  end

  describe "generate/0" do
    test "generates sequential, sortable by time IDs " do
      ids = for _i <- 0..99, do: Worker.generate()
      assert Enum.sort(ids) == ids
    end
  end
end
