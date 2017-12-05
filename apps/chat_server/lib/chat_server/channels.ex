defmodule Chat.Server.Channels do
  @registry Chat.Server.ChannelsRegistry

  alias Chat.Server.Message

  def join(channel, name) do
    # add `name` so it can be used in list_users/1
    Registry.register(@registry, channel, name)
  end

  def push(from, channel, message) do
    message = Message.format_channel_message(from, channel, message)

    Registry.dispatch(@registry, channel, &send_in_channel(&1, message), parallel: true)
  end

  def list_users(channel) do
    @registry
    |> Registry.lookup(channel)
    |> Enum.take(100)
    |> Enum.map(fn {_, name} -> name end)
    |> Enum.sort()
  end

  defp send_in_channel(entries, message) do
    Enum.each entries, fn {user, _}->
      Message.channel_message(user, message)
    end
  end
end
