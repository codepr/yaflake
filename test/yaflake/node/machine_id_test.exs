defmodule Yaflake.Node.MachineIDTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import Mox, only: [expect: 3]

  alias Yaflake.Node.InterfaceMock
  alias Yaflake.Node.MachineID

  describe "generate/1" do
    test "generate from an integer" do
      assert MachineID.generate(10) == 10
    end

    test "returns an ID" do
      hwaddr = [101, 99, 54, 201, 88, 143]
      <<_skip::integer-38, expected_id::integer-10>> = :binary.list_to_bin(hwaddr)
      expect(InterfaceMock, :getifaddrs, fn -> [en0: hwaddr] end)
      assert MachineID.generate() == 143
      assert expected_id == 143
    end

    test "filters nil interface hw-addresses" do
      [hwaddr | _rest] = hwaddresses = [[101, 99, 54, 201, 88, 143], nil, nil]

      <<_skip::integer-38, expected_id::integer-10>> = :binary.list_to_bin(hwaddr)
      expect(InterfaceMock, :getifaddrs, fn -> Enum.zip([[:en0, :en1, :lo], hwaddresses]) end)
      assert MachineID.generate() == 143
      assert expected_id == 143
    end

    test "returns an ID with a specific interface en0" do
      name = :en0

      InterfaceMock
      |> expect(:getifaddrs, fn -> [en0: [101, 99, 54, 201, 88, 143], lo: [0, 0, 0, 0, 0, 0]] end)
      |> expect(:getifaddr, fn ^name -> [101, 99, 54, 201, 88, 143] end)

      assert MachineID.generate(:en0) == 143
    end

    test "from with invalid input" do
      assert_raise ArgumentError,
                   "expected an integer or a string or an atom representing a network interface",
                   fn -> MachineID.generate(89.21) end
    end
  end
end
