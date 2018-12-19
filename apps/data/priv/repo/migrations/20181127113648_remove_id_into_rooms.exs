defmodule Data.Repo.Migrations.RemoveIdIntoRooms do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      remove :id
    end
  end
end
