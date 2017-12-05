defmodule Chat.Server.Application do
  @moduledoc false

  use Application

  alias Chat.Server.Handler

  def start(_type, _args) do
    ranch_opts = [port: Application.get_env(:chat_server, :port)]
    children = [
      {Registry, keys: :unique, name: Chat.Server.UsersRegistry},
      {Registry, keys: :duplicate, name: Chat.Server.ChannelsRegistry,
                 partitions: System.schedulers_online()},
      :ranch.child_spec(Chat.Server, :ranch_tcp, ranch_opts, Handler, [])
    ]

    opts = [strategy: :one_for_one, name: Chat.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
