defmodule Data.Repo.Migrations.RemoveSomeFieldsInFacilityRooms do
  use Ecto.Migration

  def change do
    alter table(:facility_rooms) do
      remove :room_name
    end
  end
end
