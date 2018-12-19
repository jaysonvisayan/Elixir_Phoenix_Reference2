defmodule Data.Schemas.PackageTest do
  use Data.SchemaCase, async: false

  alias Data.Schemas.Package

  describe "create changeset" do
    test "with valid attributes" do
      params = %{
        code: "PACKAGECODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        created_by: "masteradmin",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      changeset = Package.changeset(:create, %Package{}, params)

      assert changeset.valid? == true
    end

    test "with invalid attributes return validate required field" do
      params = %{
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        created_by: "masteradmin",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      changeset = Package.changeset(:create, %Package{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [code: {"is required", [validation: :required]}]
      assert Enum.count(changeset.errors) == 1
    end

    test "with invalid attributes returns validate length error" do
      params = %{
        code: "TESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODETESTCODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        created_by: "masteradmin",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      changeset = Package.changeset(:create, %Package{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [code:
                                  {"Code must be at most 50 characters",
                                    [count: 50, validation: :length, kind: :max]}]
      assert Enum.count(changeset.errors) == 1
    end

    test "with invalid attributes return validate format for code" do
      params = %{
        code: "test@#$sample%$@#",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        created_by: "masteradmin",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      changeset = Package.changeset(:create, %Package{}, params)

      assert changeset.valid? == false
      assert changeset.errors == [code:
                                  {"Code must have no special characters except for - _ and .",
                                    [validation: :format]}]
      assert Enum.count(changeset.errors) == 1
    end
  end
end

