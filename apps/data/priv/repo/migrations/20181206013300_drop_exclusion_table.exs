defmodule Data.Repo.Migrations.DropExclusionTable do
  use Ecto.Migration

  def change do
    drop table(:exclusions)
  end
end
