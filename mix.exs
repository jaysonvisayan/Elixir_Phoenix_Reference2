defmodule Medical.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: :dev},
      {:decimal, "~> 1.0"},
      {:sobelow, "~> 0.7", only: :dev}
    ]
  end

  defp aliases do
    [
      "scan.all": ["scan.code", "scan.security"],
      "scan.security": ["sobelow --root apps/api -i Config.HTTPS"],
      "scan.code": ["credo"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.seed": ["run apps/data/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reset-seed": ["ecto.drop", "ecto.setup", "ecto.seed"]
    ]
  end
end
