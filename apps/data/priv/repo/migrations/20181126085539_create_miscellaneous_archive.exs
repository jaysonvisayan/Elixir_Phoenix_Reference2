defmodule Data.Repo.Migrations.CreateMiscellaneousArchive do
  @moduledoc false
  
  use Ecto.Migration

  def change do
    create table(:miscellaneous_archives, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :miscellaneous_code, references(:miscellany, column: :code, type: :string, primary_key: true)
      add :description, :text
      add :max_price, :decimal
      add :version, :string
      add :updated_by, :string
      add :updated_at, :utc_datetime
      add :change_logs, {:array, :string}
    end
  end
end
