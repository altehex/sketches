defmodule Mix.Tasks.Compile.Tax do
  def run(_args) do
	{_result, _error} = System.cmd("make", [])
	:ok
  end
end

defmodule Tax.MixProject do
  use Mix.Project

  def project do
    [
      app: :tax,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
	  compilers: [:tax] ++ Mix.compilers
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
	  extra_applications: [:logger, ex_unit: :optional]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
