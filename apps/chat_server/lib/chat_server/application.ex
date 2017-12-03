defmodule Chat.Server.Application do
  @moduledoc false

  use Application

  alias Chat.Server.Handler

  def start(_type, _args) do
    opts = [port: 8080]
    children = [
      :ranch.child_spec(Chat.Server, :ranch_tcp, opts, Handler, [])
    ]

    opts = [strategy: :one_for_one, name: Chat.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
