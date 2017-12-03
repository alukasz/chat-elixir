defmodule Chat.Server.Users do
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
end
