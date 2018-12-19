defmodule Data.Tests.SequenceSeederTest do
  use Data.SchemaCase, async: false

  alias Data.Seeders.SequenceSeeder

  test "seed with new data" do
    data = [
      %{
        type: "facility_group_code",
        number: "1"
      }
    ]
    [d1] = SequenceSeeder.seed(data)
    assert d1.type == "facility_group_code"
  end

  test "seed with existing data" do
    insert(:sequence, type: "facility_group_code", number: "10")
    data = [
      %{
        type: "facility_group_code",
        number: "1"
      }

    ]
    [d1] = SequenceSeeder.seed(data)
    assert d1.number == "10" #Avoid reset sequence upon seed
  end

end
