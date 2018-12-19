defmodule Data.Schemas.PackageContextTest do
  use Data.SchemaCase, async: false

  alias Data.{
    Contexts.PackageContext,
    Contexts.ValidationContext
  }

  @invalid_attrs %{}

  describe "validate params" do
    test "with valid attributes returns valid changeset" do
      insert(:procedure, code: "Test1", desc: "Test1", type: "CPT")
      insert(:procedure, code: "Test2", desc: "Test2", type: "CPT")

      params = %{
        code: "PACKAGECODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      {is_valid, changeset} = PackageContext.validate_params(:create, params)

      assert is_valid == true
      assert changeset.valid? == true
    end

    test "with valid attributes returns constraint error" do
      insert(:package, code: "PACKAGEcODE", name: "PACKAGENAME")
      insert(:procedure, code: "Test1", desc: "Test1", type: "CPT")
      insert(:procedure, code: "Test2", desc: "Test2", type: "CPT")

      params = %{
        code: "PACKAGECODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      {is_valid, changeset} = PackageContext.validate_params(:create, params)

      assert is_valid == false
      assert changeset.valid? == false
      assert changeset.errors == [code: {"Code is already taken", []}]
      assert Enum.count(changeset.errors) == 1
    end
  end

  describe "insert package" do
    test "with valid attributes creates a package" do
      insert(:procedure, code: "Test1", desc: "Test1", type: "CPT")
      insert(:procedure, code: "Test2", desc: "Test2", type: "CPT")

      params = %{
        code: "PACKAGECODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      package =
        :create
        |> PackageContext.validate_params(params)
        |> ValidationContext.valid_changeset()
        |> PackageContext.insert_package(:create)

      assert package.code == params.code
      assert package.name == params.name
      assert package.procedure == params.procedure
      assert package.version == params.version
      assert package.status == params.status
      assert package.inserted_by == params.inserted_by
      assert package.updated_by == params.updated_by
    end

    test "with invalid attributes returns error changeset" do
      package =
        :create
        |> PackageContext.validate_params(@invalid_attrs)
        |> ValidationContext.valid_changeset()
        |> PackageContext.insert_package(:create)

      {:error, changeset} = package

      assert changeset.valid? == false
      assert changeset.errors == [code: {"is required",
                                    [validation: :required]},
                                  name: {"is required",
                                    [validation: :required]},
                                  procedure: {"is required",
                                    [validation: :required]}]
    end
  end
end
