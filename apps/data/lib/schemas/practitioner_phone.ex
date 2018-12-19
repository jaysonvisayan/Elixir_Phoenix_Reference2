defmodule Data.Schemas.PractitionerPhone do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  schema "practitioner_phones" do
    field :type, :string
    field :country_code, :string
    field :area_code, :string
    field :number, :string
    field :local, :string

    belongs_to :practitioners, Data.Schemas.Practitioner, foreign_key: :practitioner_code, references: :code, type: :string
    belongs_to :practitioner_corporates, Data.Schemas.PractitionerCorporate, foreign_key: :practitioner_corporate_id
    belongs_to :practitioner_primaries, Data.Schemas.PractitionerPrimary, foreign_key: :practitioner_primary_id

    timestamps()

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_code,
      :type,
      :country_code,
      :area_code,
      :number,
      :local,
      :practitioner_corporate_id,
      :practitioner_primary_id,
    ])
  end
end
