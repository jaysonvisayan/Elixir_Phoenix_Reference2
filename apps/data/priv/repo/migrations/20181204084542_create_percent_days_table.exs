defmodule Data.Repo.Migrations.CreatePercentDaysTable do
  use Ecto.Migration

  def change do
    create table(:percent_days, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ppd_id, references(:ppds, type: :binary_id, on_delete: :nothing)
      add :percent, :integer
      add :days, :integer

      timestamps()
    end
  end
end
