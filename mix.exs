defmodule Memfish.MixProject do
  use Mix.Project

  def project do
    [
      app: :memfish,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/cleverbunny/memfish"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Memfish.Application, []}
    ]
  end

  defp package do
    [
      maintainers: ["Tetiana Dushenkivska", "Keith Salisbury"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cleverbunny/memfish"}
    ]
  end

  defp description do
    "Stores key/value pairs for a specified period"
  end

  defp docs do
    [
      main: "readme",
      logo: "memfish.jpg",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
