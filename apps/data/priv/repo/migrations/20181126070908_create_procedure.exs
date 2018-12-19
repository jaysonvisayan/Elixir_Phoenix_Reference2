defmodule Data.Repo.Migrations.CreateProcedure do
  use Ecto.Migration

  def up do
    create table(:procedures, primary_key: false) do
      add :code, :binary_id, primary_key: true
      add :desc, :string
      add :type, :string
      add :standard, :string
      add :rate_type, :string

      timestamps()
    end
  end

  def down do
    drop table(:procedures)
  end
end
