defmodule Data.Schemas.PractitionerCorporateSchedule do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreign_key_type :binary_id
  schema "practitioner_corporate_schedules" do
    field :day, :string
    field :room, :string
    field :time_from, :time
    field :time_to, :time

    belongs_to :practitioner_corporate, Data.Schemas.PractitionerCorporate, foreign_key: :practitioner_corporate_id

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_corporate_id,
      :day,
      :room,
      :time_from,
      :time_to
    ])
  end
end


