defmodule Data.Contexts.MiscellaneousContext do
  @moduledoc false

  alias Data.{
    Repo,
    Schemas.Miscellaneous,
    Schemas.MiscellaneousArchive
  }

  alias Ecto.Changeset, warn: false
  import Ecto.Query

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

  def validate_params(:create, params) do
    map = %{
      "inserted_by" => "masteradmin",
      "updated_by" => "masteradmin",
      "version" => "1",
      "status" => "Active"
    }

    params =
      params
      |> Map.merge(map)

    %Miscellaneous{}
    |> Miscellaneous.changeset(params)
    |> validate_decimal_format(params["max_price"], :max_price)
    |> map_has_key(:code)
    |> validate_miscellaneous_exist()
    |> is_valid_changeset?()
  end

  def validate_params(:create_draft, params) do
    map = %{
      "inserted_by" => "masteradmin",
      "updated_by" => "masteradmin",
      "version" => "1",
      "status" => "Draft"
    }

    params =
      params
      |> Map.merge(map)

    %Miscellaneous{}
    |> Miscellaneous.draft_changeset(params)
    |> validate_decimal_format(params["max_price"], :max_price)
    |> map_has_key(:code)
    |> validate_miscellaneous_exist()
    |> is_valid_changeset?()
  end

  def validate_params(:view, params) do
    fields = %{
      code: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code], message: "entered is invalid")
    |> is_valid_changeset?()
  end


  def validate_params(:version, params) do
    fields = %{
      code: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code], message: "is required")
    |> is_valid_changeset?()
  end

  def validate_params(:version_details, params) do
    fields = %{
      code: :string,
      version: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code, :version], message: "is required")
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

  defp validate_key(changeset, ""), do: changeset |> Changeset.change(search_value: "")
  defp validate_key(changeset, _params), do: changeset |> validate_search_value(changeset.changes)

  defp validate_key(changeset) do
    changeset =
      changeset
      |> validate_search_value(changeset.changes)

    {changeset.valid?, changeset}
  end

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end
  defp validate_search_value(changeset, _changes), do: changeset

  defp map_has_key(changeset, key) do
    changeset.changes
    |> Map.has_key?(key)
    |> has_key(changeset)
  end

  defp has_key(true, changeset), do: changeset
  defp has_key(false, changeset), do: {:error, changeset}

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  def insert_miscellaneous({:error, changeset}), do: {:error, changeset}
  def insert_miscellaneous(params) do
    %Miscellaneous{}
    |> Map.merge(params)
    |> Repo.insert!()
  end

  defp validate_miscellaneous_exist({:error, changeset}), do: changeset
  defp validate_miscellaneous_exist(changeset) do
    changeset.changes
    |> get_miscellaneous()
    |> is_miscellaneous_exists(changeset)
  end

  defp is_miscellaneous_exists(map, miscellaneous_changeset) when is_nil(map), do: miscellaneous_changeset
  defp is_miscellaneous_exists(_, miscellaneous_changeset), do: Changeset.add_error(miscellaneous_changeset, :code, "already exist")

  defp validate_decimal_format(changeset, value, _) when is_nil(value) or value == "", do: changeset
  defp validate_decimal_format(changeset, value, field) when is_integer(value), do: validate_decimal_format(changeset, Integer.to_string(value), field)
  defp validate_decimal_format(changeset, value, field) when is_float(value), do: validate_decimal_format(changeset, Float.to_string(value), field)
  defp validate_decimal_format(changeset, value, field) do
    ~r/^(?!\.?$)[1-9]\d{0,5}(\.\d{0,2})?$/
      |> Regex.match?(value)
      |> is_decimal_valid?(field, changeset)
  end

  defp is_decimal_valid?(true, _, changeset), do: changeset
  defp is_decimal_valid?(false, field, changeset) do
    Changeset.add_error(changeset, field, "is invalid and should be at most 6 characters.")
  end

  def get_miscellaneous(%{code: _code} = params) do
    params
    |> case_insensitive()
  end

  def get_miscellaneous(%{code: _code} = params, :view) do
    params
    |> case_insensitive()
    |> existing_miscellaneous?()
  end

  def get_miscellaneous({:error, changeset}), do: {:error, changeset}

  def get_miscellaneous({:error, changeset}, :view), do: {:error, changeset}

  def get_miscellaneous(params) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Miscellaneous
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

  defp search_datatable(query, search_value) do
    query
    |> where(
      [m],
      ilike(m.code, fragment("REPLACE(?, '_', '\\_')", ^"#{search_value}%"))  or
      ilike(m.description, ^"%#{search_value}%") or
      ilike(fragment("CAST(? AS TEXT)", m.max_price), ^"%#{search_value}%") or
      ilike(fragment("to_char(?, 'Mon-dd-yyyy')", m.updated_at), ^"%#{search_value}%") or
      ilike(m.updated_by, ^"%#{search_value}%")
    )
  end

  defp select_datatable(query) do
    query
    |> select(
      [m],
      %{
        code: m.code,
        description: m.description,
        max_price: m.max_price,
        updated_at: fragment("to_char(?, 'Mon-dd-yyyy')", m.updated_at),
        updated_by: m.updated_by
      }
    )
  end

  defp case_insensitive(params) do
    Miscellaneous
    |> where([m], fragment("LOWER(?)", m.code) == fragment("LOWER(?)", ^params.code))
    |> select([m], m)
    |> Repo.one()
  end

  defp existing_miscellaneous?(map) when is_nil(map), do: {:error_message, "code entered is invalid"}
  defp existing_miscellaneous?(map), do: map

  def get_miscellaneous_versions({:error, changeset}), do: {:error, changeset}
  def get_miscellaneous_versions(%{code: code}) do
    Miscellaneous
    |> where([m], fragment("LOWER(?)", m.code) == fragment("LOWER(?)", ^code))
    |> preload(:miscellaneous_archives)
    |> Repo.one()
  end

  def get_miscellaneous_version_details({:error, changeset}), do: {:error, changeset}
  def get_miscellaneous_version_details(%{code: code, version: version}) do
    m =
      Miscellaneous
      |> where([m], fragment("LOWER(?)", m.code) == fragment("LOWER(?)", ^code))
      |> select([m], count(m.code))
      |> Repo.one()

    ma =
      MiscellaneousArchive
      |> where([ma], fragment("LOWER(?)", ma.miscellaneous_code) == fragment("LOWER(?)", ^code))
      |> select([ma], %{
          item_code: ma.miscellaneous_code,
          desc: ma.description,
          version: ma.version,
          maximum_price: ma.max_price,
          updated_by: ma.updated_by,
          updated_at: ma.updated_at,
        })
      |> Repo.all()

    get_miscellaneous_version_details({version, ma, m})
  end

  def get_miscellaneous_version_details({_version, _m, 0}), do: {:not_found}
  def get_miscellaneous_version_details({_version, [], _}), do: []
  def get_miscellaneous_version_details({version, result, _}) do
    Enum.find(result, &(&1.version == version))
  end

  def get_miscellany({:error, changeset}, _), do: {:error, changeset}
  def get_miscellany(params, :download) do
    search_value = params.search_value

    Miscellaneous
    |> search_datatable(search_value)
    |> select_datatable()
    |> Repo.all()
  end

  #Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([m], asc: m.code)
  defp order_datatable(query, "description", "asc"), do: query |> order_by([m], asc: m.description)
  defp order_datatable(query, "max_price", "asc"), do: query |> order_by([m], asc: m.max_price)
  defp order_datatable(query, "updated_at", "asc"), do: query |> order_by([m], asc: m.updated_at)
  defp order_datatable(query, "updated_by", "asc"), do: query |> order_by([m], asc: m.updated_by)

  #Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([m], desc: m.code)
  defp order_datatable(query, "description", "desc"), do: query |> order_by([m], desc: m.description)
  defp order_datatable(query, "max_price", "desc"), do: query |> order_by([m], desc: m.max_price)
  defp order_datatable(query, "updated_at", "desc"), do: query |> order_by([m], desc: m.updated_at)
  defp order_datatable(query, "updated_by", "desc"), do: query |> order_by([m], desc: m.updated_by)

end
