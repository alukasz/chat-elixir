defmodule Chat.Server.Command do
  alias Chat.Server.{Auth, Channels, Message, Users}

  require Logger

  @broadcast_channel "all"

  def auth(name) do
    case Auth.register(name) do
      :ok ->
        Channels.join(@broadcast_channel, name)
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
    authenticated fn name ->
      {user, message} = parse_name_message(data)
      case Users.find(user) do
        {:ok, pid} ->
          Message.whisper(pid, name, message)

        {:error, :not_found} ->
          respond("User does not exists.")
      end
    end
  end

  def join(channel) do
    authenticated fn name ->
      Channels.join(channel, name)
      respond("Joined.")
    end
  end

  def tell(data) do
    authenticated fn name ->
      {channel, message} = parse_name_message(data)
      Channels.push(name, channel, message)
    end
  end

  def yell(message) do
    authenticated fn name ->
      Channels.push(name, @broadcast_channel, message)
    end
  end

  def users(channel) do
    authenticated fn _ ->
      channel
      |> Channels.list_users()
      |> Enum.join(", ")
      |> respond()
    end
  end

  def count do
    Users.count()
    |> to_string()
    |> respond()
  end

  def unknown(_) do
    respond("Unknown command.")
  end

  defp authenticated(fun) do
    case Auth.authenticate() do
      {:ok, name} ->
        fun.(name)

      {:error, :unauthenticated} ->
        respond("You are not authenticated, use 'auth <name>'.")
    end
  end

  defp respond(message) do
    {:send, message}
  end

  defp parse_name_message(data) do
    case String.split(data, " ", parts: 2, trim: true) do
      [name] -> {name, ""}
      [name, message] -> {name, message}
    end
  end
end
