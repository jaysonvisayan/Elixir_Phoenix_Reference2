defmodule Data.Repo.Migrations.ChangeFieldsOfFacilitiesTable do
  use Ecto.Migration

  def change do
    alter table(:facilities) do
      remove :prescription_clause
      add :prescription_clause_percentage, :integer
      add :prescription_clause_days, :integer
    end

    alter table(:facility_percent_days) do
      remove :ppd_id
      add :facility_ppd_id, references(:facility_ppds, column: :id, type: :binary_id, on_delete: :nothing)
    end
  end
end
