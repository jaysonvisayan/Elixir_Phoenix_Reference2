defmodule Data.Repo.Migrations.AlterPractitionerPhones do
  use Ecto.Migration

  def change do
    alter table(:practitioner_phones) do
      add :practitioner_corporate_id, references(:practitioner_corporates, column: :id, type: :binary_id, on_delete: :nothing)
      add :practitioner_primary_id, references(:practitioner_primaries, column: :id, type: :binary_id, on_delete: :nothing)
    end
  end
end
