defmodule Chat.Server.CommandTest do
  use ExUnit.Case

  import Chat.Server.TestHelper

  alias Chat.Server.{Auth, Channels, Command}

  @username "username"
  @other "other"
  @channel "test"

  describe "auth/1" do
    test "when user authenticates" do
      assert Command.auth(@username) == sent("Welcome #{@username}.")
    end

    test "when name is taken" do
      run_in_background fn ->
        Auth.register(@username)
      end

      assert Command.auth(@username) ==
        sent("Name taken, please select other one.")
    end

    test "when user is already authenticated" do
      Auth.register(@username)

      assert Command.auth(@username) ==
        sent("You can't fool me, #{@username}.")
    end
  end

  describe "who_am_i/0" do
    test "with authenticated user" do
      Auth.register(@username)

      assert Command.who_am_i() ==
        sent("You are #{@username}.")
    end

    test "with unauthenticated user" do
      assert Command.who_am_i() ==
        sent("Dunno, please use 'auth <name>' to authenticate.")
    end
  end

  describe "whisper/1" do
    test "sending message" do
      Auth.register(@username)
      run_in_background fn ->
        Auth.register(@other)
        assert Command.whisper("#{@username} hello") == :ok
      end

      assert_receive {:send, "#{@other} whispers: hello"}
    end

    test "when user is not authenticated" do
      run_in_background fn ->
        Auth.register(@other)
      end

      assert Command.whisper("#{@other} hello") ==
        sent("You are not authenticated, use 'auth <name>'.")
    end

    test "when other user does not exists" do
      Auth.register(@username)

      assert Command.whisper("#{@other} hello") ==
        sent("User does not exists.")
    end
  end

  describe "join/1" do
    test "joins a channel" do
      Auth.register(@username)

      assert Command.join("channel") == sent("Joined.")
    end

    test "when user is not authenticated" do
      assert Command.join("channel") ==
        sent("You are not authenticated, use 'auth <name>'.")
    end
  end

  describe "tell/1" do
    test "sends message to everybody in channel" do
      Auth.register(@username)
      Channels.join(@channel)

      Command.tell("#{@channel} hello")

      assert_receive {:send, "#{@username} in #{@channel}: hello"}
    end

    test "when user is not authenticated" do
      assert Command.join("channel") ==
        sent("You are not authenticated, use 'auth <name>'.")
    end
  end

  describe "unknown/1" do
    test "informs user that command does not exist" do
      assert Command.unknown("something") == sent("Unknown command.")
    end
  end

  defp sent(message) do
    {:send, message}
  end
end
