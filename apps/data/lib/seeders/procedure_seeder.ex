defmodule Data.Seeders.ProcedureSeeder do
  @moduledoc false

  alias Data.Contexts.ProcedureContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case ProcedureContext.insert_procedure_seed(params) do
        {:ok, p} ->
          p
      end
    end)
  end
end
