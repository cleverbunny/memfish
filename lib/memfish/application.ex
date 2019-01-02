defmodule Memfish.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [Memfish]

    opts = [strategy: :one_for_one, name: Memfish.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
