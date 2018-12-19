defmodule Data.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :category, :string
      add :hierarchy, :integer
      add :status, :string
      add :version, :string
      add :created_by, :string
      add :updated_by, :string

      timestamps()
    end
  end
end
