defmodule Data.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string
      add :procedure, {:array, :map}
      add :version, :string
      add :created_by, :string
      add :inserted_by, :string
      add :updated_by, :string

      timestamps()
    end
  end
end
