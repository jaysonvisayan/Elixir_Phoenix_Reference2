defmodule ApiWeb.PackageControllerTest do
  use ApiWeb.ConnCase

  describe "create package" do
    test "with valid params returns created data" do
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

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 200)

      assert response["code"] == params.code
      assert response["name"] == params.name
      assert conn.status == 200
    end

    test "with invalid attributes returns validate required fields error" do
      params = %{}

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 400)

      assert response["errors"]["code"] == "Enter code"
      assert response["errors"]["name"] == "Enter name"
      assert conn.status == 400
    end

    test "with valid attributes returns constraint error" do
      insert(:package, code: "SAMPLEPACKAGECODE", name: "SAMPLEPACKAGENAME")
      params = %{
        code: "SAMPLEPACKAGECODE",
        name: "SAMPLEPACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 400)

      assert response["errors"]["code"] == "Code is already taken"
      assert conn.status == 400
    end

    test "with invalid attributes returns a validate length error" do
      params = %{
        code: "SAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODESAMPLEPACKAGECODE",
        name: "SAMPLEPACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 400)

      assert response["errors"]["code"] == "Code must be at most 50 characters"
      assert conn.status == 400
    end

    test "with invalid attributes returns a validate format error" do
      params = %{
        code: "test@#$%^&",
        name: "SAMPLEPACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 400)

      assert response["errors"]["code"] == "Code must have no special characters except for - _ and ."
      assert conn.status == 400
    end

    test "with invalid procedure codes returns not exist" do
      params = %{
        code: "PACKAGECODE",
        name: "PACKAGENAME",
        procedure: ["Test1", "Test2"],
        version: "1",
        status: "A",
        inserted_by: "masteradmin",
        updated_by: "masteradmin"
      }

      conn = post(build_conn(), "/api/v1/packages/create_package", params)
      response = json_response(conn, 400)

      assert response["errors"]["procedure"] == "Procedure code/s Test1, Test2 does not exist"
      assert conn.status == 400
    end
  end

  describe "view package" do
    test "with valid params" do
      insert(:package, code: "TESTCODE01", name: "Test", updated_by: "masteradmin", procedure: ["Test_01", "Test_02"])
      conn = post(build_conn(), "api/v1/packages/get_package",
                             %{
                               code: "TESTCODE01",
                               procedure: %{
                                 search_value: "TESTCODE01",
                                 page_number: "1",
                                 display_per_page: "10",
                                 sort_by: "code",
                                 order_by: "asc"
                               }
                             })
      assert json_response(conn, 200)
    end

    test "with invalid params/400" do
      insert(:miscellaneous, code: "TESTCODE0")
      conn = post(build_conn(), "api/v1/packages/get_package",
                             %{
                               code: ""
                             })
      assert json_response(conn, 400)["errors"]["code"] == "Enter code"
    end
  end

  describe "search packages" do
    test "with valid params" do
      package = insert(:package, code: "1")
      conn = post(
        build_conn(),
        "/api/v1/packages/get_packages",
        %{page_number: 1, search_value: "", display_per_page: "5", sort_by: "code", order_by: "asc"}
      )
      assert List.first(json_response(conn, 200)["packages"])["code"] == package.code
    end

    test "with invalid params/400" do
      insert(:package, code: "1")
      conn = post(
        build_conn(),
        "/api/v1/packages/get_packages",
        %{page_number: 1, search_value: "", display_per_page: "", sort_by: "code", order_by: "asc"}
      )
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end
end
