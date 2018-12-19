defmodule Data.Repo.Migrations.CreateFacilityGroups do
  use Ecto.Migration

  def up do
    create table(:facility_groups, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string
      add :description, :string
      add :selecting_type, :string
      add :facility_codes, {:array, :string}
      add :region, {:array, :string}
      add :all_luzon, :boolean
      add :all_visayas, :boolean
      add :all_mindanao, :boolean
      add :status, :string
      add :version, :string
      add :inserted_by, :string
      add :updated_by, :string
    end
  end

  def down do
    drop table(:facility_groups)
  end
end
