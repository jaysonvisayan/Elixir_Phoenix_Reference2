defmodule Data.Schemas.Sequence do
  use Data.Schema
  @moduledoc false

  schema "sequences" do
    field :type, :string
    field :number, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :type,
      :number
    ])
    |> validate_required([
      :type,
      :number
    ])
  end
end
