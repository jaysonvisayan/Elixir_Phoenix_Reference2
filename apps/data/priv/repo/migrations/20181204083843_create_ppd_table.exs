defmodule Data.Repo.Migrations.CreatePpdTable do
  use Ecto.Migration

  def change do
    create table(:ppds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_code, references(:facilities, column: :code, type: :string, on_delete: :nothing)
      add :coverage, :string
      add :subcoverage, :string
      add :discount_mode, :string

      timestamps()
    end
  end
end
