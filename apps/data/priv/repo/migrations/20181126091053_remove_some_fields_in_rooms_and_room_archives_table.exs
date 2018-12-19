defmodule Data.Repo.Migrations.RemoveSomeFieldsInRoomsAndRoomArchivesTable do
  use Ecto.Migration

  def change do
    alter table(:room_archives) do
      remove :room_id
      remove :code
    end

    alter table(:rooms) do
      remove :id
    end
  end
end
