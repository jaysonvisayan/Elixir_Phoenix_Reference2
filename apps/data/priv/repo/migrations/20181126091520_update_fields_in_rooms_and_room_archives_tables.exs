defmodule Data.Repo.Migrations.UpdateFieldsInRoomsAndRoomArchivesTables do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      modify :code, :string, primary_key: true
    end
    create unique_index(:rooms, [:code])

    alter table(:room_archives) do
      add :room_code, references(:rooms, column: :code, type: :string, on_delete: :nothing)
    end
  end
end
