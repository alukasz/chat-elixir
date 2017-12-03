defmodule Chat.Server.Auth do
  @moduledoc """
  Performs authentication of the connection by name.
  Only one connection, identified by pid, can claim given name.
  """

  alias Chat.Server.Users

  @registry Chat.Server.UsersRegistry

  def authenticate(name) do
    case Registry.lookup(@registry, name) do
      [{pid, _}] when pid == self() -> {:ok, pid}
      _ -> :error
    end
  end

  def register(name) do
    case Users.find_by_pid(self()) do
      {:ok, name} ->
        {:error, :already_registered}

      _ ->
        case Registry.register(@registry, name, nil) do
          {:ok, _} -> :ok
          {:error, _} -> {:error, :name_taken}
        end
    end
  end
end
