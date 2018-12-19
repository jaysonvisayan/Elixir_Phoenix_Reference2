defmodule Data.Repo.Migrations.AlterPractitionerTableAddPhicDateFromAndDateTo do
  use Ecto.Migration

  def change do
    alter table(:practitioners) do
      add :phic_accreditation_to, :date
      add :phic_accreditation_from, :date
    end
  end
end
