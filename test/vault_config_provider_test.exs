defmodule VaultConfigProviderTest do
  use ExUnit.Case

  import Mock

  setup_with_mocks([
    {Vaultex.Client, [], [read: fn path, _method, _credentials -> {:ok, %{"key" => "ok"}} end]}
  ]) do
    Application.put_env(:vaultex, :auth, {:method, :credentials})
    :ok
  end

  describe "resolve secrets" do
    test "single string path" do
      assert VaultConfigProvider.resolve_secrets(
               app: [some_key: "secret:secret/services/my_app key=key"]
             ) == [app: [some_key: "ok"]]
    end

    test "keyword path" do
      assert VaultConfigProvider.resolve_secrets(
               app: [some_key: [path: "secret/services/my_app", key: "key"]]
             ) == [app: [some_key: "ok"]]
    end

    test "key word path with transform" do
      assert VaultConfigProvider.resolve_secrets(
               app: [
                 some_key: [
                   path: "secret/services/my_app",
                   key: "key",
                   fun: &String.upcase/1
                 ]
               ]
             ) == [app: [some_key: "OK"]]
    end

    test "keyword paths in array" do
      assert VaultConfigProvider.resolve_secrets(
               app: [
                 some_key: [
                   [path: "secret/services/my_app", key: "key"],
                   [path: "secret/services/my_app", key: "key"]
                 ]
               ]
             ) == [app: [some_key: ["ok", "ok"]]]
    end

    test "string paths in array" do
      assert VaultConfigProvider.resolve_secrets(
               app: [
                 some_key: [
                  "secret:secret/services/my_app key=key",
                  "secret:secret/services/my_app key=key"
                 ]
               ]
             ) == [app: [some_key: ["ok", "ok"]]]
    end

    test "deeply nested keyword path" do
      assert VaultConfigProvider.resolve_secrets(
               app: [
                 some_key: [
                   at: [
                     a: [
                       very: [
                         deep: [
                           path: [path: "secret/services/my_app", key: "key"]
                         ]
                       ]
                     ]
                   ]
                 ]
               ]
             ) == [app: [some_key: [at: [a: [very: [deep: [path: "ok"]]]]]]]
    end
  end
end
