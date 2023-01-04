defmodule ExflakeTest do
  use ExUnit.Case
  doctest Exflake

  test "greets the world" do
    assert Exflake.hello() == :world
  end
end
