defmodule Chat.Server.TestHelper do
  defmodule Echo do
    use GenServer

    def start_link(fun, process) do
      GenServer.start_link(__MODULE__, {fun, process})
    end

    def init({fun, process}) do
      fun.()

      {:ok, process}
    end

    # forward received messages to `process`
    def handle_info(message, process) do
      send(process, message)

      {:noreply, process}
    end
  end

  def run_in_background(fun, process \\ self()) do
    Echo.start_link(fun, process)
  end
end

ExUnit.start()
