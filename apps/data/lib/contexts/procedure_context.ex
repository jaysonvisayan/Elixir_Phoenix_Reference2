defmodule Data.Contexts.ProcedureContext do
  @moduledoc false

  alias Ecto.Changeset
  import Ecto.Query

  alias Data.{
    Repo,
    Schemas.Procedure
  }

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
      |> Changeset.validate_required([:page_number, :display_per_page, :sort_by, :order_by], message: "is required")
      |> is_valid_changeset?()
  end

  def validate_params(:download, params) do
    fields = %{
      search_value: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> validate_key(params["search_value"])
    |> is_valid_changeset?()
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  def get_procedures({:error, changeset}, _), do: {:error, changeset}

  def get_procedures(params, :search) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Procedure
    |> search_datatable(search_value)
    |> select_datatable()
    |> order_datatable(
      params.sort_by,
      params.order_by
    )
    |> offset(^offset)
    |> limit(^params.display_per_page)
    |> Repo.all()
  end

  def get_procedures(params, :download) do
    search_value = params.search_value

    Procedure
    |> search_datatable(search_value)
    |> select_datatable()
    |> Repo.all()
  end

  defp search_datatable(query, search_value) do
    query
    |> where([r],
      ilike(r.code, ^"%#{search_value}%") or
      ilike(r.desc, ^"%#{search_value}%") or
      ilike(r.type, ^"%#{search_value}%") or
      ilike(r.standard, ^"%#{search_value}%") or
      ilike(r.rate_type, ^"%#{search_value}%")
      )
  end

  defp select_datatable(query) do
    query
    |> select([r],
      %{
       code: r.code,
        desc: r.desc,
        type: r.type,
        standard: r.standard,
        rate_type: r.rate_type
      }
    )
  end

  # For Seed

  def insert_procedure_seed(params) do
    params
    |> get_by()
    |> create_update_procedure(params)
  end

  defp create_update_procedure(nil, params) do
    %Procedure{}
    |> Procedure.changeset(params)
    |> Repo.insert()
  end

  defp create_update_procedure(procedure, params) do
    procedure
    |> Procedure.changeset(params)
    |> Repo.update()
  end

  #Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([r], asc: r.code)
  defp order_datatable(query, "desc", "asc"), do: query |> order_by([r], asc: r.desc)
  defp order_datatable(query, "type", "asc"), do: query |> order_by([r], asc: r.type)
  defp order_datatable(query, "standard", "asc"), do: query |> order_by([r], asc: r.standard)
  defp order_datatable(query, "rate_type", "asc"), do: query |> order_by([r], asc: r.rate_type)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([r], desc: r.code)
  defp order_datatable(query, "desc", "desc"), do: query |> order_by([r], desc: r.desc)
  defp order_datatable(query, "type", "desc"), do: query |> order_by([r], desc: r.type)
  defp order_datatable(query, "standard", "desc"), do: query |> order_by([r], desc: r.standard)
  defp order_datatable(query, "rate_type", "desc"), do: query |> order_by([r], desc: r.rate_type)

  defp validate_key(changeset, ""), do: changeset |> Changeset.change(search_value: "")
  defp validate_key(changeset, _params), do: changeset |> validate_search_value(changeset.changes)

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end
  defp validate_search_value(changeset, _changes), do: changeset

  defp get_by(params) do
    Procedure |> Repo.get_by(params)
  end
end
