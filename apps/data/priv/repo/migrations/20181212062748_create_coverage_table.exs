defmodule Data.Repo.Migrations.CreateCoverageTable do
  use Ecto.Migration

  def change do
    create table(:coverages, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
