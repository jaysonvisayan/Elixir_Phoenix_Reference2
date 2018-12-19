defmodule Data.Seeders.SequenceSeeder do
  @moduledoc false

  alias Data.Contexts.SequenceContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SequenceContext.insert_sequence_seed(params) do
        {:ok, sequence} ->
          sequence
      end
    end)
  end
end
