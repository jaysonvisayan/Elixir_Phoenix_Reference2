defmodule Data.Repo.Migrations.CreatePractitionerPrimaries do
  use Ecto.Migration

 def up do
    create table(:practitioner_primaries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :practitioner_code, references(:practitioners, column: :code, type: :string, on_delete: :nothing)
      add :type, :string
      add :facility_code, :string
      add :status, :string
      add :affiliation_date, :date
      add :disaffiliation_date, :date
      add :mode_of_payment, :string
      add :credit_term, :string
      add :balance_biller, :string
      add :is_inpatient, :boolean
      add :is_outpatient, :boolean
      add :email, :string
      add :email2, :string
      add :is_coordinator, :boolean
      add :is_fixed_fee, :boolean
      add :fixed_fee, :float
      add :effective_date, :date
      add :expiry_date, :date
      add :is_regular, :boolean
      add :coordinator_fee, :float
      add :cp_clearance, :string
      add :cp_clearance_fee, :float
      add :inserted_by, :string
      add :updated_by, :string

      timestamps()

    end
  end

  def down do
    drop table(:practitioner_primaries)
  end


end
