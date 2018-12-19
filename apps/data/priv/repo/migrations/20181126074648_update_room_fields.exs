defmodule Data.Repo.Migrations.UpdateRoomFields do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      remove :created_by
      add :inserted_by, :string
    end
  end
end
