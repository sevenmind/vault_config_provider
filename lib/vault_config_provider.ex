defmodule VaultConfigProvider do
  @moduledoc """
  VaultConfigProvider is a [Distillery Config provider](https://hexdocs.pm/distillery/config/runtime.html#config-providers).

  This provider expects a path to a config file to load during boot as an argument:
      set config_providers: [
        {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/config.exs"]},
        {VaultConfigProvider, []}
      ]

  The above configuration goes in a `release` or `environment` definition in `rel/congfig.exs`,
  and will result in the given path being expanded during boot, and evaluated using `Mix.Config`.

  Any value set as `"secret:secret/foo/bar key=baz"` or `[path: "secret/foo/bar", key: "baz"]`
  will be resolved from Vault.

  This provider is based on `Mix.Releases.Config.Providers.Elixir` in `Distillery` 2.0.9

  This provider expects the passed config file to contain configuration for `Vaultex.Client.auth/3` describing authentication parameters:

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

  use Mix.Releases.Config.Provider

  def init(_) do
    # Ensure VaultEx is started
    vault_started? = app_started?(:vaultex)

    unless vault_started? do
      {:ok, _} = Application.ensure_all_started(:vaultex)
    end

    try do
      app_env()
      |> resolve_secrets()
      |> persist()
    else
      _ ->
        :ok
    after
      # teardown started vaultex if started here
      unless vault_started? do
        :ok = Application.stop(:vaultex)
      end
    end
  end

  def app_env do
    for {app, _, _} <- :application.loaded_applications() do
      {app, :application.get_all_env(app)}
    end
  end

  defp persist(config) do
    for {app, app_config} <- config do
      for {k, v} <- app_config do
        Application.put_env(app, k, v, persistent: true)
      end
    end

    :ok
  end

  defp app_started?(app) do
    List.keymember?(Application.started_applications(), app, 0)
  end

  defp vault_read(path) do
    {method, credentials} = Application.get_env(:vaultex, :auth)
    Vaultex.Client.read(path, method, credentials)
  end

  def resolve_secrets(runtime_config) do
    Enum.map(runtime_config, &eval_secret(&1))
  end

  defp eval_secret("secret:" <> path) do
    [path, "key=" <> vault_key] = String.split(path, " ")

    eval_secret(path: path, key: vault_key)
  end

  defp eval_secret(path: path, key: vault_key, fun: fun) do
    secret = eval_secret(path: path, key: vault_key)

    fun.(secret)
  end

  defp eval_secret(path: path, key: vault_key) do
    with {:ok, secret} when is_map(secret) <- vault_read(path) do
      secret[vault_key]
    else
      error ->
        raise ArgumentError, "secret at #{path}##{vault_key} returned #{inspect(error)}"
    end
  end

  defp eval_secret({key, val}) do
    {key, eval_secret(val)}
  end

  defp eval_secret(val) when is_list(val), do: Enum.map(val, &eval_secret/1)

  defp eval_secret(other), do: other
end
