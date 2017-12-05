defmodule Chat.Server.Command do
  alias Chat.Server.{Auth, Channels, Message, Users}

  require Logger

  @broadcast_channel "all"

  def auth(name) do
    case Auth.register(name) do
      :ok ->
        Channels.join(@broadcast_channel)
        respond("Welcome #{name}.")

      {:error, :name_taken} ->
        respond("Name taken, please select other one.")

      {:error, :already_registered} ->
        {:ok, name} = Users.find_by_pid(self())
        respond("You can't fool me, #{name}.")
    end
  end

  def who_am_i do
    case Users.find_by_pid(self()) do
      {:ok, name} ->
        respond("You are #{name}.")

      {:error, :not_found} ->
        respond("Dunno, please use 'auth <name>' to authenticate.")
    end
  end

  def whisper(data) do
    with {:ok, user} <- Auth.authenticate(),
         {name, message} <- parse_name_message(data),
         {:ok, pid} <- Users.find(name) do
      Message.whisper(pid, user, message)
      :ok
    else
      {:error, :unauthenticated} ->
        respond("You are not authenticated, use 'auth <name>'.")

      {:error, :not_found} ->
        respond("User does not exists.")
    end
  end

  def join(channel) do
    case Auth.authenticate() do
      {:ok, _} ->
        Channels.join(channel)
        respond("Joined.")

      {:error, :unauthenticated} ->
        respond("You are not authenticated, use 'auth <name>'.")
    end
  end

  def tell(data) do
    case Auth.authenticate() do
      {:ok, name} ->
        {channel, message} = parse_name_message(data)
        Channels.push(name, channel, message)

      {:error, :unauthenticated} ->
        respond("You are not authenticated, use 'auth <name>'.")
    end
  end

  def yell(message) do
    case Auth.authenticate() do
      {:ok, name} ->
        Channels.push(name, @broadcast_channel, message)

      {:error, :unauthenticated} ->
        respond("You are not authenticated, use 'auth <name>'.")
    end
  end

  def unknown(_) do
    respond("Unknown command.")
  end

  defp respond(message) do
    {:send, message}
  end

  defp parse_name_message(data) do
    data
    |> String.split(" ", parts: 2, trim: true)
    |> List.to_tuple()
  end
end
