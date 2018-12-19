defmodule Data.Repo.Migrations.CreateSequenceTable do
  use Ecto.Migration

  def up do
    create table(:sequences, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string
      add :type, :string

      timestamps()
    end
  end

  def down do
    drop table(:sequences)
  end
end
