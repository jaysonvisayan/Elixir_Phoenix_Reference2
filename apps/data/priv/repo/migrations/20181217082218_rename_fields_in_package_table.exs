defmodule Data.Repo.Migrations.RenameFieldsInPackageTable do
  use Ecto.Migration

  def up do
    rename table(:packages), :created_by, to: :status
  end

  def down do
    rename table(:packages), :status, to: :created_by
  end
end
