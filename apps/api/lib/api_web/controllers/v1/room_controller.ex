defmodule ApiWeb.V1.RoomController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.RoomContext,
    Contexts.UtilityContext,
    Contexts.ValidationContext,
  }

  alias ApiWeb.{
    ErrorView,
    RoomView
  }

  def get_rooms(conn, params) when is_map(params) do
    :search
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.get_rooms(:search)
    |> return_result("rooms.json", conn, :search)
  end

  def get_rooms(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def download_rooms(conn, params) when is_map(params) do
      :download
      |> RoomContext.validate_params(params)
      |> ValidationContext.valid_changeset()
      |> RoomContext.get_rooms(:download)
      |> UtilityContext.generate_csv([
        "Room Code",
        "Room Category",
        "Room Hierarchy",
        "Last Updated",
        "Updated By"
      ], "Rooms")
      |> UtilityContext.upload_to_s3(conn)
      |> return_result("download_rooms.json", conn, :download)
  end

  def download_rooms(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  defp return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  def get_room(conn, params) when is_map(params) do
    :view
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.get_room()
    |> RoomContext.get_room_facilities()
    |> return_result("room.json", conn, :view)
  end

  def get_room(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn, :search)

  defp return_result(nil, _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(RoomView)
    |> render("error.json", error: "Room not found!")
  end

  defp return_result({:error, changeset}, _, conn, :create) do
    conn
    |> put_status(400)
    |> put_view(RoomView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset, :create))
  end

  defp return_result({:error, changeset}, _, conn, :update) do
    conn
    |> put_status(400)
    |> put_view(RoomView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset, :room_update))
  end

  defp return_result({:error, changeset}, _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(RoomView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  defp return_result([], _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(RoomView)
    |> render("error.json", error: "No room matched your search")
  end

  defp return_result({:error_message, message}, _, conn, _) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  defp return_result(result, json_name, conn, _) do
    conn
    |> put_status(200)
    |> put_view(RoomView)
    |> render(json_name, result: result)
  end

  def get_room_versions(conn, params) do
    :version
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.get_room_versions()
    |> return_result("room_version.json", conn, :version)
  end

  def create_room(conn, params) do
    map = %{
      "inserted_by" => "masteradmin",
      "updated_by" => "masteradmin",
      "version" => "1",
      "status" => "Active"
    }

    params =
      params
      |> Map.merge(map)

    :create
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.insert_rooms(:create)
    |> return_result("insert_room.json", conn, :create)

  end

  def create_draft_room(conn, params) when is_map(params) do
    map = %{
      "inserted_by" => "masteradmin",
      "updated_by" => "masteradmin",
      "version" => "1",
      "status" => "Draft"
    }

    params =
      params
      |> Map.merge(map)

    :create_draft
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.insert_rooms(:create_draft)
    |> return_result("insert_room.json", conn, :create)
  end

  def update_room(conn, params) when is_map(params) do
    :update
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.insert_version()
    |> RoomContext.update_room(:update)
    |> return_result("update_room.json", conn, :update)
  end

  def update_room(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn, :update)

  def get_room_version_details(conn, params) do
    :version_details
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.room_version_detail_result()
    |> return_result("room_version_detail.json", conn, :version_details)
  end

  def delete_room(conn, params) do
    map = %{
      "status" => "Deleted",
      "updated_by" => "masteradmin"
    }
    params =
      params
      |> Map.merge(map)
    :delete
    |> RoomContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RoomContext.update_room(:delete)
    |> return_result("delete_room.json", conn, :delete)
  end

  def delete_room(conn, params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

end
