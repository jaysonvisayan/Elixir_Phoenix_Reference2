defmodule Data.Repo.Migrations.AlterPractitionersModifyExclusive do
  use Ecto.Migration

  def up do
      execute """
        alter table practitioners alter column exclusive type character varying(255)[] using (exclusive::character varying(255)[])
       """
   end

   def down do
      execute """
        alter table practitioners alter column exclusive type character varying(255);
       """
   end
end
