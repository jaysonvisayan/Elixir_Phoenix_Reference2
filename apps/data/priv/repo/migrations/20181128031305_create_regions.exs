defmodule Data.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def up do
    create table(:regions, primary_key: false) do
      add :code, :string, primary_key: true
      add :region_name, :string
      add :island_group, :string
      add :updated_by, :string
      add :inserted_by, :string

      timestamps()
    end
  end

  def down do
    drop table(:regions)
  end
end
