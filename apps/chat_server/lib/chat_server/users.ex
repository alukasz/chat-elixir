defmodule Chat.Server.Users do
  @broadcast_channel "all"
  @registry Chat.Server.UsersRegistry

  def find(name) do
    case Registry.lookup(@registry, name) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end

  def find_by_pid(pid) do
    case Registry.keys(@registry, pid) do
      [name] -> {:ok, name}
      _ -> {:error, :not_found}
    end
  end

  # rethink implementation
  # ETS table with update_counter would be faster
  # for the cost of manually decreasing counter
  def count do
    Chat.Server.ChannelsRegistry
    |> Registry.lookup(@broadcast_channel)
    |> length()
  end
end
