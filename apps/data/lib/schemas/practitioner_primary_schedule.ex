defmodule Data.Schemas.PractitionerPrimarySchedule do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreig_key_type :binary_id
  schema "practitioner_primary_schedules" do
    field :day, :string
    field :room, :float
    field :time_from, :time
    field :time_to, :time

    belongs_to :practitioner_primaries, Data.Schemas.PractitionerPrimary, foreign_key: :practitioner_primary_id

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_primary_id,
      :day,
      :room,
      :time_from,
      :time_to
    ])
  end
end



