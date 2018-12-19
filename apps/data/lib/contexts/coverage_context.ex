defmodule Data.Contexts.CoverageContext do
  @moduledoc false
  alias Data.{
    Schemas.Coverage,
    Repo
  }
  import Ecto.{
    Query
  }

  def insert_coverage_seed(params) do
    params
    |> get_coverage()
    |> create_update_coverage(params)
  end

  defp create_update_coverage(nil, params) do
    %Coverage{}
    |> Coverage.changeset(params)
    |> Repo.insert()
  end

  defp create_update_coverage(c, params) do
    c
    |> Coverage.changeset(params)
    |> Repo.update()
  end

  def get_coverage(params) do
    Coverage
    |> Repo.get_by(params)
  end
end
