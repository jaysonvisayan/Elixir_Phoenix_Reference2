defmodule Data.Schemas.FacilityContact do
  @moduledoc false

  use Data.Schema

  @foreign_key_type :string
  schema "facility_contacts" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :suffix, :string
    field :department, :string
    field :designation, :string
    field :email_address, :string
    field :email_address_2, :string
    field :mobile_nos, {:array, :map}
    field :tel_nos, {:array, :map}
    field :fax_nos, {:array, :map}

    belongs_to :facility, Data.Schemas.Facility, foreign_key: :facility_code

    timestamps()
  end

  def changeset(:create, struct, params) do
    struct
    |> cast(params, [
      :facility_code,
      :first_name,
      :middle_name,
      :last_name,
      :suffix,
      :department,
      :designation,
      :email_address,
      :email_address_2,
      :mobile_nos,
      :tel_nos,
      :fax_nos
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :email_address,
      :mobile_nos
    ])
    |> validate_length(:first_name, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:first_name, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:middle_name, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:middle_name, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:last_name, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:last_name, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:suffix, max: 5, message: "only accepts 5 alphanumeric characters")
    |> validate_format(:suffix, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:department, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:department, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:designation, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:designation, ~r/^[ a-zA-Z0-9-_.]*$/, message: "only accepts special characters hyphen (-), comma (,) and dot (.)")
    |> validate_length(:email_address, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:email_address, ~r/^[ a-zA-Z0-9-_.@]*$/, message: "only accepts special characters hyphen (-), underscore (_), dot (.) and at(@)")
    |> validate_length(:email_address_2, max: 80, message: "only accepts 80 alphanumeric characters")
    |> validate_format(:email_address_2, ~r/^[ a-zA-Z0-9-_.@]*$/, message: "only accepts special characters hyphen (-), underscore (_), dot (.) and at(@)")
  end
end
