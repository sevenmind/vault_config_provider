# VaultConfigProvider

[![Hex.pm Version](http://img.shields.io/hexpm/v/vault_config_provider.svg?style=flat)](https://hex.pm/packages/vault_config_provider)

VaultConfigProvider is an Elixir Distillery release config provider for loading secrets from [Vault](https://www.vaultproject.io/) into app env at runtime. 

Built with [Distillery](https://hexdocs.pm/distillery/home.html) and [Vaultex](https://github.com/findmypast/vaultex)

## Installation

The package can be installed by adding `vault_config_provider` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vault_config_provider, "~> 0.1.0"}
  ]
end
```

Set up [Distillery](https://github.com/bitwalker/distillery/) and add to config provider to the config_providers in `rel/config.exs`.

```
  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/config.exs"]},
    {VaultConfigProvider, []}
  ]
```

## Configuration

Read the [Vaultex docs](https://github.com/findmypast/vaultex), and configure vaultex with your vault address and credentials. The Vault address can be set from the system environment or application environment.

VaultConfigProvider assumes vault auth credentials are already set in application environment by earlier config providers. 

For instance, the standard `Mix.Releases.Config.Providers.Elixir` should be configured something like so:

```elixir
config :vaultex,
  auth: {:kubernetes, %{jwt: File.read!("/tmp/token"), role: "my_role"}},
  vault_addr: "http://127.0.0.1"

config :vaultex,
  auth: {:token, {"root"}}
```

## Usage

The provider will resolve secrets stored matching two patterns srtings or keyword lists. Keyword lists can contain transformations

```elixir
config :my_app,
  username: "secret:secret/services/my_app key=username",

  username: [
    path: "secret/services/my_app",
    key: "username",
    fun: &transform/1
  ],
```

A string address is expected to include `secret:/path` and `key=key_name`.

A keyword address must contain the keys `key` and `path` it also accepts an optional `fun` argument which can be used for transformations on returned values. 
