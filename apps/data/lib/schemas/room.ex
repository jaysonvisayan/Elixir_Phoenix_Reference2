defmodule Data.Schemas.Room do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @primary_key {:code, :string, []}
  schema "rooms" do
    field :category, :string
    field :hierarchy, :integer
    field :status, :string
    field :version, :string
    field :inserted_by, :string
    field :updated_by, :string

    has_many :room_archives, Data.Schemas.RoomArchive, on_delete: :nothing
    has_many :facility_rooms, Data.Schemas.FacilityRoom, on_delete: :nothing
    has_many :ruv_multipliers, Data.Schemas.RuvMultiplier, on_delete: :nothing

    timestamps()
  end

  def changeset(:create, struct, params) do
    struct
    |> cast(params, [
      :code,
      :category,
      :hierarchy,
      :status,
      :version,
      :inserted_by,
      :updated_by,
    ])
    |> validate_required([
      :code,
      :category,
      :hierarchy,
    ], message: "is required")
    |> validate_length(:code, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_length(:category, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_number(:hierarchy, greater_than: 0, message: "only accepts numeric characters greater than one (1)")
    |> validate_number(:hierarchy, less_than: 100, message: "only accepts 2 numeric characters")
    |> validate_format(:code, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), underscore (_) and dot (.)")
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, [
      :code,
      :category,
      :hierarchy,
      :status,
      :version,
      :inserted_by,
      :updated_by,
    ])
    |> validate_required([
      :code,
      :category,
      :hierarchy,
    ], message: "room is required")
    |> validate_length(:code, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:code, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), underscore (_) and dot (.)")
    |> validate_length(:category, max: 80, message: "only accepts 80 Alphanumeric characters")
    |> validate_format(:category, ~r/^[ a-zA-Z0-9]*$/, message: "only accepts 80 Alphanumeric characters")
    |> validate_number(:hierarchy, less_than: 100, message: "only accepts 2 numeric characters")
    |> validate_number(:hierarchy, greater_than: 0, message: "only accepts numeric characters greater than one (1)")
  end

  def changeset_draft(:create_draft, struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :category,
      :hierarchy,
      :status,
      :version,
      :inserted_by,
      :updated_by,
    ])
    |> validate_required([
      :code,
      :category
    ], message: "is required")
    |> validate_length(:code, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_length(:category, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_number(:hierarchy, greater_than: 0, message: "only accepts numeric characters greater than one (1)")
    |> validate_number(:hierarchy, less_than: 100, message: "only accepts 2 numeric characters")
    |> validate_format(:code, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), underscore (_) and dot (.)")
  end

  def changeset(:delete, struct, params) do
    struct
    |> cast(params, [
      :code,
      :status,
      :updated_by
    ])
    |> validate_required([
      :code
    ], message: "is required")
    |> validate_length(:code, max: 80, message: "must be at most 80 characters")
    |> validate_format(:code, ~r/^[ a-zA-Z0-9-_.]*$/, message: "must have no special characters except for - _ and .")
  end

end
