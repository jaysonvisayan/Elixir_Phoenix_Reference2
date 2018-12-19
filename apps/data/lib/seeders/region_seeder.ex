defmodule Data.Seeders.RegionSeeder do
  @moduledoc false

  alias Data.Contexts.RegionContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case RegionContext.insert_region_seed(params) do
        {:ok, region} ->
          region
      end
    end)
  end
end
