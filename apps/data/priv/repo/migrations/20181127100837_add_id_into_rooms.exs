defmodule Data.Repo.Migrations.AddIdIntoRooms do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :id, :binary_id, primary_key: false
    end
  end
end
