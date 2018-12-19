defmodule Data.Seeders.CoverageSeeder do
  @moduledoc false

  alias Data.Contexts.CoverageContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case CoverageContext.insert_coverage_seed(params) do
        {:ok, coverage} ->
          coverage
      end
    end)
  end
end
