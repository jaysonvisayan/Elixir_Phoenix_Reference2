defmodule Data.Schemas.MiscellaneousArchive do
    @moduledoc false

    use Data.Schema

    schema "miscellaneous_archives" do
      field :description, :string
      field :max_price, :decimal
      field :version, :string
      field :updated_by, :string
      field :updated_at, :utc_datetime
      field :change_logs, {:array, :string}

      belongs_to :miscellaneous,
        Data.Schemas.Miscellaneous,
        foreign_key: :miscellaneous_code,
        references: :code,
        type: :string
    end

    def changeset(:search, struct, params \\ %{}) do
      struct
      |> cast(params, [
          :miscellaneous_code,
          :description,
          :max_price,
          :version,
          :updated_by,
          :updated_at,
          :change_logs
         ])
      |> validate_required([
          :miscellaneous_code,
         ])
      |> unique_constraint(:miscellaneous_code, message: "Miscellaneous code is already exist!")
    end
end
