defmodule Data.Contexts.RegionContext do
  @moduledoc false
  alias Data.{
    Schemas.Region,
    Repo
  }

  def insert_region_seed(params) do
    params
    |> get_region_by_region_and_island_group()
    |> create_update_region(params)
  end

  defp create_update_region(region, params) when is_nil(region) do
    %Region{}
    |> Region.changeset(params)
    |> Repo.insert()
  end

  defp create_update_region(region, params) do
    region
    |> Region.changeset(params)
    |> Repo.update()
  end

  def get_region_by_region_and_island_group(params) do
    Region
    |> Repo.get_by(code: params.code)
  end

end
