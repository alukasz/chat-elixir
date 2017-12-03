defmodule Chat.Server.AuthTest do
  use ExUnit.Case

  alias Chat.Server.Auth

  @username "username"

  test "register/1 registers new username" do
    assert Auth.register(@username) == :ok
  end

  test "register/1 when user tries register twice" do
    Auth.register(@username)

    assert Auth.register(@username) == {:error, :already_registered}
  end

  test "register/1 when username is already registered" do
    Task.async(fn ->
      Auth.register(@username)
    end) |> Task.await()

    assert Auth.register(@username) == {:error, :name_taken}
  end

  test "authenticate/1 when user was registered" do
    Auth.register(@username)

    assert Auth.authenticate(@username) == {:ok, self()}
  end

  test "authenticate/1 when user was not registered" do
    assert Auth.authenticate(@username) == :error
  end

  test "authenticate/1 when other connection tries to authenticate" do
    Task.async(fn ->
      Auth.register(@username)
    end) |> Task.await()

    spawn fn ->
      assert Auth.authenticate(@username) == :error
    end
  end
end
