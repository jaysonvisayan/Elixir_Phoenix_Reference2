defmodule Data.Repo.Migrations.CreatePractitionerPhones do
  use Ecto.Migration

  def up do
    create table(:practitioner_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_code, references(:practitioners, column: :code, type: :string, on_delete: :nothing)
      add :type, :string
      add :country_code, :string
      add :area_code, :integer
      add :number, :integer
      add :local, :integer

      timestamps()
    end
  end

  def down do
    drop table(:practitioner_phones)
  end
end
