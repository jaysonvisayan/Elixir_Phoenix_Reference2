defmodule Data.Schemas.Diagnosis do
  @moduledoc false

  use Data.Schema

  @primary_key {:code, :string, []}
  schema "diagnoses" do
    field :desc, :string
    field :group_code, :string
    field :group_desc, :string
    field :is_dreaded, :boolean
    field :is_congenital, :boolean
    field :standard, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :desc,
      :group_code,
      :group_desc,
      :is_dreaded,
      :is_congenital,
      :standard
    ])
    |> validate_required([
      :code
    ])
  end
end
