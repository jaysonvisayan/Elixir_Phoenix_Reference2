defmodule Data.Repo.Migrations.CreatePractitionerPrimarySpecializations do
  use Ecto.Migration

  def up do
    create table(:practitioner_primary_specializations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_primary_id, references(:practitioner_primaries, column: :id, type: :binary_id, on_delete: :nothing)
      add :specialization, :string
      add :fee, :float
    end
  end

  def down do
    drop table(:practitioner_primary_specializations)
  end

end
