defmodule Data.Schemas.FacilityAddress do
  @moduledoc false

  use Data.Schema
  alias Data.Contexts.{
    FacilityContext
  }

  @foreign_key_type :string
  schema "facility_addresses" do
    field :type, :string
    field :address_line_1, :string
    field :address_line_2, :string
    field :city, :string
    field :province, :string
    field :region, :string
    field :country, :string
    field :postal_code, :string
    field :latitude, :string
    field :longitude, :string

    belongs_to :facility, Data.Schemas.Facility, foreign_key: :facility_code

    timestamps()
  end

  def changeset(:create, struct, params) do
    struct
    |> cast(params, [
      :facility_code,
      :type,
      :facility_code,
      :address_line_1,
      :address_line_2,
      :city,
      :province,
      :region,
      :country,
      :postal_code,
      :latitude,
      :longitude
    ])
    |> validate_required([
      :type,
      :address_line_1,
      :address_line_2,
      :city,
      :province,
      :region,
      :country,
      :postal_code,
      :latitude,
      :longitude
    ], message: "is required")
    |> FacilityContext.validate_address_dropdown(%{city_municipal: params["city"]}, params["city"], :city)
    |> FacilityContext.validate_address_dropdown(%{region: params["region"]}, params["region"], :region)
    |> FacilityContext.validate_address_dropdown(%{province: params["province"]}, params["province"], :province)
    |> validate_length(:address_line_1, max: 150, message: "must be at most 150 characters")
    |> validate_length(:address_line_2, max: 150, message: "must be at most 150 characters")
    |> validate_inclusion(:country, ["Philippines"])
    |> validate_length(:postal_code, max: 6, message: "must be at most 6 numeric characters")
    |> validate_format(:postal_code, ~r/^[0-9]*$/)
    |> validate_length(:longitude, max: 20, message: "must be at most 20 numeric characters")
    |> validate_format(:longitude, ~r/^\d*(\.\d{1,100})?$/)
    |> validate_length(:latitude, max: 20, message: "must be at most 20 numeric characters")
    |> validate_format(:latitude, ~r/^\d*(\.\d{1,100})?$/)
  end

end
