defmodule Data.Repo.Migrations.CreateRuvMultiplier do
  use Ecto.Migration

  def up do
    create table(:ruv_multipliers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ruv_id, references(:ruvs, column: :id, type: :binary_id)
      add :room_code, references(:rooms, column: :code, type: :string)
      add :amount, :decimal
      add :effective_date, :utc_datetime

      timestamps()
    end
  end

  def down do
    drop table(:ruv_multipliers)
  end
end
