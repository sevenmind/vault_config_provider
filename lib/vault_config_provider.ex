defmodule VaultConfigProvider do
  @moduledoc """
  VaultConfigProvider is a [release config
  provider](https://hexdocs.pm/elixir/Config.Provider.html).

  This provider expects a path to a config file to load during boot as an
      argument: config_providers: [{VaultConfigProvider, []}]

  The above configuration goes in a `release` or `environment` definition in
  `rel/congfig.exs`, and will result in the given path being expanded during
  boot, and evaluated using `Mix.Config`.

  Any value set as `"secret:secret/foo/bar key=baz"`, `[path: "secret/foo/bar",
  key: "baz"]`, or `"vault:secret/foo/bar#baz"` will be resolved from Vault.

  This provider expects the passed config file to contain configuration for
  `Vaultex.Client.auth/3` describing authentication parameters:

      # using kubernetes auth strategy
      config :vaultex,
        auth: {:kubernetes, %{jwt: File.read!("/tmp/token"), role: "my_role"}}

      # or using a token strategy
      config :vaultex,
        auth: {:token, {"root"}}

      config :vaultex,
        auth: {:github, {"github_token"}}

      config :vaultex,
        auth: {:app_id, {"app_id", "user_id"}}
  """

  @behaviour Config.Provider

  def init(_), do: nil

  def load(config, _) do
    {:ok, _} = Application.ensure_all_started(:vaultex)

    Config.Reader.merge(config, resolve_secrets(config))
  end

  def resolve_secrets(config) do
    Enum.map(config, &eval_secret(&1, config))
  end

  defp eval_secret("secret:" <> path, config) do
    [path, vault_key] = split_path(path)

    eval_secret([path: path, key: vault_key], config)
  end

  defp eval_secret("vault:" <> path, config) do
    [path, vault_key] = split_path(path)

    eval_secret([path: path, key: vault_key], config)
  end

  defp eval_secret([path: path, key: vault_key, fun: fun], config) do
    secret = eval_secret([path: path, key: vault_key], config)

    fun.(secret)
  end

  defp eval_secret([path: path, key: vault_key], config) when is_binary(vault_key) do
    with {:ok, secret} when is_map(secret) <- vault_read(path, config) do
      secret[vault_key]
    else
      error ->
        raise ArgumentError, "secret at #{path}##{vault_key} returned #{inspect(error)}"
    end
  end

  defp eval_secret([path: path, key: nil], config) do
    with {:ok, secret} when is_map(secret) <- vault_read(path, config) do
      secret
    else
      error ->
        raise ArgumentError, "secret at #{path}# returned #{inspect(error)}"
    end
  end

  defp eval_secret({key, val}, config) do
    {key, eval_secret(val, config)}
  end

  defp eval_secret(val, config) when is_list(val), do: Enum.map(val, &eval_secret(&1, config))

  defp eval_secret(other, _config), do: other

  defp vault_read(path, config) do
    {method, credentials} = get_in(config, [:vaultex, :auth])
    Vaultex.Client.read(path, method, credentials)
  end

  defp split_path(path) do
    pattern = :binary.compile_pattern([" ", "#"])

    if String.contains?(path, pattern) do
      [path, key] = String.split(path, pattern)

      key =
        case key do
          "key=" <> key -> key
          key -> key
        end

      [path, key]
    else
      [path, nil]
    end
  end
end
