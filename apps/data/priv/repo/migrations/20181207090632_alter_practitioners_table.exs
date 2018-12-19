defmodule Data.Repo.Migrations.AlterPractitionersTable do
  use Ecto.Migration

  def change do
    alter table(:practitioners) do
      add :is_active, :boolean
      add :is_suspected, :boolean
      add :prescription_inpatient, :string
      add :prescription_outpatient, :string
    end
  end
end
