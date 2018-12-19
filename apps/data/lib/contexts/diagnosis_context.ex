defmodule Data.Contexts.DiagnosisContext do
  @moduledoc false

  alias Data.Schemas.Diagnosis, as: DS
  alias Data.Repo
  alias Ecto.Changeset, warn: false

  import Ecto.Query

  def validate_params(:download, params) do
    fields = %{
      search_value: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> validate_key(params["search_value"])
    |> is_valid_changeset?()
  end

  def validate_params(:search, params) do
    fields = %{
      search_value: :string,
      page_number: :integer,
      display_per_page: :integer,
      sort_by: :string,
      order_by: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:page_number, :display_per_page, :sort_by, :order_by], message: "is required" )
    |> validate_key(params["search_value"])
    |> is_valid_changeset?()
  end

  def validate_params(:download, params) do
    fields = %{
      search_value: :string
    }

    changeset =
      {%{}, fields}
      |> Changeset.cast(params, Map.keys(fields))
      |> validate_key(params["search_value"])
      |> is_valid_changeset?()
  end

  def is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  def get_diagnoses({:error, changeset}), do: {:error, changeset}
  def get_diagnoses(params) do
    search_value = params.search_value

    DS
    |> where([d],
             ilike(d.code, ^"%#{search_value}%") or
             ilike(d.desc, ^"%#{search_value}%") or
             ilike(d.group_code, ^"%#{search_value}%") or
             ilike(d.group_desc, ^"%#{search_value}%") or
             ilike(d.standard, ^"%#{search_value}%") or
             ilike(fragment("(CASE WHEN ? = true THEN 'YES' ELSE 'NO' END)", d.is_dreaded), ^"%#{search_value}%") or
             ilike(fragment("(CASE WHEN ? = true THEN 'YES' ELSE 'NO' END)", d.is_congenital), ^"%#{search_value}%")
    )
    |> select([d], %{
      group_code: d.group_code,
      code: d.code,
      group_desc: d.group_desc,
      standard: d.standard,
      is_dreaded: fragment("(CASE WHEN ? = true then 'YES' ELSE 'NO' END)", d.is_dreaded),
      is_congenital: fragment("(CASE WHEN ? = true then 'YES' ELSE 'NO' END)", d.is_congenital),
    })
    |> Repo.all()
  end

  # For Seed

  def insert_diagnosis_seed(params) do
    params
    |> get_by()
    |> create_update_diagnosis(params)
  end

  defp create_update_diagnosis(nil, params) do
    %DS{}
    |> DS.changeset(params)
    |> Repo.insert()
  end

  defp create_update_diagnosis(diagnosis, params) do
    diagnosis
    |> DS.changeset(params)
    |> Repo.update()
  end

  defp validate_key(changeset, ""), do: changeset |> Changeset.change(search_value: "")
  defp validate_key(changeset, _params), do: changeset |> validate_search_value(changeset.changes)

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end
  defp validate_search_value(changeset, _changes), do: changeset

  defp get_by(params) do
    DS |> Repo.get_by(params)
  end
end
