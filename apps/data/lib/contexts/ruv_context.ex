defmodule Data.Contexts.RuvContext do
  @moduledoc false

  alias Ecto.Changeset
  import Ecto.Query

  alias Data.{
    Repo,
    Schemas.Procedure,
    Schemas.Room,
    Schemas.Ruv,
    Schemas.RuvMultiplier
  }

  def validate_params(:search, params) do

    fields = %{
      page_number: :integer,
      search_value: :string,
      display_per_page: :integer,
      sort_by: :string,
      order_by: :string
    }

    changeset =
      {%{}, fields}
      |> Changeset.cast(params, Map.keys(fields))
      |> Changeset.validate_required([
        :page_number,
        :display_per_page,
        :sort_by,
        :order_by
      ],
        message: "is required")
    {changeset.valid?, changeset}

  end

  def get_ruvs({:error, changeset}), do: {:error, changeset}
  def get_ruvs(params) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Ruv
    |> join(:inner, [r], p in Procedure, on: p.code == r.code)
    |> where([r, p],
      ilike(r.code, ^"%#{search_value}%") or
      ilike(p.desc, ^"%#{search_value}%") or
      ilike(fragment("to_char(?, '00')", r.unit), ^"%#{search_value}%")
    )
    |> select([r, p],
      %{
        code: r.code,
        name: p.standard,
        unit: r.unit

      }
    )
    |> order_datatable(
      params.sort_by,
      params.order_by
    )
    |> offset(^offset)
    |> limit(^params.display_per_page)
    |> Repo.all()

  end

  def validate_params(:view, params) do
    fields = %{
      code: :string
    }

    changeset =
      {%{}, fields}
      |> Changeset.cast(params, Map.keys(fields))
      |> Changeset.validate_required([
        :code
      ],
        message: "Enter code")
    {changeset.valid?, changeset}
  end

  def get_ruv({:error, changeset}), do: {:error, changeset}
  def get_ruv(params) do
    Ruv
    |> join(:inner, [r], p in Procedure, on: r.code == p.code)
    |> where([r, p], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^params.code))
    |> select([r, p],
      %{
        id: r.id,
        code: p.code,
        desc: p.desc,
        unit: r.unit,
        updated_by: r.updated_by,
        updated_at: r.updated_at
      }
    )
    |> Repo.one()
    |> preload_room()
  end

  defp preload_room(nil), do: nil
  defp preload_room(ruv) do
    multiplier =
      RuvMultiplier
      |> join(:inner, [rm], ro in Room, on: rm.room_code == ro.code)
      |> where([rm, ro], rm.ruv_id == ^ruv.id)
      |> select([rm, ro], %{
        amount: rm.amount,
        effective_date: rm.effective_date,
        room_code: ro.code,
        room_category: ro.category
      })
      |> Repo.all()

    ruv |> Map.put(:ruv_multipliers, multiplier)
  end

  # Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([r], asc: r.code)
  defp order_datatable(query, "unit", "asc"), do: query |> order_by([r], asc: r.unit)
  defp order_datatable(query, "version", "asc"), do: query |> order_by([r], asc: r.version)
  defp order_datatable(query, "status", "asc"), do: query |> order_by([r], asc: r.status)
  defp order_datatable(query, "updated_by", "asc"), do: query |> order_by([r], asc: r.updated_by)


  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([r], desc: r.code)
  defp order_datatable(query, "unit", "desc"), do: query |> order_by([r], desc: r.unit)
  defp order_datatable(query, "version", "desc"), do: query |> order_by([r], desc: r.version)
  defp order_datatable(query, "status", "desc"), do: query |> order_by([r], desc: r.status)
  defp order_datatable(query, "updated_by", "desc"), do: query |> order_by([r], desc: r.updated_by)

  # For seed

 def insert_ruv_seed(params) do
    params
    |> ruv_get_by()
    |> create_update_ruv(params)
  end

  defp create_update_ruv(nil, params) do
    %Ruv{}
    |> Ruv.changeset(params)
    |> Repo.insert()
  end

  defp create_update_ruv(ruv, params) do
    ruv
    |> Ruv.changeset(params)
    |> Repo.update()
  end

  defp ruv_get_by(params) do
    Ruv |> Repo.get_by(params)
  end

end

