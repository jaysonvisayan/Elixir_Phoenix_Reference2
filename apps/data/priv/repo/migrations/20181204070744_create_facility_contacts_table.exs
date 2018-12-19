defmodule Data.Repo.Migrations.CreateFacilityContactsTable do
  use Ecto.Migration

  def change do
    create table(:facility_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_code, references(:facilities, column: :code, type: :string, on_delete: :nothing)
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :suffix, :string
      add :department, :string
      add :designation, :string
      add :email_address, :string
      add :email_address_2, :string
      add :mobile_no, {:array, :map}
      add :telephone, {:array, :map}
      add :fax, {:array, :map}

      timestamps()
    end
  end
end
