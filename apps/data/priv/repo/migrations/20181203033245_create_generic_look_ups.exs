defmodule Data.Repo.Migrations.CreateGenericLookUps do
  use Ecto.Migration

  def change do
    create table(:generic_look_ups, primary_key: false) do
      add :code, :string, primary_key: true
      add :type, :string, primary_key: true
      add :name, :string
      add :description, :string

      timestamps()
    end
  end
end
