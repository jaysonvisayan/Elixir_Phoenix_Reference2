defmodule Data.Repo.Migrations.AddUniqueConstraintMiscellanyCode do
  use Ecto.Migration

  def change do
    create unique_index(:miscellany, [:code])
  end
end
