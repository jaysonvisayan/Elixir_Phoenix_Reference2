defmodule ApiWeb.RoomControllerTest do
  use ApiWeb.ConnCase

  setup do
    room = insert(:room, code: "MMC_R201", version: "3", updated_by: "masteradmin")

    [room_archive1, room_archive2] = [
      insert(
        :room_archive,
        room_code: room.code,
        version: "1",
        change_logs: [
          "Room category updated from public to private.",
          "Room hierarchy updated from 1 to 2."
        ],
        updated_by: "masteradmin",
        updated_at: DateTime.utc_now()
      ),
      insert(
        :room_archive,
        room_code: room.code,
        version: "2",
        change_logs: [
          "Room category updated from private to semi-private.",
          "Room hierarchy updated from 2 to 3."
        ],
        updated_by: "masteradmin",
        updated_at: DateTime.utc_now()
      )
    ]
    {:ok, %{room: room, room_archive1: room_archive1, room_archive2: room_archive2}}
  end

  describe "get_rooms" do
    test "with valid params" do
      conn = post(
        build_conn(),
        "/api/v1/rooms/get_rooms",
        %{
          page_number: 1,
          search_value: "",
          display_per_page: "5",
          sort_by: "code",
          order_by: "desc"
        }
      )
      assert List.first(json_response(conn, 200)["rooms"])["code"] =~ "MM"
  end

    test "with invalid params/400" do
      insert(:room, code: "1")
      conn = post(
        build_conn(),
        "/api/v1/rooms/get_rooms",
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

  describe "download_rooms" do
    # comments download until upload to google is done

    # test "with valid params" do
    #   rooms = insert(:room, code: "10080", category: "TEST123", hierarchy: "1", updated_by: "masteradmin")
    #   insert(:room, code: "1080", category: "TEST1234", hierarchy: "2", updated_by: "masteradmin")
    #   insert(:room, code: "180", category: "TEST12345", hierarchy: "3", updated_by: "masteradmin")
    #   conn = post(build_conn(), "/api/v1/rooms/download_rooms", %{search_value: "100"})
    #   assert Map.has_key?(json_response(conn, 200), "url")
    # end

    # test "with invalid params" do
    #   insert(:room, code: "10080", category: "TEST123", hierarchy: "1", updated_by: "masteradmin")
    #   conn = post(build_conn(), "/api/v1/rooms/download_rooms", %{test: "hehe"})
    #   assert json_response(conn, 400)["errors"]["search_value"] == "search_value is not in the parameters"
    # end

    # test "no results found" do
    #   insert(:room, code: "10080", category: "TEST123", hierarchy: "1", updated_by: "masteradmin")
    #   conn = post(build_conn(), "/api/v1/rooms/download_rooms", %{search_value: "gksdfjgh"})
    #   assert json_response(conn, 400)["message"] == "No results found"
    # end
  end

  describe "get_room_versions" do
    test "with valid params", %{room: room, room_archive1: room_archive1, room_archive2: room_archive2} do
      conn = post(build_conn(), "/api/v1/rooms/get_room_versions", %{code: "MMC_R201"})
      assert json_response(conn, 200)
      assert conn |> json_response(200) |> Enum.count() == 3
      assert conn |> json_response(200) |> Enum.map(fn(x) -> Map.take(x, ["version"]) end)
        ==
      [%{"version" => room_archive1.version}, %{"version" => room_archive2.version}, %{"version" => room.version}]
    end

    test "with invalid params, test for blank params" do
      conn = post(build_conn(), "/api/v1/rooms/get_room_versions", %{})
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]  == %{"code" => "code can't be blank"}
    end

    test "with invalid params, if test code value == integer value" do
      conn = post(build_conn(), "/api/v1/rooms/get_room_versions", %{code: 99_999})
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]  == %{"code" => "code is invalid"}
    end

    test "with invalid params, if code is not existing" do
      conn = post(build_conn(), "/api/v1/rooms/get_room_versions", %{code: "MMC_R201_not_existing"})
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["code"] == "code is not existing!"
    end

    test "with lowercase scenario, lowercase data input", %{
      room: room,
      room_archive1: room_archive1,
      room_archive2: room_archive2
    }
    do
      conn = post(build_conn(), "/api/v1/rooms/get_room_versions", %{code: "mmc_R201"})
      assert json_response(conn, 200)
      assert conn |> json_response(200) |> Enum.count() == 3
      assert conn |> json_response(200) |> Enum.map(fn(x) -> Map.take(x, ["version"]) end)
        ==
      [%{"version" => room_archive1.version}, %{"version" => room_archive2.version}, %{"version" => room.version}]
    end
  end

  describe "get_room" do
    test "with valid params" do
      room = insert(:room, code: "11", category: "test")
      insert(:facility, code: "11", name: "test")
      insert(:facility_room, room_code: "11", facility_code: "11",  room_type: "Suite", room_rate: "123")
      conn = post(build_conn(), "/api/v1/rooms/get_room", %{code: "11", facility_room: %{search_value: "1", page_number: 1, display_per_page: "5", sort_by: "facility_code", order_by: "asc"}})
      assert json_response(conn, 200)["code"] == room.code
      assert json_response(conn, 200)["category"] == room.category
      assert json_response(conn, 200)["status"] == room.status
      assert json_response(conn, 200)["version"] == room.version
    end

    test "with invalid params/400" do
      insert(:room, code: "", category: "test")
      conn = post(build_conn(), "/api/v1/rooms/get_room", %{code: "11", facility_room: %{search_value: "", page_number: "2", display_per_page: "", sort_by: "facility_code"}})
      assert json_response(conn, 400)["errors"]["display_per_page"] == "Enter display_per_page"
    end
  end

  describe "update_room" do
    test "with valid params" do
      insert(:room, code: "123", category: "category", hierarchy: 10, version: "1")
      conn = post(build_conn(), "/api/v1/rooms/update_room", %{code: "123", category: "test", hierarchy: 1})
      assert json_response(conn, 200)
      assert json_response(conn, 200)["category"] == "test"
      assert json_response(conn, 200)["hierarchy"] == 1
    end

    test "with invalid params" do
      insert(:room, code: "123", category: "category", hierarchy: 10, version: "1")
      conn = post(build_conn(), "/api/v1/rooms/update_room", %{code: "", category: "test", hierarchy: 1})
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["code"] == "Enter Room code"
    end

    test "with valid params and code not found" do
      insert(:room, code: "123", category: "category", hierarchy: 10, version: "1")
      conn = post(build_conn(), "/api/v1/rooms/update_room", %{code: "12", category: "test", hierarchy: 1})
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["code"] == "Room code not found!"
    end
  end

  describe "create_rooms" do
    test "with valid params" do
      params = %{
        code: "TestingRoom",
        category: "Ward",
        hierarchy: "12"
      }
      conn = post(build_conn(), "/api/v1/rooms/create_room", params)
      assert json_response(conn, 200)
    end

    test "with invalid params" do
      params = %{
        code: "TestingRoom",
        category: "Ward",
        hierarchy: "12rc"
      }
      conn = post(build_conn(), "/api/v1/rooms/create_room", params)
      assert json_response(conn, 400)
    end
  end

  describe "create_draft_room" do
    test "with valid params draft" do
      params = %{
        code: "TestingRoomDraft",
        category: "Test123"
      }
      conn = post(build_conn(), "/api/v1/rooms/create_draft_room", params)
      assert json_response(conn, 200)
    end

    test "with invalid params draft" do
      params = %{
        code: "TestingRoom?"
      }
      conn = post(build_conn(), "/api/v1/rooms/create_draft_room", params)
      assert json_response(conn, 400)
    end
  end

  describe "get_room_version_details" do
    test "with valid params, (room_code == MMC_R201) and (version == 1), return 200", %{
      room: _room,
      room_archive1: room_archive1,
      room_archive2: _room_archive2
    }
    do
      params = %{
        code: "MMC_R201",
        version: "1"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 200)
      assert json_response(conn, 200)["version"] == room_archive1.version
      assert json_response(conn, 200)["change_logs"] == room_archive1.change_logs
    end

    test "with valid params, (room_code == MMC_R201) and (version == 2), return 200", %{
      room: _room,
      room_archive1: _room_archive1,
      room_archive2: room_archive2
    }
    do
      params = %{
        code: "MMC_R201",
        version: "2"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 200)
      assert json_response(conn, 200)["version"] == room_archive2.version
      assert json_response(conn, 200)["change_logs"] == room_archive2.change_logs
    end

    test "with valid params, (room_code == MMC_R201) and (version == 3), return 200", %{
      room: room,
      room_archive1: _room_archive1,
      room_archive2: _room_archive2
    }
    do
      params = %{
        code: "MMC_R201",
        version: "3"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      json_response(conn, 200)
      assert json_response(conn, 200)["version"] == room.version
      assert json_response(conn, 200)["change_logs"] == "current"
    end

    test "with lowercase room_code params, (room_code == mmc_R201) and (version == 1), return 200", %{
      room: _room,
      room_archive1: room_archive1,
      room_archive2: _room_archive2
    }
    do
      params = %{
        code: "mmc_R201",
        version: "1"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 200)
      assert json_response(conn, 200)["version"] == room_archive1.version
      assert json_response(conn, 200)["change_logs"] == room_archive1.change_logs
    end

    test "with invalid params, (room_code == existing) and (version not existing)" do
      params = %{
        code: "MMC_R201",
        version: "0"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["version"] == "version is not existing!"
    end

    test "with invalid params, (room_code == not existing) and (version not existing)" do
      params = %{
        code: "MMC_XXXXXX",
        version: "0"
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["code"] == "code is not existing!"
    end

    test "with invalid params, (room == MMC_R201) and (version == null)" do
      params = %{
        code: "MMC_R201",
        version: ""
      }
      conn = post(build_conn(), "/api/v1/rooms/get_room_version_details", params)
      assert json_response(conn, 400)
      assert json_response(conn, 400)["errors"]["version"] == "version can't be blank"

    end
  end

  describe "delete_room" do
    test "with valid params delete" do
      insert(:room, code: "test_delete", category: "category", hierarchy: 10, version: "1", status: "Active", inserted_by: "masteradmin", updated_by: "masteradmin")
      params = %{
        code: "test_delete"
      }
      conn = post(build_conn(), "/api/v1/rooms/delete_room", params)
      assert json_response(conn, 200)
      assert json_response(conn, 200)["status"] == "Deleted"
    end

    test "with invalid params delete" do
      room = insert(:room, code: "test_delete", category: "category", hierarchy: 10, version: "1", status: "Active")
      facility = insert(:facility, code: "11", name: "test")
      insert(:facility_room, room_code: room.code , facility_code: facility.code,  room_type: "Suite", room_rate: "123")
      params = %{
        code: "test_delete"
      }
      conn = post(build_conn(), "/api/v1/rooms/delete_room", params)
      assert json_response(conn, 400)["errors"]["error"] == "Room cannot be deleted, already attached in facilities"
    end
  end
end
