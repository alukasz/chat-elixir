defmodule Chat.Server.AuthTest do
  use ExUnit.Case

  import Chat.Server.TestHelper

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
    run_in_background fn ->
      Auth.register(@username)
    end

    assert Auth.register(@username) == {:error, :name_taken}
  end
end
