# VaultConfigProvider

[![Hex.pm Version](http://img.shields.io/hexpm/v/vault_config_provider.svg?style=flat)](https://hex.pm/packages/vault_config_provider)

VaultConfigProvider is an Elixir [release config provider](https://hexdocs.pm/elixir/Config.Provider.html) for loading secrets from [Vault](https://www.vaultproject.io/) into app env at runtime.

Built with [Vaultex](https://github.com/findmypast/vaultex)

## Installation

The package can be installed by adding `vault_config_provider` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vault_config_provider, "~> 0.4.0"}
  ]
end
```

Configure [your release](https://hexdocs.pm/mix/Mix.Tasks.Release.html) and add VaultConfigProvider as a config provider

```
def project
  [
    releases: [
      config_providers: [{VaultConfigProvider, nil}]
    ]
  ]
```

## Configuration

Read the [Vaultex docs](https://github.com/findmypast/vaultex), and configure vaultex with your vault address and credentials. The Vault address can be set from the system environment or application environment.

VaultConfigProvider assumes vault auth credentials are already set in application environment by earlier config providers.

```elixir
config :vaultex,
  auth: {:kubernetes, %{jwt: File.read!("/tmp/token"), role: "my_role"}},
  vault_addr: "http://127.0.0.1"

# or 

config :vaultex,
  auth: {:token, {"root"}}
```

## Usage

The provider will resolve secrets stored matching two patterns: strings or keyword lists. Keyword lists can contain transformations.

```elixir
config :my_app,
  username: "secret:secret/services/my_app key=username"
  
  username: "vault:secret/services/my_app#username"

  username: [
    path: "secret/services/my_app",
    key: "username",
    fun: &String.upcase/1
  ]

  user_config: "secret:secret/services/my_app" # %{"key" => "username}
```

A string address is expected to include `secret:/path` and `key=key_name` or `vault:path` and `#key_name`

A keyword address must contain the keys `key` and `path` and may contain optional `fun` function which will be applied to any returned values