defmodule Chat.Server.Channels do
  @registry Chat.Server.ChannelsRegistry

  alias Chat.Server.Message

  def join(channel) do
    Registry.register(@registry, channel, nil)
  end

  def push(from, channel, message) do
    message = Message.format_channel_message(from, channel, message)

    Registry.dispatch(@registry, channel, &send_in_channel(&1, message), parallel: true)
  end

  defp send_in_channel(entries, message) do
    Enum.each entries, fn {user, _}->
      Message.channel_message(user, message)
    end
  end
end
