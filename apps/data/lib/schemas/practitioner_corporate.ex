defmodule Data.Schemas.PractitionerCorporate do
  @moduledoc false

  alias Ecto.Changeset

  use Data.Schema

  @foreign_key_type :string
  schema "practitioner_corporates" do
    field :account_code, :string
    field :email, :string
    field :inserted_by, :string

    has_many :practitioner_phones, Data.Schemas.PractitionerPhone, on_delete: :delete_all
    has_many :practitioner_corporate_schedules, Data.Schemas.PractitionerCorporateSchedule, on_delete: :delete_all

    belongs_to :practitioners, Data.Schemas.Practitioner, foreign_key: :practitioner_code

    timestamps()

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :practitioner_code,
      :account_code,
      :email,
      :inserted_by
    ])
  end

end

