defmodule MemfishTest do
  use ExUnit.Case
  doctest Memfish

  test "greets the world" do
    assert Memfish.hello() == :world
  end
end
