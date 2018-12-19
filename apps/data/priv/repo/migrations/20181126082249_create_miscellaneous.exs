defmodule Data.Repo.Migrations.CreateMiscellaneous do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:miscellany, primary_key: false) do
      add :code, :string, primary_key: true
      add :description, :text
      add :max_price, :decimal
      add :status, :string
      add :version, :string
      add :updated_by, :string
      add :inserted_by, :string

      timestamps()
    end
  end
end
