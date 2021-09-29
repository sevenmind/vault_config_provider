defmodule VaultConfigProvider.MixProject do
  use Mix.Project

  def project do
    [
      app: :vault_config_provider,
      version: "0.4.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: "release config provider to read vault secrets",
      package: package(),
      deps: deps(),
      name: "VaultConfigProvider",
      docs: [
        main: "VaultConfigProvider",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:vaultex, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", ".formatter.exs"],
      maintainers: ["Grant McLendon"],
      licenses: ["MIT"],
      links: %{
        Documentation: "https://hexdocs.pm/vault_config_provider",
        GitHub: "https://github.com/sevenmind/vault_config_provider"
      }
    ]
  end
end
