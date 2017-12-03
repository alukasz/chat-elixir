defmodule Chat.Server.TestHelper do
  def run_in_background(fun) do
    Agent.start_link(fun)
  end
end

ExUnit.start()
