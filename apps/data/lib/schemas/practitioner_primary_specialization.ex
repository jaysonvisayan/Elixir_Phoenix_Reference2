defmodule Data.Schemas.PractitionerPrimarySpecialization do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreign_key_type :binary_id
  schema "practitioner_primary_specializations" do
    field :specialization, :string
    field :fee, :float

    belongs_to :practitioner_primaries, Data.Schemas.PractitionerPrimary, foreign_key: :practitioner_primary_id

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_primary_id,
      :specialization,
      :fee
    ])
  end
end


