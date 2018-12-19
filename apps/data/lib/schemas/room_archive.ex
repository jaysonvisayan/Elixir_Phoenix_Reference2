defmodule Data.Schemas.RoomArchive do
  @moduledoc false

  use Data.Schema

  @foreign_key_type :string
  schema "room_archives" do
    field :category, :string
    field :hierarchy, :integer
    field :version, :string
    field :updated_by, :string
    field :updated_at, :utc_datetime
    field :change_logs, {:array, :string}

    belongs_to :room, Data.Schemas.Room, foreign_key: :room_code
  end

  def changeset(:search, struct, params) do
    struct
    |> cast(params, [
      :room_code,
      :category,
      :hierarchy,
      :version,
      :updated_by,
      :updated_at,
      :change_logs
    ])
    |> validate_required([
      :room_code,
    ])
  end

  def changeset(:insert, struct, params) do
    struct
    |> cast(params, [
      :room_code,
      :category,
      :hierarchy,
      :version,
      :updated_by,
      :updated_at,
      :change_logs
    ])
    |> validate_required([
      :room_code,
      :category,
      :hierarchy,
    ])
  end

end
