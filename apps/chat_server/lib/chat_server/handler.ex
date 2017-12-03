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

    state = %{ref: ref, socket: socket, transport: transport}
    :gen_server.enter_loop(__MODULE__, [], state)
  end

  def handle_info({:tcp, socket, data}, %{transport: transport, socket: socket} = state) do
    transport.send(socket, data)

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
  def handle_info(message, state) do
    Logger.warn("#{__MODULE__} unhandled message: #{inspect message}")

    {:noreply, state}
  end
end
