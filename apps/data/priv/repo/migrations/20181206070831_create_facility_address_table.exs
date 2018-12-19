defmodule Data.Repo.Migrations.CreateFacilityAddressTable do
  use Ecto.Migration

  def change do
    create table(:facility_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_code, references(:facilities, column: :code, type: :string, on_delete: :nothing)
      add :type, :string
      add :address_line_1, :string
      add :address_line_2, :string
      add :city, :string
      add :province, :string
      add :region, :string
      add :country, :string
      add :postal_code, :string
      add :latitude, :string
      add :longtitude, :string

      timestamps()
    end

    alter table(:facilities) do
      add :billing_same_as_permanent_address, :boolean
      remove :address_line_1
      remove :address_line_2
      remove :city
      remove :province
      remove :region
      remove :country
      remove :postal_code
      remove :latitude
      remove :longitude
    end
  end
end
