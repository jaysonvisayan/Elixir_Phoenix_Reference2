defmodule Data.Repo.Migrations.CreateRuv do
  use Ecto.Migration

  def up do
    create table(:ruvs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, references(:procedures, column: :code, type: :string)
      add :unit, :integer
      add :version, :string
      add :status, :string
      add :inserted_by, :string
      add :updated_by, :string

      timestamps()
    end
  end

  def down do
    drop table(:ruvs)
  end
end
