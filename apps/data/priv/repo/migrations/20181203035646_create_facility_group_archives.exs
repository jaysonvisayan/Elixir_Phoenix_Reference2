defmodule Data.Repo.Migrations.CreateFacilityGroupArchives do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:facility_group_archives, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :facility_group_code, references(:facility_groups, column: :code, type: :string, primary_key: true)
      add :description, :text
      add :version, :string
      add :updated_by, :string
      add :change_logs, {:array, :string}
    end
  end
end
