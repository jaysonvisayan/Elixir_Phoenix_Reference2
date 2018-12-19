defmodule Data.Repo.Migrations.CreatePractitionerCorporates do
  use Ecto.Migration

  def up do
    create table(:practitioner_corporates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_code, references(:practitioners, column: :code, type: :string, on_delete: :nothing)
      add :account_code, :string
      add :email, :string
      add :inserted_by, :string

      timestamps()
    end
  end

  def down do
    drop table(:practitioner_corporates)
  end
end
