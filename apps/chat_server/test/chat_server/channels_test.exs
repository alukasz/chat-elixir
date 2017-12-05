defmodule Chat.Server.ChannelsTest do
  use ExUnit.Case

  import Chat.Server.TestHelper

  alias Chat.Server.{Channels, ChannelsRegistry}

  @channel "test"

  test "join/1 adds user to channel" do
    Channels.join(@channel)
    pid = self()

    assert [{^pid, _}] = Registry.lookup(ChannelsRegistry, @channel)
  end

  test "push/3 sends message to everyone in channel" do
    run_in_background fn ->
      Channels.join(@channel)
    end
    Channels.join(@channel)

    Channels.push("ex_unit", @channel, "hello")

    assert_receive {:send, "ex_unit in #{@channel}: hello"}
    assert_receive {:send, "ex_unit in #{@channel}: hello"}
  end
end
