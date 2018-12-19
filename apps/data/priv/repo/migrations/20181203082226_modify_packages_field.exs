defmodule Data.Repo.Migrations.ModifyPackagesField do
  use Ecto.Migration

  def change do
    alter table(:packages) do
      modify :procedure, {:array, :string}
    end
  end
end
