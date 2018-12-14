defmodule VaultConfigProvider.MixProject do
  use Mix.Project

  def project do
    [
      app: :vault_config_provider,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: "distillery config provider to read vault secrets",
      package: package(),
      deps: deps()
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
      {:vaultex, "~> 0.8"},
      {:distillery, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
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
