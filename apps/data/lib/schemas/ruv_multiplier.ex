defmodule Data.Schemas.RuvMultiplier do
  @moduledoc false

  use Data.Schema

  @primary_key {:id, :binary_id, []}
  schema "ruv_multipliers" do
    field :amount, :decimal
    field :effective_date, :utc_datetime

    belongs_to :ruvs, Data.Schemas.Ruv, foreign_key: :ruv_id
    belongs_to :rooms, Data.Schemas.Room, foreign_key: :room_code, type: :string

    timestamps()
  end
end

