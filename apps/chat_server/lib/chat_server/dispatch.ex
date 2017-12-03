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
  def handle_command(command) do
    Command.unknown(command)
  end
end
