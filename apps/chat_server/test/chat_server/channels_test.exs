defmodule Chat.Server.ChannelsTest do
  use ExUnit.Case

  import Chat.Server.TestHelper

  alias Chat.Server.{Auth, Channels, ChannelsRegistry}

  @channel "test"

  test "join/1 adds user to channel" do
    Channels.join(@channel, "user")
    pid = self()

    assert [{^pid, _}] = Registry.lookup(ChannelsRegistry, @channel)
  end

  test "push/3 sends message to everyone in channel" do
    run_in_background fn ->
      Channels.join(@channel, "other")
    end
    Channels.join(@channel, "user")

    Channels.push("ex_unit", @channel, "hello")

    assert_receive {:send, "ex_unit in #{@channel}: hello"}
    assert_receive {:send, "ex_unit in #{@channel}: hello"}
  end

  test "list_users/1 returns users in channel" do
    run_in_background fn ->
      Auth.register("u1")
      Channels.join(@channel, "u1")
    end
    Auth.register("u2")
    Channels.join(@channel, "u2")

    assert Channels.list_users(@channel) == ["u1", "u2"]
  end
end
