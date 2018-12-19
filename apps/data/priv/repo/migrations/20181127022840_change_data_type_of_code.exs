defmodule Data.Repo.Migrations.ChangeDataTypeOfCode do
  use Ecto.Migration

  def change do
    alter table(:procedures) do
      modify :code, :string
    end
  end
end
