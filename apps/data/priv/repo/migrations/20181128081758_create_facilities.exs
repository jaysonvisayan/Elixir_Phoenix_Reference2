defmodule Data.Repo.Migrations.CreateFacilites do
  use Ecto.Migration

  def up do
    create table(:facilities, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string
    end
  end

  def down do
    drop table(:facilities)
  end
end
