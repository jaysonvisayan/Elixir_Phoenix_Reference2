defmodule Data.Contexts.GenericLookUpContext do
  @moduledoc false
  alias Data.{
    Schemas.GenericLookUp,
    Repo
  }
  import Ecto.{
    Query
  }

  def insert_generic_look_up_seed(params) do
    params
    |> get_generic_look_up()
    |> create_update_generic_look_up(params)
  end

  defp create_update_generic_look_up(nil, params) do
    %GenericLookUp{}
    |> GenericLookUp.changeset(params)
    |> Repo.insert()
  end

  defp create_update_generic_look_up(gnl, params) do
    gnl
    |> GenericLookUp.changeset(params)
    |> Repo.update()
  end

  def get_generic_look_up(params) do
    GenericLookUp
    |> Repo.get_by(%{code: params.code, type: params.type})
  end

  def get_generic_look_up_by_code(%{code: code}) do
    GenericLookUp
    |> Repo.get_by(code: code)
  end
end
