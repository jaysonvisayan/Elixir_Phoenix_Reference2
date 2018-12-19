defmodule ApiWeb.DiagnosisControllerTest do
  use ApiWeb.ConnCase

  describe "download_diagnoses" do
    # comments to prevent csv generation

    # test "with valid params" do
    #  insert(:diagnosis, code: "A01", desc: "TEST123", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: false, standard: "AMA")
    #   insert(:diagnosis, code: "A02", desc: "TEST1231", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
    #   insert(:diagnosis, group_code: "A0", code: "A03", group_desc: "TEST", standard: "AMA", is_dreaded: true, is_congenital: false)
    #   conn = post(build_conn(), "/api/v1/diagnoses/download_diagnoses", %{search_value: "A0"})
    #   assert json_response(conn, 200)["url"] =~ "http"
    # end

    # test "with blank search value" do
    #   insert(:diagnosis, code: "A01", desc: "TEST123", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
    #   insert(:diagnosis, code: "A02", desc: "TEST1231", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
    #   conn = post(build_conn(), "/api/v1/diagnoses/download_diagnoses", %{search_value: ""})
    #   assert json_response(conn, 200)["url"] =~ "http"
    # end

    test "with invalid params" do
      insert(:diagnosis, code: "A01", desc: "TEST123", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
      conn = post(build_conn(), "/api/v1/diagnoses/download_diagnoses", %{test: "haha"})
      assert json_response(conn, 400)["errors"]["search_value"] == "search_value is not in the parameters"
    end

    test "when no results found" do
      insert(:diagnosis, code: "A01", desc: "TEST123", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
      insert(:diagnosis, code: "A02", desc: "TEST1231", group_code: "A0", group_desc: "TEST", is_dreaded: true, is_congenital: true, standard: "AMA")
      conn = post(build_conn(), "/api/v1/diagnoses/download_diagnoses", %{search_value: "ZZ"})
      assert json_response(conn, 412)["message"] == "No results found"
    end
  end

  describe "get_diagnoses" do
    test "with valid params" do
      diagnosis = insert(:diagnosis, code: "1")
      conn = post(build_conn(), "/api/v1/diagnoses/get_diagnoses", %{
        page_number: 1,
        search_value: "",
        display_per_page: 5,
        sort_by: "code",
        order_by: "asc"
      })
      assert List.first(json_response(conn, 200)["diagnoses"])["code"] == diagnosis.code
    end

    test "with invalid params/400" do
      insert(:diagnosis, code: "1")
      conn = post(build_conn(), "/api/v1/diagnoses/get_diagnoses", %{
        page_number: 1,
        search_value: "",
        display_per_page: "",
        sort_by: "code",
        order_by: "asc"
      })
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

end
