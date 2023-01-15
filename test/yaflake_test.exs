defmodule YaflakeTest do
  use ExUnit.Case
  doctest Yaflake

  test "generates an ID" do
    assert {:ok, _} = Yaflake.generate()
  end
end
