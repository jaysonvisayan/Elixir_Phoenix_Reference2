defmodule Data.Repo.Migrations.AlterTablePractitionerRemovePrescriptionPeriodAndModifyPrescriptionInpatientOutpatient do
  use Ecto.Migration

  def up do
    alter table(:practitioners) do
      remove :prescription_period
    end
    execute "ALTER TABLE practitioners ALTER COLUMN prescription_inpatient TYPE integer USING (prescription_inpatient::integer);"
    execute "ALTER TABLE practitioners ALTER COLUMN prescription_outpatient TYPE integer USING (prescription_inpatient::integer);"
  end

  def down do
    alter table(:practitioners) do
      add :prescription_period, :string
    end
    execute "ALTER TABLE practitioners ALTER COLUMN prescription_inpatient TYPE character varying(255) USING (prescription_inpatient::character varying(255));"
    execute "ALTER TABLE practitioners ALTER COLUMN prescription_outpatient TYPE character varying(255) USING (prescription_inpatient::character varying(255));"
  end
end
