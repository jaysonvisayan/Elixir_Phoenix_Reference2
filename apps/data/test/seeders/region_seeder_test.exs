defmodule Data.Tests.RegionSeederTest do
  use Data.SchemaCase, async: false

  alias Data.Seeders.RegionSeeder

  test "seed with new data" do
    data = [
      %{
        island_group: "Mindanao",
        region_name: "Region XII - SOCCSARGEN",
        code: "R-XII"
      }

    ]
    [d1] = RegionSeeder.seed(data)
    assert d1.code == "R-XII"
  end

  test "seed with existing data" do
    insert(:region, code: "R-XII", island_group: "Luzon")
    data = [
      %{
        island_group: "Mindanao",
        region_name: "Region XII - SOCCSARGEN",
        code: "R-XII"
      }

    ]
    [d1] = RegionSeeder.seed(data)
    assert d1.code == "R-XII"
    assert d1.island_group == "Mindanao"
  end
end
