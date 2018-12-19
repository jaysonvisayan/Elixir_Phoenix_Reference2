defmodule ApiWeb.PractitionerControllerTest do
  use ApiWeb.ConnCase

  describe "get_practitioners" do
    test "with valid params" do
      p = insert(:practitioners, code: "1", first_name: "first_name", middle_name: "middle_name", last_name: "last_name", specialization: "Internal Medicine",  status: "Active")
      conn = post(
        build_conn(),
        "/api/v1/practitioners/get_practitioners",
        %{
          page_number: 1,
          search_value: "first_name",
          display_per_page: "5",
          sort_by: "code",
          order_by: "desc"
        }
      )
      assert List.first(json_response(conn, 200)["practitioners"])["code"] == p.code
    end

    test "with invalid params/400 returns validate required" do
      conn = post(build_conn(), "/api/v1/practitioners/get_practitioners", %{page_number: 1, search_value: "", sort_by: "code", order_by: "asc"})
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end
end
