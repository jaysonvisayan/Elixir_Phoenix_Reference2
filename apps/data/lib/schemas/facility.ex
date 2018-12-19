defmodule Data.Schemas.Facility do
  @moduledoc false

  use Data.Schema
  use Arc.Ecto.Schema
  alias Ecto.Changeset
  alias Data.Contexts.{
    FacilityContext,
    UtilityContext
  }

  @primary_key {:code, :string, []}
  schema "facilities" do
    field :name, :string
    field :photo, :string
    field :type, :string
    field :category, :string
    field :license_name, :string
    field :affiliation_date, :date
    field :disaffiliation_date, :date
    field :website, :string
    field :with_incremental, :boolean
    field :cut_off_time, :time
    field :phic_accreditation_from, :date
    field :phic_accreditation_to, :date
    field :phic_accreditation_no, :string
    field :billing_same_as_permanent_address, :boolean
    field :tin, :string
    field :vat_status, :string
    field :prescription_term, :string
    field :prescription_clause_percentage, :integer
    field :prescription_clause_days, :integer
    field :credit_term, :string
    field :credit_limit, :string
    field :bank_charge, :decimal
    field :withholding_tax, :decimal
    field :balance_biller, :boolean
    field :authorization_form, :string
    field :payment_mode, :string
    field :releasing_mode, :string
    field :bank_name, :string
    field :bank_account_no, :string
    field :payee_name, :string
    field :number_of_beds, :integer
    field :bond, :integer
    field :exclusive, {:array, :string}
    field :gross_bill, :boolean
    field :effective_date, :date
    field :step, :integer
    field :status, :string
    field :inserted_by, :string
    field :updated_by, :string

    has_many :facility_rooms, Data.Schemas.FacilityRoom, on_delete: :nothing
    has_many :facility_contacts, Data.Schemas.FacilityContact, on_delete: :nothing
    has_many :facility_service_fees, Data.Schemas.FacilityServiceFee, on_delete: :nothing
    has_many :facility_ppds, Data.Schemas.FacilityPpd, on_delete: :nothing
    has_many :facility_addresses, Data.Schemas.FacilityAddress, on_delete: :nothing

    timestamps()
  end

  def changeset(:create, struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :name,
      :type,
      :category,
      :license_name,
      :website,
      :with_incremental,
      :cut_off_time,
      :phic_accreditation_no,
      :billing_same_as_permanent_address,
      :tin,
      :vat_status,
      :prescription_term,
      :prescription_clause_percentage,
      :prescription_clause_days,
      :credit_term,
      :credit_limit,
      :bank_charge,
      :withholding_tax,
      :balance_biller,
      :payment_mode,
      :releasing_mode,
      :bank_name,
      :bank_account_no,
      :payee_name,
      :number_of_beds,
      :bond,
      :exclusive,
      :gross_bill,
      :step,
      :status,
      :inserted_by,
      :updated_by
    ])
    |> validate_required([
      :name,
      :type,
      :category,
      :cut_off_time,
      :billing_same_as_permanent_address,
      :tin,
      :vat_status,
      :prescription_term,
      :credit_term,
      :credit_limit,
      :bank_charge,
      :withholding_tax,
      :payment_mode,
      :releasing_mode,
      :bank_name,
      :bank_account_no,
      :payee_name,
      :bond,
      :gross_bill,
      :status,
    ], message: "is required")
    |> FacilityContext.validate_dropdown(params["type"], "facility_type", :type)
    |> FacilityContext.validate_dropdown(params["category"], "facility_category", :category)
    |> UtilityContext.validate_file(params["photo"], params["code"], :photo, "facility_photo", true)
    |> UtilityContext.validate_file(params["authorization_form"], params["code"], :authorization_form, "facility_authorization_form", false)
    |> validate_length(:name, max: 80, message: "must be at most 80 characters")
    |> validate_format(:name, ~r/^[ a-zA-Z0-9]*$/)
    |> validate_length(:category, max: 80, message: "must be at most 80 characters")
    |> validate_format(:license_name, ~r/^[ a-zA-Z0-9]*$/)
    |> validate_length(:website, max: 255, message: "must be at most 255 characters")
    |> validate_length(:phic_accreditation_no, max: 80, message: "must be at most 80 characters")
    |> validate_format(:phic_accreditation_no, ~r/^[ a-zA-Z0-9-]*$/)
    |> validate_format(:tin, ~r/\d{3}-\d{3}-\d{3}-\d{3}/)
    |> validate_length(:prescription_term, max: 3, message: "must be at most 3 numeric characters")
    |> validate_format(:prescription_term, ~r/^[0-9]*$/)
    |> validate_number(:prescription_clause_percentage, less_than: 101, greater_than: 0, message: "will only accept numeric characters from 0 to 100")
    |> validate_number(:prescription_clause_days, less_than: 1_000, greater_than: 0, message: "must accept at most 3 numeric characters")
    |> validate_length(:credit_term, max: 3, message: "must be at most 3 numeric characters")
    |> validate_format(:credit_term, ~r/^[0-9]*$/)
    |> validate_length(:credit_limit, max: 10, message: "must be at most 10 numeric characters")
    |> validate_format(:credit_limit, ~r/^[0-9]*$/)
    |> validate_length(:bank_name, max: 80, message: "must be at most 80 characters")
    |> validate_format(:bank_name, ~r/^[ a-zA-Z0-9]*$/)
    |> validate_length(:bank_account_no, max: 16, message: "Must accept 16 numeric characters")
    |> validate_format(:bank_account_no, ~r/^[0-9]*$/)
    |> validate_length(:payee_name, max: 80, message: "must be at most 80 characters")
    |> validate_format(:payee_name, ~r/^[ a-zA-Z0-9]*$/)
    |> validate_number(:number_of_beds, less_than: 10_000, message: "Must accept 4 numeric characters")
    |> validate_number(:bond, less_than: 10_000_000_000_000_000_000, message: "must be at most 20 numeric characters")
    |> validate_date(params, :affiliation_date, Map.has_key?(params, "affiliation_date"), "affiliation_date")
    |> validate_date(params, :disaffiliation_date, Map.has_key?(params, "disaffiliation_date"), "disaffiliation_date")
    |> validate_date(params, :phic_accreditation_from, Map.has_key?(params, "phic_accreditation_from"), "phic_accreditation_from")
    |> validate_date(params, :phic_accreditation_to, Map.has_key?(params, "phic_accreditation_to"), "phic_accreditation_to")
    |> validate_date(params, :effective_date, Map.has_key?(params, "effective_date"), "effective_date")
    |> validate_time(params, :cut_off_time, Map.has_key?(params, "cut_off_time"), "cut_off_time")
    |> validate_list_required(params, :addresses, Map.has_key?(params, "addresses"), "addresses")
    |> validate_list_required(params, :contacts, Map.has_key?(params, "contacts"), "contacts")
    |> validate_list_required(params, :service_fee, Map.has_key?(params, "service_fee"), "service_fee")
    |> validate_list(params, :ppd, Map.has_key?(params, "ppd"), "ppd")
    |> validate_decimal(params, :bank_charge, Map.has_key?(params, "bank_charge"), "bank_charge")
  end

  def changeset_upload(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :photo,
      :authorization_form
    ])
  end

  defp validate_date(changeset, _, _, false, _), do: changeset
  defp validate_date(changeset, params, error_key, true, key) do
    {valid?, date} = Timex.parse(Map.get(params, key), "{Mshort}-{0D}-{YYYY}")
    if valid? == :ok do
      changeset |> Map.put(:changes, changeset.changes |> Map.put(error_key, Timex.to_date(date)))
    else
      changeset |> Changeset.add_error(error_key, "is invalid")
    end
  end

  defp validate_time(changeset, _, _, false, _), do: changeset
  defp validate_time(changeset, params, error_key, true, key) do
    {valid?, time} = Time.from_iso8601(Map.get(params, key) <> ":00")
    if valid? == :ok do
      changeset |> Map.put(:changes, changeset.changes |> Map.put(error_key, time))
    else
      changeset |> Changeset.add_error(error_key, "is invalid")
    end
  end

  defp validate_list_required(changeset, _, error_key, false, _), do: changeset |> Changeset.add_error(error_key, "is required")
  defp validate_list_required(changeset, params, error_key, true, key) do
    if is_list(Map.get(params, key)) do
      changeset
    else
      changeset |> Changeset.add_error(error_key, "is invalid")
    end
  end

  defp validate_list(changeset, _, _, false, _), do: changeset
  defp validate_list(changeset, params, error_key, true, key) do
    if is_list(Map.get(params, key)) do
      changeset
    else
      changeset |> Changeset.add_error(error_key, "is invalid")
    end
  end

  defp validate_decimal(changeset, _, _, false, _), do: changeset
  defp validate_decimal(changeset, params, error_key, true, key) do
    if Regex.match?(~r/[+-]?([0-9]*[.])?[0-9]+/, Map.get(params, key)) do
      changeset |> Map.put(:changes, changeset.changes |> Map.put(key, Decimal.new(Map.get(params, key))))
    else
      changeset |> Changeset.add_error(error_key, "is invalid")
    end
  end
end
