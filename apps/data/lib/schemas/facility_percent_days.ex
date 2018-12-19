defmodule Data.Schemas.FacilityPercentDay do
  @moduledoc false

  use Data.Schema
  schema "facility_percent_days" do
    field :percent, :integer
    field :days, :integer

    belongs_to :facility_ppd, Data.Schemas.FacilityPpd
    timestamps()
  end

  def changeset(:create, struct, params) do
    struct
    |> cast(params, [
      :facility_ppd_id,
      :percent,
      :days
    ])
    |> validate_number(:percent, less_than_or_equal_to: 99_999_999 , message: "must be at most 8 numeric characters")
    |> validate_number(:days, less_than_or_equal_to: 99_999_999 , message: "must be at most 8 numeric characters")
  end
end
