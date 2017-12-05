defmodule Chat.Server.Message do
  def whisper(to, from, message) do
    send(to, {:send, format_whisper(from, message)})
  end

  def format_channel_message(from, channel, message) do
    "#{from} in #{channel}: #{message}"
  end

  def channel_message(to, message) do
    send(to, {:send, message})
  end

  defp format_whisper(from, message) do
    "#{from} whispers: #{message}"
  end
end
