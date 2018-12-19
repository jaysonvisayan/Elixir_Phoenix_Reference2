defmodule Data.Repo.Migrations.CreatePractitionerCorporateSchedules do
  use Ecto.Migration

  def up do
    create table(:practitioner_corporate_schedules, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_corporate_id, references(:practitioner_corporates, column: :id, type: :binary_id, on_delete: :nothing)
      add :day, :string
      add :room, :string
      add :time_from, :time
      add :time_to, :time
    end
  end

  def down do
    drop table(:practitioner_corporate_schedules)
  end
end
