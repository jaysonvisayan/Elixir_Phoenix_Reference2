defmodule ApiWeb.RuvControllerTest do
  use ApiWeb.ConnCase

  describe "get_ruvs" do
    test "with valid params" do
      ruv = insert(:procedure, %{
        code: "P002"
      })
      insert(:ruv, code: ruv.code,  id: "fed52eff-f1be-4023-bb69-fc99bae2c971")
      conn = post(build_conn(), "/api/v1/ruvs/get_ruvs", %{page_number: 1, search_value: "", display_per_page: "5", sort_by: "code", order_by: "asc"})
      assert List.first(json_response(conn, 200)["ruvs"])["code"] == ruv.code
    end

    test "with invalid params/400" do
      insert(:ruv, id: "fed52eff-f1be-4023-bb69-fc99bae2c971")
      conn = post(build_conn(), "/api/v1/ruvs/get_ruvs", %{page_number: 1, search_value: "P002", display_per_page: "", sort_by: "code", order_by: "asc"})
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

  describe "get_ruv" do
    test "with valid params" do
      procedure = insert(:procedure, %{
        code: "10080",
        desc: "Incision and drainage"
      })

      room = insert(:room, %{
        code: "201",
        category: "WARD"
      })

      ruv = insert(:ruv, %{
        id: "fed52eff-f1be-4023-bb69-fc99bae2c972",
        code: procedure.code,
        unit: 12,
        updated_by: "jmramos"
      })

      ruv_multipliers = insert(:ruv_multipliers, %{
        id: "fed52eff-f1be-4023-bb69-fc99bae2c971",
        amount: 120.00,
        effective_date: DateTime.utc_now(),
        ruv_id: ruv.id,
        room_code: room.code
      })

      conn = post(build_conn(), "/api/v1/ruvs/get_ruv", %{code: "10080"})
      assert json_response(conn, 200)["code"] == ruv.code
    end

    test "non existing params/400" do
      conn = post(build_conn(), "/api/v1/ruvs/get_ruv", %{code: "1000"})
      assert json_response(conn, 400)["error"]["view"]  == "Bad request. Validation failed"
    end

    test "with empty params/400" do
      conn = post(build_conn(), "/api/v1/ruvs/get_ruv", %{code: ""})
      assert json_response(conn, 400)["errors"]["code"]  == "code Enter code"
    end
  end
end
