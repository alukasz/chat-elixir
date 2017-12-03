defmodule Chat.Server.UsersTest do
  use ExUnit.Case

  alias Chat.Server.{Auth, Users}

  @username "username"

  test "find/1 returns pid of registered user" do
    Auth.register(@username)

    assert Users.find(@username) == {:ok, self()}
  end

  test "find/1 when name is not registered" do
    assert Users.find(@username) == {:error, :not_found}
  end

  test "find_by_pid/1 returns pid of registered user" do
    Auth.register(@username)

    assert Users.find_by_pid(self()) == {:ok, @username}
  end

  test "find_by_pid/1 when name is not registered" do
    assert Users.find_by_pid(self()) == {:error, :not_found}
  end
end
