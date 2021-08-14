defmodule VaultConfigProvider.MixProject do
  use Mix.Project

  @source_url "https://github.com/sevenmind/vault_config_provider"
  @version "0.3.0"

  def project do
    [
      app: :vault_config_provider,
      version: @version,
      name: "VaultConfigProvider",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:vaultex, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp package do
    [
      description: "Release config provider to read vault secrets.",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", ".formatter.exs"],
      maintainers: ["Grant McLendon"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
