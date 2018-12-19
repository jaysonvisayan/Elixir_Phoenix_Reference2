defmodule Data.Repo.Migrations.AlterPractitionerPhonesType do
  use Ecto.Migration

  def change do
    alter table(:practitioner_phones) do
      modify :area_code, :string
      modify :number, :string
      modify :local, :string
    end
  end
end
