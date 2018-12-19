defmodule Data.Repo.Migrations.CreatePractitionerPrimarySchedules do
  use Ecto.Migration

  def up do
    create table(:practitioner_primary_schedules, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_primary_id, references(:practitioner_primaries, column: :id, type: :binary_id, on_delete: :nothing)
      add :day, :string
      add :room, :float
      add :time_from, :time
      add :time_to, :time
    end
  end

  def down do
    drop table(:practitioner_primary_schedules)
  end

end
