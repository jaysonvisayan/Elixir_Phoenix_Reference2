defmodule Data.Schemas.Coverage do
  @moduledoc false

  use Data.Schema

  @primary_key {:code, :string, []}
  schema "coverages" do
    field :name

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :name
    ])
    |> validate_required([
      :code,
      :name
    ])
  end
end
