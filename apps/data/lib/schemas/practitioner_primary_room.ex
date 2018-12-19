defmodule Data.Schemas.PractitionerPrimaryRoom do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreign_key_type :binary_id
  schema "practitioner_primary_rooms" do
    field :type, :string
    field :rate, :string

    belongs_to :practitioner_primaries, Data.Schemas.PractitionerPrimary, foreign_key: :practitioner_primary_id

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_primary_id,
      :type,
      :rate
    ])
  end
end

