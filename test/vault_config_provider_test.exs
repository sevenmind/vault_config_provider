defmodule VaultConfigProviderTest do
  use ExUnit.Case

  import Mock

  setup_with_mocks([
    {Vaultex.Client, [], [read: fn path, _method, _credentials -> {:ok, %{"key" => "ok"}} end]}
  ]) do
    :ok
  end

  describe "resolve secrets" do
    test "single string path" do
      assert [{:app, [some_key: "ok"]} | _] =
               VaultConfigProvider.resolve_secrets(
                 app: [some_key: "secret:secret/services/my_app key=key"],
                 vaultex: [auth: {:method, :credentials}]
               )
    end

    test "keyword path" do
      assert [{:app, [some_key: "ok"]} | _] =
               VaultConfigProvider.resolve_secrets(
                 app: [some_key: [path: "secret/services/my_app", key: "key"]],
                 vaultex: [auth: {:method, :credentials}]
               )
    end

    test "key word path with transform" do
      assert [{:app, [some_key: "OK"]} | _] =
               VaultConfigProvider.resolve_secrets(
                 app: [
                   some_key: [
                     path: "secret/services/my_app",
                     key: "key",
                     fun: &String.upcase/1
                   ]
                 ],
                 vaultex: [auth: {:method, :credentials}]
               )
    end

    test "keyword paths in array" do
      assert [{:app, [some_key: ["ok", "ok"]]} | _] =
               VaultConfigProvider.resolve_secrets(
                 app: [
                   some_key: [
                     [path: "secret/services/my_app", key: "key"],
                     [path: "secret/services/my_app", key: "key"]
                   ]
                 ],
                 vaultex: [auth: {:method, :credentials}]
               )
    end

    test "string paths in array" do
      assert [{:app, [some_key: ["ok", "ok"]]} | _] =
               VaultConfigProvider.resolve_secrets(
                 app: [
                   some_key: [
                     "secret:secret/services/my_app key=key",
                     "secret:secret/services/my_app key=key"
                   ]
                 ],
                 vaultex: [auth: {:method, :credentials}]
               )
    end

    test "deeply nested keyword path" do
      assert [{:app, [some_key: [at: [a: [very: [deep: [path: "ok"]]]]]]} | _] =
               VaultConfigProvider.resolve_secrets(
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
                 ],
                 vaultex: [auth: {:method, :credentials}]
               )
    end
  end
end
