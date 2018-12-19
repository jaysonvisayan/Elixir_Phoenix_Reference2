defmodule Data.Schemas.Package do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @primary_key {:code, :string, []}
  schema "packages" do
    field :name, :string
    field :procedure, {:array, :string}
    field :version, :string
    field :status, :string
    field :inserted_by, :string
    field :updated_by, :string

    timestamps()
  end

  def changeset(:create, struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :name,
      :procedure,
      :version,
      :status,
      :inserted_by,
      :updated_by
    ])
    |> validate_required([
      :code,
      :name,
      :procedure
    ], message: "is required")
    |> unique_constraint(:code, message: "Code is already taken")
    |> Changeset.validate_length(:code, max: 50, message: "Code must be at most 50 characters")
    |> Changeset.validate_format(:code, ~r/^[ a-zA-Z0-9-_.]*$/, message: "Code must have no special characters except for - _ and .")
    |> Changeset.validate_length(:name, max: 80, message: "Name must be at most 80 characters")
  end
end
