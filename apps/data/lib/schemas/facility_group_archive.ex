defmodule Data.Schemas.FacilityGroupArchive do
    @moduledoc false

  use Data.Schema

  schema "facility_group_archives" do
      field :description, :string
      field :version, :string
      field :updated_by, :string
      field :updated_at, :utc_datetime
      field :change_logs, {:array, :string}

    belongs_to :facility_group, Data.Schemas.FacilityGroup, foreign_key: :facility_group_code
  end

  def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
          :facility_group_code,
          :description,
          :version,
          :updated_by,
          :updated_at,
          :change_logs
      ])
      |> validate_required([
          :facility_group_code,
      ])
      |> unique_constraint(:facility_group_code, message: "Facility Group Code is already exist!")
  end
end
