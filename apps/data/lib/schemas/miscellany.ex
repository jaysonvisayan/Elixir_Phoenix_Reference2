defmodule Data.Schemas.Miscellaneous do
    @moduledoc false

    use Data.Schema
    @primary_key {:code, :string, []}
    schema "miscellany" do
        field :description, :string
        field :max_price, :decimal
        field :status, :string
        field :version, :string
        field :updated_by, :string
        field :inserted_by, :string

        has_many :miscellaneous_archives, Data.Schemas.MiscellaneousArchive, on_delete: :nothing

        timestamps()

    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [
            :code,
            :description,
            :max_price,
            :status,
            :version,
            :updated_by,
            :inserted_by
        ])
        |> validate_required([
            :code,
            :description,
            :max_price
        ])
        |> validate_length(:code, max: 80, message: "should be at most 80 characters ")
        |> validate_length(:description, max: 80, message: "should be at most 80 characters")
    end

    def draft_changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [
            :code,
            :description,
            :max_price,
            :status,
            :version,
            :updated_by,
            :inserted_by
        ])
        |> validate_required([
            :code
        ])
        |> validate_length(:code, max: 80, message: "is invalid")
        |> validate_length(:description, max: 80, message: "is invalid")
    end
end
