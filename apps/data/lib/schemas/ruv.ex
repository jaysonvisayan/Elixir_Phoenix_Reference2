defmodule Data.Schemas.Ruv do
  @moduledoc false

  use Data.Schema

  @primary_key {:id, :binary_id, []}
  @foreign_key_type :string
  schema "ruvs" do
    field :unit, :integer
    field :version, :string
    field :status, :string
    field :inserted_by, :string
    field :updated_by, :string

    belongs_to :procedures, Data.Schemas.Procedure, foreign_key: :code
    has_many :ruv_multipliers, Data.Schemas.RuvMultiplier, on_delete: :nothing

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :code,
      :unit,
      :version,
      :status,
      :inserted_by,
      :updated_by
    ])
  end

end

