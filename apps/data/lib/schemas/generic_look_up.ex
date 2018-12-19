defmodule Data.Schemas.GenericLookUp do
  @moduledoc false

  alias Ecto.Changeset
  use Data.Schema

  @primary_key {:code, :string, []}
  @primary_key {:type, :string, []}
  schema "generic_look_ups" do
    field :code, :string
    field :name, :string
    field :description, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :type,
      :name,
      :description
    ])
    |> validate_required([
      :code,
      :type,
      :name,
      :description
    ])
    |> Changeset.validate_length(:code, max: 80, message: "must be at most 80 characters")
    |> Changeset.validate_length(:type, max: 80, message: "must be at most 80 characters")
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, [
      :name,
      :description
    ])
  end
end
