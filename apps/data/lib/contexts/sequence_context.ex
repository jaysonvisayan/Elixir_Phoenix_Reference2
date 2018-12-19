defmodule Data.Contexts.SequenceContext do
  @moduledoc false

  alias Data.{
    Schemas.Sequence,
    Repo
  }

  def insert_sequence_seed(params) do
    params
    |> get_sequence_by_type()
    |> insert_or_ignore_sequence(params)
  end

  defp get_sequence_by_type(params) do
    Sequence
    |> Repo.get_by(type: params.type)
  end

  defp insert_or_ignore_sequence(sequence, params) when is_nil(sequence) do
    %Sequence{}
    |> Sequence.changeset(params)
    |> Repo.insert()
  end
  defp insert_or_ignore_sequence(sequence, _params), do: {:ok, sequence}
end
