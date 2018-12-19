defmodule Data.Schemas.FacilityServiceFee do
  @moduledoc false

  use Data.Schema
  alias Data.Contexts.{
    FacilityContext
  }

  @foreign_key_type :string
  schema "facility_service_fees" do
    field :coverage, :string
    field :payment_mode, :string
    field :service_fee, :string
    field :rate, :string

    belongs_to :facility, Data.Schemas.Facility, foreign_key: :facility_code

    timestamps()
  end

  def changeset(:create, struct, params) do
    struct
    |> cast(params, [
      :facility_code,
      :coverage,
      :payment_mode,
      :service_fee,
      :rate
    ])
    |> validate_required([
      :coverage,
      :payment_mode,
      :service_fee
    ])
    |> FacilityContext.validate_coverage_dropdown(params["coverage"], :coverage)
    |> FacilityContext.validate_dropdown(params["service_fee"], "facility_service_fee", :service_fee)
    |> validate_inclusion(:payment_mode, ["Umbrella", "Individual"])
    |> validate_rate(params["service_fee"])
  end

  def validate_rate(changeset, nil), do: changeset
  def validate_rate(changeset, ""), do: changeset

  def validate_rate(changeset, "FF") do
    changeset
    |> validate_required(:rate)
    |> validate_length(:rate, max: 10, message: "must be at most 10 numeric characters")
    |> validate_format(:rate, ~r/^[0-9]*$/)
  end

  def validate_rate(changeset, "DR") do
    changeset
    |> validate_required(:rate)
    |> validate_length(:rate, max: 3, message: "must be at most 3 numeric characters")
    |> validate_format(:rate, ~r/^[0-9]*$/)
  end

  def validate_rate(changeset, "NDR"), do: changeset
  def validate_rate(changeset, _), do: changeset
end
