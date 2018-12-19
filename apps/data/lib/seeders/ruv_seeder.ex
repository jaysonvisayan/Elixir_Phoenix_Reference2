defmodule Data.Seeders.RuvSeeder do
  @moduledoc false
  alias Data.Contexts.RuvContext, as: PC

  def seed(data) do
    Enum.map(data, fn(params) ->
      case PC.insert_ruv_seed(params) do
        {:ok, data} ->
          data
      end
    end)
  end
end
