defmodule Data.Repo.Migrations.CreateFacilityPercentDaysTable do
  use Ecto.Migration

  def change do
    drop_if_exists table(:service_fees)
    drop_if_exists table(:percent_days)
    drop_if_exists table(:ppds)
    create table(:facility_percent_days, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ppd_id, references(:facility_ppds, type: :binary_id, on_delete: :nothing)
      add :percent, :integer
      add :days, :integer

      timestamps()
    end
  end
end
