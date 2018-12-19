defmodule Data.Schemas.Practitioner do
  @moduledoc false

  use Data.Schema

  @primary_key {:code, :string, []}
  schema "practitioners" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :suffix, :string
    field :step, :string
    field :status, :string
    field :version, :string
    field :photo, :string
    field :birth_date, :date
    field :gender, :string
    field :specialization, :string
    field :sub_specialization, {:array, :string}
    field :prc_no, :string
    field :affiliated, :boolean
    field :effective_date, :date
    field :expiry_date, :date
    field :phic_accredited, :boolean
    # field :phic_accreditation_date, :date
    field :email, :string
    field :email2, :string
    field :exclusive, {:array, :string}
    field :vat_status, :string
    # field :prescription_period, :string
    field :tin, :string
    field :withholding_tax, :float
    field :mode_of_payment, :string
    field :mode_of_releasing, :string
    field :bank_name, :string
    field :bank_account_no, :integer
    field :xp_card_no, :integer
    field :payee_name, :string
    field :is_active, :boolean
    field :is_suspected, :boolean
    field :prescription_inpatient, :integer ## update from string to integer
    field :prescription_outpatient, :integer ## update from string to integer
    field :phic_accreditation_to, :date
    field :phic_accreditation_from, :date
    field :inserted_by, :string
    field :updated_by, :string

    has_many :practitioner_phones, Data.Schemas.PractitionerPhone, on_delete: :nothing
    has_many :practitioner_primaries, Data.Schemas.PractitionerPrimary, on_delete: :nothing

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :first_name,
      :middle_name,
      :last_name,
      :suffix,
      :step,
      :status,
      :version,
      :photo,
      :birth_date,
      :gender,
      :specialization,
      :sub_specialization,
      :prc_no,
      :affiliated,
      :effective_date,
      :expiry_date,
      :phic_accredited,
      # :phic_accreditation_date,
      :email,
      :email2,
      :exclusive,
      :vat_status,
      # :prescription_period,
      :tin,
      :withholding_tax,
      :mode_of_payment,
      :mode_of_releasing,
      :bank_name,
      :bank_account_no,
      :xp_card_no,
      :payee_name,
      :is_active,
      :is_suspected,
      :prescription_inpatient,
      :prescription_outpatient,
      :phic_accreditation_to,
      :phic_accreditation_from,
      :inserted_by,
      :updated_by
    ])
    |> validate_required([
      :code
    ], message: "is required")
  end

end
