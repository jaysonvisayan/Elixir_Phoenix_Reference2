defmodule Data.Repo.Migrations.AddFieldsToFacilities do
  use Ecto.Migration

  def change do
    alter table(:facilities) do
      add :photo, :string
      add :type, :string
      add :category, :string
      add :license_name, :string
      add :affiliation_date, :date
      add :disaffiliation_date, :date
      add :website, :string
      add :with_incremental, :boolean
      add :cut_off_time, :time
      add :phic_accreditation_from, :date
      add :phic_accreditation_to, :date
      add :phic_accreditation_no, :string
      add :address_line_1, :string
      add :address_line_2, :string
      add :city, :string
      add :province, :string
      add :region, :string
      add :country, :string
      add :postal_code, :string
      add :latitude, :string
      add :longitude, :string
      add :tin, :string
      add :vat_status, :string
      add :prescription_term, :string
      add :prescription_clause, :string
      add :credit_term, :string
      add :credit_limit, :string
      add :bank_charge, :decimal
      add :withholding_tax, :decimal
      add :balance_biller, :boolean
      add :authorization_form, :string
      add :payment_mode, :string
      add :releasing_mode, :string
      add :bank_name, :string
      add :bank_account_no, :string
      add :payee_name, :string
      add :number_of_beds, :integer
      add :bond, :integer
      add :exclusive, {:array, :string}
      add :gross_bill, :boolean
      add :effective_date, :date
      add :step, :integer
      add :status, :string
      add :inserted_by, :string
      add :updated_by, :string
    end
  end
end
