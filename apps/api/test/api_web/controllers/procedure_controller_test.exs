defmodule ApiWeb.ProcedureControllerTest do
  use ApiWeb.ConnCase

  describe "get_procedures" do
    test "with valid params" do
      procedure = insert(:procedure, code: "1")
      conn = post(build_conn(), "/api/v1/procedures/get_procedures", %{page_number: 1, search_value: "", display_per_page: "5", sort_by: "code", order_by: "asc"})
      assert List.first(json_response(conn, 200)["procedures"])["code"] == procedure.code
    end

    test "with invalid params/400" do
      insert(:procedure, code: "1")
      conn = post(build_conn(), "/api/v1/procedures/get_procedures", %{page_number: 1, search_value: "", display_per_page: "", sort_by: "code", order_by: "asc"})
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

  describe "download_procedures" do
    # comments to prevent csv generation

    # test "with valid params" do
    #   insert(:procedure, code: "1", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
    #   insert(:procedure, code: "2", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
    #   conn = post(build_conn(), "/api/v1/procedures/download_procedures", %{search_value: "1"})
    #   assert json_response(conn, 200)["url"] =~ "http"
    # end

    # test "with blank search value" do
    #   insert(:procedure, code: "1", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
    #   insert(:procedure, code: "2", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
    #   conn = post(build_conn(), "/api/v1/procedures/download_procedures", %{search_value: ""})
    #   assert json_response(conn, 200)["url"] =~ "http"
    # end

    test "with invalid params" do
      insert(:procedure, code: "1", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
      conn = post(build_conn(), "/api/v1/procedures/download_procedures", %{test: "ohoho"})
      assert json_response(conn, 400)["errors"]["search_value"] == "search_value is not in the parameters"
    end

    test "when no results found" do
      insert(:procedure, code: "1", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
      insert(:procedure, code: "2", desc: "123", type: "CPT", standard: "hehe", rate_type: "HAHA")
      conn = post(build_conn(), "/api/v1/procedures/download_procedures", %{search_value: "ZZ"})
      assert json_response(conn, 412)["message"] == "No results found"
    end
  end
end
