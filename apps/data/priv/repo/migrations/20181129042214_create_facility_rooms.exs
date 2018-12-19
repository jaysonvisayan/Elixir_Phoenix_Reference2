defmodule Data.Repo.Migrations.CreateFacilityRooms do
  use Ecto.Migration

  def up do
    create table(:facility_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_code, references(:facilities, column: :code, type: :string)
      add :room_code, references(:rooms, column: :code, type: :string)
      add :room_name, :string
      add :room_rate, :decimal
    timestamps()
    end
  end

  def down do
    drop table(:facility_rooms)
  end
end


