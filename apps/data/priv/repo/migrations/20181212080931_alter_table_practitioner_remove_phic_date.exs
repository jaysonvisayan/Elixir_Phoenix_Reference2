defmodule Data.Repo.Migrations.AlterTablePractitionerRemovePhicDate do
  use Ecto.Migration

  def up do
    alter table(:practitioners) do
      remove :phic_accreditation_date
    end
  end

  def down do
    alter table(:practitioners) do
      add :phic_accreditation_date, :date
    end
  end
end
