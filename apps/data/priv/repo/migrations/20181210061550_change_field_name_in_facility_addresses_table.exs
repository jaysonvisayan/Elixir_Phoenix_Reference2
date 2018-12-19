defmodule Data.Repo.Migrations.ChangeFieldNameInFacilityAddressesTable do
  use Ecto.Migration

  def change do

    alter table(:facility_addresses) do
      remove :longtitude
      add :longitude, :string
    end

    alter table(:facility_contacts) do
      remove :mobile_no
      remove :telephone
      remove :fax

      add :mobile_nos, {:array, :map}
      add :tel_nos, {:array, :map}
      add :fax_nos, {:array, :map}
    end
  end
end
