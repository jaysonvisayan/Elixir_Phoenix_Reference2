defmodule ApiWeb.RoomView do
  use ApiWeb, :view

  alias Data.{
    Schemas.Room,
    Schemas.RoomArchive
  }

  def render("download_rooms.json", %{result: result}) do
    %{
      url: result.url
    }
  end

  def render("rooms.json", %{result: rooms}) do
    %{
      rooms: rooms
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("room.json", %{result: room}) do
    facility = render_many(room.facility_room, ApiWeb.RoomView, "facility_room.json", as: :facility_room)
    %{
      code: room.code,
      category: room.category,
      hierarchy: room.hierarchy,
      status: room.status,
      version: room.version,
      inserted_by:  room.inserted_by,
      inserted_at: room.updated_by,
      updated_by: room.inserted_at,
      updated_at: room.updated_at,
      facility_room_total_count: Enum.count(room.facility_room),
      facility_rooms:  facility |> validate_facility_room()
    }
  end

  defp validate_facility_room([]), do: "No facility matched your search"
  defp validate_facility_room(frr), do: frr

  def render("facility_room.json", %{facility_room: facility_room}) do
    %{
      code: facility_room.facility_code,
      name: facility_room.facility_name,
      facility_room_type: facility_room.facility_room_type,
      facility_room_rate: facility_room.facility_room_rate
    }
  end

  def render("room_version.json", %{result: result}) do
    render_many(
      result.room_archives, ApiWeb.RoomView, "room_archives.json", as: :room_archive
    )
    ++
      [
        %{
          version: result.version,
          updated_by: result.updated_by,
          updated_at: result.updated_at,
          change_logs: "current"
        }
      ]
  end

  def render("room_archives.json", %{room_archive: room_archive}) do
    %{
      version: room_archive.version,
      updated_by: room_archive.updated_by,
      updated_at: room_archive.updated_at,
      change_logs: room_archive.change_logs
    }
  end

  def render("insert_room.json", %{result: result}) do
    %{
      code: result.code,
      category: result.category,
      hierarchy: result.hierarchy,
      inserted_at: result.inserted_at,
      inserted_by: result.inserted_by,
      status: result.status,
      updated_at: result.updated_at,
      updated_by: result.updated_by,
      version: result.version
    }
  end

  def render("room_version_detail.json", %{result: result}) do
    case result do
      %Room{} ->
        %{
          version: result.version,
          updated_by: result.updated_by,
          updated_at: result.updated_at,
          change_logs: "current"
        }

      %RoomArchive{} ->
        %{
          version: result.version,
          updated_by: result.updated_by,
          updated_at: result.updated_at,
          change_logs: result.change_logs
        }
    end
  end

  def render("update_room.json", %{result: room}) do
    %{
      code: room.code,
      category: room.category,
      hierarchy: room.hierarchy,
      status: room.status,
      version: room.version,
      inserted_by:  room.inserted_by,
      inserted_at: room.updated_by,
      updated_by: room.inserted_at,
      updated_at: room.updated_at
    }
  end

  def render("delete_room.json", %{result: room}) do
    %{
      code: room.code,
      category: room.category,
      hierarchy: room.hierarchy,
      status: room.status,
      version: room.version,
      updated_by: room.updated_by,
      updated_at: room.updated_at
    }
  end
end
