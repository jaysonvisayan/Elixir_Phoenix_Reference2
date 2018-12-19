defmodule Data.Repo.Migrations.CreateFacilityServiceFeesTables do
  use Ecto.Migration

  def change do
    create table(:facility_service_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_code, references(:facilities, column: :code, type: :string, on_delete: :nothing)
      add :coverage, :string
      add :payment_mode, :string
      add :service_fee, :string
      add :rate, :string

      timestamps()
    end
  end
end

