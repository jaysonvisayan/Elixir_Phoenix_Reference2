defmodule Data.Repo.Migrations.UpdateRoomArchiveFields do
  use Ecto.Migration

  def change do
    alter table(:room_archives) do
      remove :updated_at
      remove :inserted_at
      add :updated_at, :utc_datetime
    end
  end
end
