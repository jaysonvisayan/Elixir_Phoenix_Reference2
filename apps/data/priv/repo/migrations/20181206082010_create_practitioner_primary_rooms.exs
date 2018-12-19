defmodule Data.Repo.Migrations.CreatePractitionerPrimaryRooms do
  use Ecto.Migration

  def up do
    create table(:practitioner_primary_rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_primary_id, references(:practitioner_primaries, column: :id, type: :binary_id, on_delete: :nothing)
      add :type, :string
      add :rate, :string
    end
  end

  def down do
    drop table(:practitioner_primary_rooms)
  end
end
