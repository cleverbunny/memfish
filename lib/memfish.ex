defmodule Memfish do
  use Agent

  @moduledoc """
  Memfish provides you a way to store values against the key for a short period of time
  (20 mins by default).

  It uses an `Agent` abstraction to store values in memory.
  """

  # 1 min
  @clean_up_interval 60_000
  # 20 min
  @delay 1_200_000

  @type key :: integer | String.t() | atom

  @doc """
  Start up a `:memfish` process.

  ## Examples

      Memfish.start_link()
      {:ok, pid}

  Also, you can provide `:name` and `clean_up_interval` on startup.
  `:name` - specify a name to be given for `memfish` process (atom)
  `:clean_up_interval` - specify how often check and clean up of expired key/value pairs would be
  performed (1 min by default)

      Memfish.start_link(name: :my_name, clean_up_interval: 100)
      {:ok, pid}
  """
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    clean_up_interval = Keyword.get(opts, :clean_up_interval, @clean_up_interval)
    name = Keyword.get(opts, :name, :memfish)

    :timer.apply_interval(clean_up_interval, __MODULE__, :delete_expired, [])

    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Store a key/value in a `memfish` process for a period of time (20 mins by default).

  ## Examples

      iex> Memfish.remember(123, :hello)
      :ok

  Also, you can specify for how long value will be stored before it expires. Provide integer value
  in milliseconds for `:for` option.

      iex> Memfish.remember(123, :hello, for: 60)
      :ok
  """
  @spec remember(key(), value :: any, opts :: Keyword.t()) :: :ok
  def remember(key, value, opts \\ []) do
    delay = Keyword.get(opts, :for, @delay)
    expires_at = NaiveDateTime.add(time_now(), delay, :millisecond)
    Agent.update(:memfish, &Map.put(&1, key, {value, expires_at}))
  end

  @doc """
  Retrieve value by it's key if it exists in the store, `:not_found` is returned when value hasn't been
  found. That would happen if value expired, deleted or never been saved to the store.

  ## Examples

      iex> Memfish.retrieve(:expired_key)
      :not_found
  """
  @spec retrieve(key()) :: {:ok, any} | :not_found
  def retrieve(key) do
    fetch_value = fn state ->
      case Map.get(state, key) do
        {value, _expires_at} -> {:ok, value}
        nil -> :not_found
      end
    end

    Agent.get(:memfish, fetch_value)
  end

  @doc """
  Tell `memfish` to forget any value stored under the :key

  ## Examples

      iex> Memfish.forget(:my_key)
      :ok
  """
  @spec forget(key()) :: :ok
  def forget(key) do
    Agent.update(:memfish, &Map.delete(&1, key))
  end

  @doc false
  def delete_expired do
    Agent.update(:memfish, fn state ->
      Enum.reject(state, &expired?/1)
      |> Enum.into(%{})
    end)
  end

  defp expired?({_key, {_value, expires_at}}) do
    case NaiveDateTime.compare(expires_at, time_now()) do
      :gt -> false
      :lt -> true
      :eq -> true
    end
  end

  defp time_now, do: NaiveDateTime.utc_now()
end
