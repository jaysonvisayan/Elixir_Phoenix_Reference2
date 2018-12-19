defmodule Data.Repo.Migrations.CreatePractitioner do
  use Ecto.Migration

  def up do
    create table(:practitioners, primary_key: false) do
      add :code, :string, primary_key: true
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :suffix, :string
      add :step, :string
      add :status, :string
      add :version, :string
      add :photo, :string
      add :birth_date, :date
      add :gender, :string
      add :specialization, :string
      add :sub_specialization, {:array, :string}
      add :prc_no, :string
      add :affiliated, :boolean
      add :effective_date, :date
      add :expiry_date, :date
      add :phic_accredited, :boolean
      add :phic_accreditation_date, :date
      add :email, :string
      add :email2, :string
      add :exclusive, :string
      add :vat_status, :string
      add :prescription_period, :string
      add :tin, :string
      add :withholding_tax, :float
      add :mode_of_payment, :string
      add :mode_of_releasing, :string
      add :bank_name, :string
      add :bank_account_no, :integer
      add :xp_card_no, :integer
      add :payee_name, :string
      add :inserted_by, :string
      add :updated_by, :string

      timestamps()

    end
  end

  def down do
    drop table(:practitioner)
  end
end
