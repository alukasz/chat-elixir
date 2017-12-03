defmodule Chat.Server.Handler do
  use GenServer

  require Logger

  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{ref, socket, transport}])

    {:ok, pid}
  end

  def init({ref, socket, transport}) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, active: true)
    send(self(), :after_join)

    state = %{ref: ref, socket: socket, transport: transport}
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  def handle_info({:tcp, socket, data}, %{transport: transport, socket: socket} = state) do
    data
    |> dispatch()
    |> maybe_send(socket, transport)

    {:noreply, state}
  end
  def handle_info({:send, message}, %{transport: transport, socket: socket} = state) do
    send_message(message, socket, transport)

    {:noreply, state}
  end
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end
  def handle_info({:tcp_error, _socket, reason}, state) do
    {:stop, reason, state}
  end
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end
  def handle_info(:after_join, %{transport: transport, socket: socket} = state) do
    data = [
      "Available commands:",
      "auth <name> - authenticates under given name",
      "whoami - prints your name",
      "whisper <name> <message> - sends 'message' to 'name', w <name> <message> for short"
    ]
    |> Enum.map(&encode_data(&1))
    |> Enum.join()

    transport.send(socket, data)

    {:noreply, state}
  end
  def handle_info(message, state) do
    Logger.warn("#{__MODULE__} unhandled message: #{inspect message}")

    {:noreply, state}
  end

  defp dispatch(data) do
    data
    |> String.trim()
    |> Chat.Server.Dispatch.handle_command()
  end

  defp send_message(data, socket, transport) do
    transport.send(socket, encode_data(data))
  end

  defp maybe_send({:send, data}, socket, transport) do
    send_message(data, socket, transport)
  end
  defp maybe_send(_, _, _), do: :ok

  defp encode_data(data) do
    data <> "\r\n"
  end
end
