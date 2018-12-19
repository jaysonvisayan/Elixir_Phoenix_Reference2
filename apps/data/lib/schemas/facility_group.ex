defmodule Data.Schemas.FacilityGroup do
    @moduledoc false

    use Data.Schema

  @primary_key {:code, :string, []}

  schema "facility_groups" do
    field :name, :string
    field :description, :string
    field :selecting_type, :string
    field :facility_codes, {:array, :string}
    field :regions, {:array, :string}
    field :all_luzon, :boolean, default: false
    field :all_visayas, :boolean, default: false
    field :all_mindanao, :boolean, default: false
    field :status, :string
    field :version, :string
    field :inserted_by, :string
    field :updated_by, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :code,
      :name,
      :description,
      :selecting_type,
      :facility_codes,
      :all_luzon,
      :all_visayas,
      :all_mindanao,
      :status,
      :version,
      :regions
    ])
    |> unique_constraint(:code, message: "Enter facility group name.")
    |> unique_constraint(:name, message: "Enter description.")
    |> validate_required([:name], message: "Enter facility group name.")
    |> validate_required([:description], message: "Enter description.")
    |> validate_required([:selecting_type], message: "Enter selecting type.")
    |> validate_length(:name, max: 80, message: "must not exceed 80 characters")
    |> validate_length(:description, max: 80, message: "must not exceed 80 characters")
    |> validate_format(:name, ~r/^[a-zA-Z0-9 ():-]*$/, message: "Name is invalid")
    |> validate_format(:description, ~r/^[a-zA-Z0-9 ():-]*$/, message: "Description is invalid")
    |> validate_inclusion(:selecting_type, ["R", "F"], message: "Selecting type is invalid")
  end
end
