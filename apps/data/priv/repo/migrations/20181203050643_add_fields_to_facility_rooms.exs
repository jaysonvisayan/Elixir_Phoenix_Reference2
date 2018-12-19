defmodule Data.Repo.Migrations.AddFieldsToFacilityRooms do
  use Ecto.Migration

  def change do
    alter table(:facility_rooms) do
      add :room_type, :string
    end
  end
end
