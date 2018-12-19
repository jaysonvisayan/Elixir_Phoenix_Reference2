defmodule Data.Schemas.FacilityRoom do
  @moduledoc false

  use Data.Schema

  @foreign_key_type :string
  schema "facility_rooms" do
    field :room_rate, :decimal
    field :room_type, :string

    belongs_to :room, Data.Schemas.Room, foreign_key: :room_code
    belongs_to :facilities, Data.Schemas.Facility, foreign_key: :facility_code
    timestamps()
  end

  def changeset(:search, struct, params \\ %{}) do
    struct
    |> cast(params, [
      :facility_code,
      :room_code,
      :room_type,
      :room_rate,
    ])
    |> validate_required([
      :room_code,
      :facility_code,
    ])
  end

end
