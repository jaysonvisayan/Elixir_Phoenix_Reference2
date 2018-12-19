defmodule Data.Schemas.FacilityPpd do
  @moduledoc false

  use Data.Schema

  @foreign_key_type :string
  schema "facility_ppds" do
    field :coverage, :string
    field :subcoverage, :string
    field :discount_mode, :string

    belongs_to :facility, Data.Schemas.Facility, foreign_key: :facility_code
    has_many :facility_percent_days, Data.Schemas.FacilityPercentDay, on_delete: :nothing

    timestamps()
  end

  def changeset(:create, struct, params \\ %{}) do
    struct
    |> cast(params, [
      :coverage,
      :subcoverage,
      :discount_mode
    ])
    |> validate_required([
      :coverage,
      :subcoverage
    ])
    |> validate_inclusion(:coverage, ["Outpatient", "Inpatient", "Emergency", "Consultation"])
    |> validate_inclusion(:discount_mode, ["Outright", "Rebate"])
    |> validate_subcoverage()
  end

  defp validate_subcoverage(changeset) do
    check_coverage(Map.has_key?(changeset.changes, :sub_coverage), changeset)
  end

  defp check_coverage(false, changeset), do: changeset
  defp check_coverage(true, changeset) do
    validate_subcoverage1(changeset.subcoverage, changeset)
  end

  defp validate_subcoverage1("Inpatient", changeset) do
    changeset
    |> validate_inclusion(:subcoverage, ["Room And Board", "Labs/Diagnostics", "Medicine"])
  end

  defp validate_subcoverage1(_, changeset) do
    changeset
    |> validate_inclusion(:subcoverage, ["Labs/Diagnostics", "Medicine"])
  end
end
