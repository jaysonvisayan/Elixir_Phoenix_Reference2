defmodule Data.Tests.GenericLookUpSeederTest do
  use Data.SchemaCase, async: false

  alias Data.Seeders.GenericLookUpSeeder

  test "seed with new data" do
    data = [
      %{
        code: "F",
        type: "sample",
        name: "Facility",
        description: "Facility Test"
      }

    ]
    [d1] = GenericLookUpSeeder.seed(data)
    assert d1.code == "F"
  end

  test "seed with existing data" do
    insert(:generic_look_up, code: "F", type: "sample", name: "Name")
    data = [
      %{
        code: "F",
        type: "sample",
        name: "updated",
        description: "Facility Test"
      }

    ]
    [d1] = GenericLookUpSeeder.seed(data)
    assert d1.code == "F"
    assert d1.name == "updated"
  end
end
