defmodule PlugResponseReplace.MixProject do
  use Mix.Project

  @description "A tiny plug for replacing response fields"
  @source_url "https://github.com/edragonconnect/plug_response_replace"

  def project do
    [
      app: :plug_response_replace,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      description: @description,
      source_url: @source_url,
      package: package()
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
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.0", only: [:dev, :test]},
      {:jason, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      formatter_opts: [gfm: true],
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Xin Zou"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
