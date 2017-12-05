defmodule Chat.Server.MessageTest do
  use ExUnit.Case

  alias Chat.Server.Message

  test "whisper/3 sends properly formatted message" do
    Message.whisper(self(), "ex_unit", "hello")

    assert_receive {:send, "ex_unit whispers: hello"}
  end


  test "format_channel_message/3" do
    assert Message.format_channel_message("ex_unit", "test", "hello") ==
      "ex_unit in test: hello"
  end

  test "channel_message/4 sends message" do
    Message.channel_message(self(), "message")

    assert_receive {:send, "message"}
  end
end
