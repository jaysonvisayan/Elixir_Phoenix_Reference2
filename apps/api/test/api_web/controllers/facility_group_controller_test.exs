defmodule ApiWeb.FacilityGroupControllerTest do

  use ApiWeb.ConnCase
  @moduledoc """

  """
  setup do
    sequence = insert(:sequence, type: "facility_group_code", number: "1")
    facility = insert(:facility, code: "1234")
    region = insert(:region, code: "R-I")
    facility_group =  insert(:facility_group, code: "Existing_code", name: "Existing_Name")
    {:ok, %{
      facility: facility,
      region: region,
      facility_group: facility_group,
      sequence: sequence
    }}
  end

  describe "get_facilities" do
    test "with valid params" do
      conn = post(
        build_conn(),
        "/api/v1/facilities/get_facilities",
        %{
          page_number: 1,
          search_value: "",
          display_per_page: 5,
          sort_by: "code",
          order_by: "desc"
        }
      )
      assert List.first(json_response(conn, 200)["facilities"])["code"] =~ "1234"
    end

    test "with invalid params/400" do
      insert(:room, code: "1")
      conn = post(
        build_conn(),
        "/api/v1/facilities/get_facilities",
        %{
          page_number: 1,
          search_value: "",
          display_per_page: "",
          sort_by: "code",
          order_by: "asc"
        }
      )
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

  describe "create_facility_group" do
    test "with valid params selecting type facility" do
      params = %{
        name: "F2yG-My222Health",
        description: "MyHealthHospitalsa()-ndClinicsasd",
        selecting_type: "F",
        facility_codes: ["1234"],
        regions: %{
          all_luzon: false,
          all_visayas: true,
          all_mindanao: false,
          regions: [
            "Region I",
            "Region I",
            "NCR",
            "NCR"
          ]
        }
      }
      conn = post(build_conn(), "/api/v1/facility_groups/create_facility_group", params)
      assert json_response(conn, 200)["name"] == "F2yG-My222Health"
    end

    test "with valid params selecting type region" do
      params = %{
        name: "F2yG-My222Health",
        description: "MyHealthHospitalsa()-ndClinicsasd",
        selecting_type: "R",
        facility_codes: ["1234"],
        regions: %{
          all_luzon: false,
          all_visayas: true,
          all_mindanao: false,
          regions: [
            "Region I"
          ]
        }
      }
      conn = post(build_conn(), "/api/v1/facility_groups/create_facility_group", params)
      assert json_response(conn, 200)["name"] == "F2yG-My222Health"
    end

    test "with invalid params selecting type region" do
      params = %{
        name: "F2yG-My222Health",
        description: "MyHealthHospitalsa()-ndClinicsasd",
        selecting_type: "R",
        facility_codes: ["1234"],
        regions: %{
          all_luzon: false,
          all_visayas: true,
          all_mindanao: false,
          regions: [
            "Region asd"
          ]
        }
      }
      conn = post(build_conn(), "/api/v1/facility_groups/create_facility_group", params)
      assert json_response(conn, 400)["errors"]["regions"] == "Region asd is invalid."
    end

    test "with invalid params selecting type facility" do
      params = %{
        name: "F2yG-My222Health",
        description: "MyHealthHospitalsa()-ndClinicsasd",
        selecting_type: "F",
        facility_codes: ["12374"],
      }
      conn = post(build_conn(), "/api/v1/facility_groups/create_facility_group", params)
      assert json_response(conn, 400)["errors"]["facility_code"] == "Facility Code 12374 does not exist."
    end
  end

  describe "get_facility_groups" do
    test "with valid params" do
      conn = post(build_conn(), "/api/v1/facility_groups/get_facility_groups",
                             %{page_number: 1,
                               search_value: "",
                               display_per_page: "5",
                               sort_by: "code",
                               order_by: "asc"}
      )
      assert List.first(json_response(conn, 200)["facility_groups"])["code"] == "Existing_code"
    end

    test "with invalid params/400" do
      insert(:facility_group, code: "FC-0001")
      conn = post(build_conn(), "/api/v1/facility_groups/get_facility_groups",
                             %{page_number: 1,
                               search_value: "",
                               display_per_page: "",
                               sort_by: "code",
                               order_by: "asc"}
                 )
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

  describe "get_facility_group" do

      test "test valid params" do
      insert(:facility_group, code: "FC-001")
        conn = post(build_conn(), "/api/v1/facility_groups/get_facility_group",
          %{
            code: "FC-001",
            name: "FC-Myhealth",
            description: "Myhealth hospitals and clinics",
            selecting_type: "Region",
            regions: %{
              all_luzon: "false",
              all_visayas: "true",
              all_mindanao: "true",
              regions: [
                "Region 1",
                "NCR"
              ]
            },
          })
        assert json_response(conn, 200)["code"] == "FC-001"
      end

      test "with invalid params/400" do
      insert(:facility_group, code: "FC-001")
        conn = post(build_conn(), "/api/v1/facility_groups/get_facility_group",
        %{
          code: ""
        })
        assert json_response(conn, 400)["errors"]["code"] == "code entered is invalid!"
      end

    end

end
