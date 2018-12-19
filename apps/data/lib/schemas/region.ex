defmodule Data.Schemas.Region do
    @moduledoc false

    use Data.Schema

  @primary_key {:code, :string, []}
  schema "regions" do
    field :region_name, :string
    field :island_group, :string
    field :updated_by, :string
    field :inserted_by, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :region_name,
      :island_group,
      :inserted_by,
      :updated_by
    ])
    |> validate_required([
      :code,
      :region_name,
      :island_group
    ])
    |> unique_constraint(:code, message: "Region code already exist!")
    |> unique_constraint(:region_name, message: "Region name already exist!")
  end
end
