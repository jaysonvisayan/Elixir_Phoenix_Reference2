defmodule Data.Schemas.PractitionerPrimary do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreign_key_type :string
  schema "practitioner_primaries" do
    field :type, :string
    field :facility_code, :string
    field :status, :string
    field :affiliation_date, :date
    field :disaffiliation_date, :date
    field :mode_of_payment, :string
    field :credit_term, :string
    field :balance_biller, :string
    field :is_inpatient, :boolean
    field :is_outpatient, :boolean
    field :email, :string
    field :email2, :string
    field :is_coordinator, :boolean
    field :is_fixed_fee, :boolean
    field :fixed_fee, :float
    field :effective_date, :date
    field :expiry_date, :date
    field :is_regular, :boolean
    field :coordinator_fee, :boolean
    field :cp_clearance, :string
    field :inserted_by, :string
    field :updated_by, :string

    has_many :practitioner_phones, Data.Schemas.PractitionerPhone, on_delete: :delete_all
    has_many :practitioner_primary_rooms, Data.Schemas.PractitionerPrimaryRoom, on_delete: :delete_all
    has_many :practitioner_primary_specializations, Data.Schemas.PractitionerPrimarySpecialization, on_delete: :delete_all
    has_many :practitioner_primary_schedules, Data.Schemas.PractitionerPrimarySchedule, on_delete: :delete_all

    belongs_to :practitioner, Data.Schemas.Practitioner, foreign_key: :practitioner_code

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_code,
      :type,
      :facility_code,
      :status,
      :affiliation_date,
      :disaffiliation_date,
      :mode_of_payment,
      :credit_term,
      :balance_biller,
      :is_inpatient,
      :is_outpatient,
      :email,
      :email2,
      :is_coordinator,
      :is_fixed_fee,
      :fixed_fee,
      :effective_date,
      :expiry_date,
      :is_regular,
      :coordinator_fee,
      :cp_clearance,
      :inserted_by,
      :updated_by,
    ])
  end

end
