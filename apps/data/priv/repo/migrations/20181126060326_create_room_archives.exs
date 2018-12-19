defmodule Data.Repo.Migrations.CreateRoomArchives do
  use Ecto.Migration

  def change do
    create table(:room_archives, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, references(:rooms, type: :binary_id, on_delete: :nothing)
      add :code, :string
      add :category, :string
      add :hierarchy, :integer
      add :version, :string
      add :updated_by, :string
      add :change_logs, {:array, :string}

      timestamps()
    end
  end
end
