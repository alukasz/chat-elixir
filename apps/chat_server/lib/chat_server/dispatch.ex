defmodule Chat.Server.Dispatch do
  @moduledoc """
  Parses and dispatches commands.
  """

  alias Chat.Server.Command

  def handle_command(<<"auth ", name :: binary>>) do
    Command.auth(name)
  end
  def handle_command(<<"whoami">>) do
    Command.who_am_i()
  end
  def handle_command(<<"whisper ", rest :: binary>>) do
    Command.whisper(rest)
  end
  def handle_command(<<"w ", rest :: binary>>) do
    Command.whisper(rest)
  end
  def handle_command(<<"join ", rest :: binary>>) do
    Command.join(rest)
  end
  def handle_command(<<"j ", rest :: binary>>) do
    Command.join(rest)
  end
  def handle_command(<<"tell ", rest :: binary>>) do
    Command.tell(rest)
  end
  def handle_command(<<"t ", rest :: binary>>) do
    Command.tell(rest)
  end
  def handle_command(<<"yell ", rest :: binary>>) do
    Command.yell(rest)
  end
  def handle_command(<<"y ", rest :: binary>>) do
    Command.yell(rest)
  end
  def handle_command(command) do
    Command.unknown(command)
  end
end
