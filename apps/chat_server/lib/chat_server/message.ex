defmodule Chat.Server.Message do
  def whisper(to, from, message) do
    send(to, {:send, format_whisper(from, message)})
  end

  defp format_whisper(from, message) do
    "#{from} whispers: #{message}"
  end
end
