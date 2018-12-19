defmodule ApiWeb.MiscellaneousControllerTest do
    use ApiWeb.ConnCase
    @moduledoc """

    """
    describe "get miscellany" do
        test "with valid params" do
            miscellaneous = insert(:miscellaneous, code: "1")
            conn = post(build_conn(), "/api/v1/miscellany/get_miscellany",
            %{
             page_number: 1,
             search_value: "",
             display_per_page: 5,
             sort_by: "code",
             order_by: "asc"
            })
          assert List.first(json_response(conn, 200)["miscellany"])["code"] == miscellaneous.code
        end

        test "with invalid params/400" do
            insert(:miscellaneous, code: "1")
            conn = post(build_conn(), "/api/v1/miscellany/get_miscellany",
            %{
             page_number: 1,
             search_value: "",
             display_per_page: "",
             sort_by: "code",
             order_by: "asc"
            })
            assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
        end
    end

  describe "download_miscellaneous" do
    # comments download until upload to google is done

    # test "with valid params" do
    #   miscellany = insert(:miscellaneous, code: "Test1", description: "TestDescription", max_price: "100", updated_by: "masteradmin")
    #   insert(:miscellaneous, code: "Test12", description: "TestDescription", max_price: "100", updated_by: "masteradmin")
    #   insert(:miscellaneous, code: "Test123", description: "TestDescription", max_price: "100", updated_by: "masteradmin")
    #   conn = post(build_conn(), "/api/v1/download_miscellany", %{search_value: "test"})
    #    assert Map.has_key?(json_response(conn, 200), "url")
    # end

    test "with invalid params" do
      insert(:miscellaneous, code: "Test1234", description: "TestDescription", max_price: "1000", updated_by: "masteradmin")
      conn = post(build_conn(), "/api/v1/miscellany/download_miscellany", %{test: "egul"})
      assert json_response(conn, 400)["errors"]["search_value"] == "search_value is not in the parameters"
    end

    test "no results found" do
      insert(:miscellaneous, code: "Test12345", description: "TestDescription", max_price: "1000", updated_by: "masteradmin")
      conn = post(build_conn(), "/api/v1/miscellany/download_miscellany", %{search_value: "cvmbcb"})
      assert json_response(conn, 412)["message"] == "No results found"
    end
  end

  describe "get miscellaneous versions" do
    test "with valid params" do
      m = insert(:miscellaneous, code: "Code", version: "1", updated_by: "Juan Dela Cruz")
      insert(:miscellaneous_archive,
             version: "1",
             max_price: 1,
             updated_by: "Juan Dela Cruz",
             miscellaneous_code: m.code,
             change_logs: [
               "Miscellaneous description updated from previous to recent.",
               "Miscellaneous maximum price updated from 10.00 to 100.00."
             ])

      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_versions", %{code: "code"})

      refute Enum.empty?(json_response(conn, 200))
    end

    test "with invalid params/400" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_versions", %{})

      assert json_response(conn, 400)["errors"]["code"] == "Enter code"
    end

    test "with invalid params/400 (Not existing)" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_versions", %{code: "Not Existing"})

      assert json_response(conn, 400)["errors"]["code"] == "Code not existing"
    end
  end

  describe "get miscellaneous versions details" do
    test "with valid params" do
      m = insert(:miscellaneous, code: "CoDe", version: "1", updated_by: "Juan Dela Cruz")
      insert(:miscellaneous_archive, miscellaneous_code: "CoDe", version: "1", updated_by: "Juan Dela Cruz")

      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{code: "CODE", version: "1"})

      assert json_response(conn, 200)["miscellany"]["item_code"] == m.code
    end

    test "with invalid params/400 (Code and Version)" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{})

      assert json_response(conn, 400)["errors"]["code"] == "Enter code"
      assert json_response(conn, 400)["errors"]["version"] == "Enter version"
    end

    test "with invalid params/400 (Code)" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{version: "1"})

      assert json_response(conn, 400)["errors"]["code"] == "Enter code"
      refute json_response(conn, 400)["errors"]["version"] == "Enter version"
    end

    test "with invalid params/400 (Version)" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{code: "1"})

      refute json_response(conn, 400)["errors"]["code"] == "Enter code"
      assert json_response(conn, 400)["errors"]["version"] == "Enter version"
    end

    test "with invalid params/400 (Code not existing)" do
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{code: "2", version: "1"})

      assert json_response(conn, 400)["errors"]["code"] == "Code not existing"
    end

    test "with invalid params/400 (Version not existing)" do
      insert(:miscellaneous, code: "1", version: "1", updated_by: "Juan Dela Cruz")
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{code: "1", version: "0"})

      assert json_response(conn, 400)["errors"]["version"] == "Version not existing"
    end

    test "with invalid params/400 with current version (Version not existing)" do
      insert(:miscellaneous, code: "1", version: "1", updated_by: "Juan Dela Cruz")
      conn = post(build_conn(), "/api/v1/miscellany/get_miscellaneous_version_details", %{code: "1", version: "1"})

      assert json_response(conn, 400)["errors"]["version"] == "Version not existing"
    end
  end

  describe "get miscellaneous" do
    test "with valid params" do
      insert(:miscellaneous, code: "TESTCODE0")
      conn = post(build_conn(), "api/v1/miscellany/get_miscellaneous",
                             %{
                               code: "TESTCODE0",
                               desc: "TESTDESC00",
                               maximum_price: 420.50,
                               status: "Active",
                               version: "1",
                               inserted_by: "masteradmin",
                               inserted_at: "01-01-2018",
                               updated_by: "user333",
                               updated_at: "01-01-2019"
                             })
      assert json_response(conn, 200)["item_code"] == "TESTCODE0"
    end

    test "with invalid params/400" do
      insert(:miscellaneous, code: "TESTCODE0")
      conn = post(build_conn(), "api/v1/miscellany/get_miscellaneous",
                             %{
                               code: ""
                             })
      assert json_response(conn, 400)["errors"]["code"] == "code entered is invalid"
    end
  end

  describe "create miscellany" do
    test "with valid params" do
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "TestMisc-001",
                               description: "This is a test misc",
                               max_price: "1000.00"
                             })
      assert json_response(conn, 200)
    end

    test "with invalid params/400 empty code" do
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "",
                               description: "This is a test misc",
                               max_price: "1000.00"
                             })
      assert json_response(conn, 400)
    end

    test "with invalid params/400 empty description" do
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "TestMisc-001",
                               description: "",
                               max_price: "1000.00"
                             })
      assert json_response(conn, 400)
    end

    test "with invalid params/400 empty max_price" do
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "TestMisc-001",
                               description: "This is a test misc",
                               max_price: ""
                             })
      assert json_response(conn, 400)
    end

    test "with invalid params/400 invalid max_price" do
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "TestMisc-001",
                               description: "This is a test misc",
                               max_price: "12hh"
                             })
      assert json_response(conn, 400)
    end

    test "with invalid params/400 repeated code with different capitalization" do
      insert(:miscellaneous, code: "TestMisc-001")
      conn = post(build_conn(), "/api/v1/miscellany/create_miscellaneous",
                             %{
                               code: "TestMisc-001",
                               description: "This is a test misc",
                               max_price: "123"
                             })
      assert json_response(conn, 400)
    end
  end

    describe "create draft miscellany" do
      test "with valid params" do
            conn = post(build_conn(), "/api/v1/miscellany/create_draft_miscellaneous",
                                   %{
                                     code: "TestMisc-001",
                                     description: "This is a test misc",
                                     max_price: "1000.00"
                                   })
             assert json_response(conn, 200)
        end

        test "with invalid params/400 empty code" do
            conn = post(build_conn(), "/api/v1/miscellany/create_draft_miscellaneous",
                                   %{
                                     code: "",
                                     description: "This is a test misc",
                                     max_price: "1000.00"
                                   })
            assert json_response(conn, 400)
        end

        test "with invalid params/400 max code" do
            conn = post(build_conn(), "/api/v1/miscellany/create_draft_miscellaneous",
                                   %{
                                     code: "TestMisc-001TestMisc-001TestMisc-001TestMisc-001TestMisc-001TestMisc-001TestMisc-001TestMisc-001TestMisc-001",
                                     description: "",
                                     max_price: "1000.00"
                                   })
            assert json_response(conn, 400)
        end

        test "with invalid params/400 max description" do
            conn = post(build_conn(), "/api/v1/miscellany/create_draft_miscellaneous",
                                   %{
                                     code: "TestMisc-001",
                                     description: "This is a test miscThis is a test miscThis is a test miscThis is a test miscThis is a test miscThis is a test misc",
                                     max_price: ""
                                   })
            assert json_response(conn, 400)
        end

        test "with invalid params/400 invalid max_price" do
            conn = post(build_conn(), "/api/v1/miscellany/create_draft_miscellaneous",
                                   %{
                                     code: "TestMisc-001",
                                     description: "This is a test misc",
                                     max_price: "12hh"
                                   })
            assert json_response(conn, 400)
        end
    end
end
