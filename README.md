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

Configure [Vaultex](https://github.com/findmypast/vaultex) with correct vault address and credentials. The Vault address can be set from the system environment or application environment.

VaultConfigProvider assumes vault auth credentials are set in previous config providers. 

With the standard `Mix.Releases.Config.Providers.Elixir`:

```elixir
config :vaultex,
  auth: {:kubernetes, %{jwt: File.read!("/tmp/token"), role: "my_role"}},
  vault_addr: "http://127.0.0.1"

config :vaultex,
  auth: {:token, {"root"}}
```

## Usage

The provider will resolve secrets stored matching two patterns:

In a string

```
scheme:#{path} key=#{key_name}
```

In a keyword list 

```elixir
config :xandra, Xandra,
  nodes: [
    path: "secret/services/cassandra", 
    key: "nodes", 
    fun: &String.split(&1, ",")
  ]
```


```elixir
config :my_app,
  # with a string
  username: "secret:secret/services/my_app key=username",

  username: [
    path: "secret/services/my_app",
    key: "username",
    fun: fn v -> v end
  ],
```
