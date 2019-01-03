defmodule MemfishTest do
  use ExUnit.Case, async: true
  doctest Memfish

  test "value stored and removed successfully" do
    key = 123
    assert Memfish.remember(key, "hello") == :ok
    assert Memfish.retrieve(key) == {:ok, "hello"}

    Memfish.forget(key)
    assert Memfish.retrieve(key) == :not_found
  end

  test "value remember within time limit" do
    key = 123
    {:ok, _pid} = Memfish.start_link(name: :memfish_test, clean_up_interval: 1)
    assert Memfish.remember(key, "hello", for: 100) == :ok
    assert Memfish.retrieve(key) == {:ok, "hello"}
  end

  test "value forgotten after time limit" do
    key = 123
    {:ok, _pid} = Memfish.start_link(name: :memfish_forget, clean_up_interval: 1)
    assert Memfish.remember(key, "hello", for: 0) == :ok

    Process.sleep(5)

    assert Memfish.retrieve(key) == :not_found
  end
end
