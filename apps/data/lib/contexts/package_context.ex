defmodule Data.Contexts.PackageContext do
  @moduledoc false

  alias Ecto.Changeset
  import Ecto.Query

  alias Data.{
    Repo,
    Schemas.Package,
    Schemas.Procedure
  }

  def validate_params(:create, params) do
    :create
    |> Package.changeset(%Package{}, params)
    |> validate_package_exist()
    |> validate_package_procedure()
    |> is_valid_changeset?()
  end

  def validate_params(:view, params) do
    fields = %{
      code: :string,
      procedure: :map
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code], message: "is required")
    |> is_valid_changeset?()
  end

  def validate_params(:search, params) do
    fields = %{
      page_number: :integer,
      search_value: :string,
      display_per_page: :integer,
      sort_by: :string,
      order_by: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([
      :page_number,
      :display_per_page,
      :sort_by,
      :order_by
    ], message: "is required")
    |> is_valid_changeset?()
  end

  defp map_has_key(changeset, key) do
    changeset.changes
    |> Map.has_key?(key)
    |> has_key(changeset)
  end

  defp has_key(true, changeset), do: changeset
  defp has_key(false, changeset), do: {:error, changeset}

  defp validate_package_exist(changeset) do
    changeset
    |> map_has_key(:code)
    |> get_package()
    |> is_package_exist(changeset)
  end

  defp get_package({:error, changeset}), do: {:error, changeset}
  defp get_package(changeset) do
    Package
    |> where([p], fragment("LOWER(?)", p.code) == fragment("LOWER(?)", ^changeset.changes.code))
    |> select([p], p.code)
    |> Repo.one()
  end

  defp is_package_exist({:error, changeset}, _), do: changeset
  defp is_package_exist(map, changeset) when is_nil(map), do: changeset
  defp is_package_exist(_, changeset), do: Changeset.add_error(changeset, :code, "Code is already taken")

  defp validate_package_procedure(changeset) do
    if Map.has_key?(changeset.changes, :procedure) do
      procedure = changeset.changes.procedure
      if Enum.empty?(procedure) or procedure == [""] do
        changeset
        |> Changeset.add_error(:procedure, "At least one Procedure needs to be added")
      else
        new_changeset_changes =
          changeset.changes
          |> Map.put(:procedure, Enum.uniq(procedure))

        changeset
        |> Map.put(:changes, new_changeset_changes)
        |> get_procedures()
        |> check_invalid_procedures(changeset)
      end
    else
      changeset
    end
  end

  defp get_procedures(changeset) do
    codes = changeset.changes.procedure

    Procedure
    |> where([p], p.code in ^codes)
    |> select([p], p.code)
    |> Repo.all()
  end

  defp check_invalid_procedures(procedure_codes, changeset) do
    val = Enum.uniq(changeset.changes.procedure) -- procedure_codes

    changeset
    |> return_invalid_procedure_codes(Enum.empty?(val), val)
  end

  defp return_invalid_procedure_codes(changeset, true, _val), do: changeset
  defp return_invalid_procedure_codes(changeset, false, val) do
    changeset
    |> Changeset.add_error(:procedure, "Procedure code/s #{Enum.join(val, ", ")} does not exist")
  end

  def insert_package({:error, changeset}, :create), do: {:error, changeset}
  def insert_package(changeset, :create) do
    {:ok, packages} =
      :create
      |> Package.changeset(%Package{}, changeset)
      |> Repo.insert()

    packages
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  def get_package_procedures({:error, changeset}), do: {:error, changeset}
  def get_package_procedures(params) do
    search_value = if Map.has_key?(params, :procedure), do: params.procedure["search_value"], else: ""
    offset =
      (
        String.to_integer(params.procedure["page_number"]) * String.to_integer(params.procedure["display_per_page"])
      ) - String.to_integer(params.procedure["display_per_page"])

    Package
    |> where([p],
      ilike(p.code, ^"%#{search_value}%")
    )
    |> select([p],
        p
    )
    |> order_datatable(
      params.procedure["sort_by"],
      params.procedure["order_by"]
    )
    |> offset(^offset)
    |> limit(^params.procedure["display_per_page"])
    |> Repo.all()
  end

  def get_packages({:error, changeset}), do: {:error, changeset}
  def get_packages(params) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Package
    |> where([p],
      ilike(p.code, ^"%#{search_value}%") or
      ilike(p.name, ^"%#{search_value}%") or
      ilike(p.updated_by, ^"%#{search_value}%") or
      ilike(fragment("to_char(?, 'Mon-dd-yyyy')", p.updated_at), ^"%#{search_value}%")
    )
    |> select([p],
      %{
        code: p.code,
        name: p.name,
        updated_at: p.updated_at,
        updated_by: p.updated_by
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

  # For Seed
  def insert_package_seed(params) do
    params
    |> get_by()
    |> create_update_package(params)
  end

  defp create_update_package(nil, params) do
    :create
    |> Package.changeset(%Package{}, params)
    |> Repo.insert()
  end

  defp create_update_package(package, params) do
    :create
    |> Package.changeset(package, params)
    |> Repo.update()
  end

  defp get_by(params) do
    Package |> Repo.get_by(params)
  end

  # Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([p], asc: p.code)
  defp order_datatable(query, "name", "asc"), do: query |> order_by([p], asc: p.name)
  defp order_datatable(query, "procedure", "asc"), do: query |> order_by([p], asc: p.procedure)
  defp order_datatable(query, "version", "asc"), do: query |> order_by([p], asc: p.version)
  defp order_datatable(query, "created_by", "asc"), do: query |> order_by([p], asc: p.created_by)
  defp order_datatable(query, "inserted_by", "asc"), do: query |> order_by([p], asc: p.inserted_by)
  defp order_datatable(query, "updated_by", "asc"), do: query |> order_by([p], asc: p.updated_by)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([p], desc: p.code)
  defp order_datatable(query, "name", "desc"), do: query |> order_by([p], desc: p.name)
  defp order_datatable(query, "procedure", "desc"), do: query |> order_by([p], desc: p.procedure)
  defp order_datatable(query, "version", "desc"), do: query |> order_by([p], desc: p.version)
  defp order_datatable(query, "created_by", "desc"), do: query |> order_by([p], desc: p.created_by)
  defp order_datatable(query, "inserted_by", "desc"), do: query |> order_by([p], desc: p.inserted_by)
  defp order_datatable(query, "updated_by", "desc"), do: query |> order_by([p], desc: p.updated_by)
end
