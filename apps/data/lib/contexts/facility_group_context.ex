defmodule Data.Contexts.FacilityGroupContext do
  @moduledoc false
  alias Ecto.Changeset
  import Ecto.{Query, Changeset}, warn: false

  alias Data.{
    Repo,
    Schemas.Facility,
    Schemas.FacilityGroup,
    Schemas.Sequence
  }

  def validate_params(:search, params) do
    fields = %{
      page_number: :integer,
      search_value: :string,
      display_per_page: :integer,
      sort_by: :string,
      order_by: :string
    }

    changeset = {%{}, fields}
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

  def validate_params(:create, params) do
    fields = %{
      code: :string,
      name: :string,
      description: :string,
      selecting_type: :string,
      version: :string,
      status: :string
    }

    fg_params =
      params
      |> Map.put("version", "1")
      |> Map.put("status", "active")

    changeset = {%{}, fields}
    |> Changeset.cast(fg_params, Map.keys(fields))
    |> Changeset.validate_required([:name], message: "Enter Facility Group Name.")
    |> Changeset.validate_required([:description], message: "Enter Facility Group Description.")
    |> Changeset.validate_required([:selecting_type], message: "Select selecting type.")
    |> Changeset.validate_length(:name, max: 80, message: "Name must not exceed 80 characters")
    |> Changeset.validate_length(:description, max: 80, message: "Description must not exceed 80 characters")
    |> Changeset.validate_format(:name, ~r/^[a-zA-Z0-9 ():-]*$/, message: "Name is invalid")
    |> Changeset.validate_format(:description, ~r/^[a-zA-Z0-9 ():-]*$/, message: "Description is invalid")
    |> Changeset.validate_inclusion(:selecting_type, ["R", "F"], message: "Selecting type is invalid")
    |> validate_facility_group_name()
    |> validate_selecting_type(:selecting_type, params)

    {changeset.valid?, changeset}
  end

  def get_facility_groups({:error, changeset}), do: {:error, changeset}
  def get_facility_groups(params) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    FacilityGroup
    |> where([f],
      ilike(f.code, ^"%#{search_value}%") or
      ilike(f.name, ^"%#{search_value}%") or
      ilike(f.description, ^"%#{search_value}%")
    )
    |> select([f],
      %{
        code: f.code,
        name: f.name,
        description: f.description
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

  # Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([f], asc: f.code)
  defp order_datatable(query, "name", "asc"), do: query |> order_by([f], asc: f.name)
  defp order_datatable(query, "description", "asc"), do: query |> order_by([f], asc: f.description)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([f], desc: f.code)
  defp order_datatable(query, "name", "desc"), do: query |> order_by([f], desc: f.name)
  defp order_datatable(query, "description", "desc"), do: query |> order_by([f], desc: f.description)

  defp validate_selecting_type(changeset, key, params) do
    if Map.has_key?(changeset.changes, key) do
      case changeset.changes[key] |> String.downcase() do
        "r" ->
          changeset |> set_region_params(params)
        "f" ->
          changeset |> set_facility_params(params)

        _ ->
          changeset
      end
    else
        changeset
    end
  end

  ### SELECTING TYPE REGION

  defp set_region_params(changeset, params) do
    fields = %{regions: :map}
    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:regions], message: "Enter regions.")
    |> Changeset.merge(changeset)
    |> check_region_keys()
    |> check_region_true_values()
  end

  defp check_region_keys(changeset) do
    keys = [
     check_true?(changeset, "all_luzon"),
     check_true?(changeset, "all_visayas"),
     check_true?(changeset, "all_mindanao"),
     check_true?(changeset, "regions")
    ]|> Enum.filter(& &1)
    {keys, changeset}
  end

  defp check_true?(changeset, "regions") do
    with true <- Map.has_key?(changeset.changes, :regions),
         true <- Map.has_key?(changeset.changes.regions, "regions"),
         false <- Enum.empty?(changeset.changes.regions["regions"])
    do
        "regions"
    else
      _ ->
        nil
    end
  end

  defp check_true?(changeset, key) do
    with true <- Map.has_key?(changeset.changes, :regions),
         true <- Map.has_key?(changeset.changes.regions, key)
    do
      if changeset.changes.regions[key] do
        key
      end
    else
      _ ->
        nil
    end
  end

  defp check_region_true_values({[], changeset}),
  do: add_error(changeset, :regions, "Select at least one region.")
  defp check_region_true_values({regions, changeset}) do
    if Enum.member?(regions, "regions") do
      changeset
      |> validate_region_name(changeset.changes.regions["regions"], :regions)
      |> transform_island_group()
      |> check_changeset()
      |> transform_region_codes()
      |> validate_region_in_island_group(regions)
    else
      remove_regions_from_changeset(changeset)
    end
  end

  defp remove_regions_from_changeset(changeset) do
    changeset
    |> transform_island_group()
    |> put_change(:regions, [])
  end

  defp validate_region_in_island_group({:error, changeset}, _regions), do: changeset
  defp validate_region_in_island_group(changeset, regions) do
    filtered_regions = remove_region_per_island(regions, [], changeset.changes.regions)
    put_change(changeset, :regions, filtered_regions)
  end

  defp remove_region_per_island([head|tails], result, regions) do
    regions = result ++ region_filter(head, regions)
    remove_region_per_island(tails, result, regions)
  end
  defp remove_region_per_island([], _, regions), do: regions

  defp region_filter("all_luzon", regions) do
    valid_luzon = ["R-I", "R-II", "R-III", "R-IVA", "R-IVB", "RV", "CAR", "NCR"]
    regions -- valid_luzon
  end

  defp region_filter("all_visayas", regions) do
    valid_visayas = ["R-VI", "R-VII", "R-VIII"]
    regions -- valid_visayas
  end

  defp region_filter("all_mindanao", regions) do
    valid_mindanao = ["R-IX", "R-X", "R-XI", "R-XII", "R-XIII", "ARMM"]
    regions -- valid_mindanao
  end

  defp region_filter("regions", regions), do: regions

  defp transform_island_group(changeset) do
    key = changeset.changes.regions
    fields = %{all_luzon: :boolean,
      all_visayas: :boolean,
      all_mindanao: :boolean
    }
    {%{}, fields}
    |> Changeset.cast(key, Map.keys(fields))
    |> Changeset.merge(changeset)
  end

  defp transform_region_codes({false, changeset}), do: {:error, changeset}
  defp transform_region_codes({true, changeset}) do
   new_region = Enum.map(changeset.changes.regions["regions"], fn(region_code) ->
      case region_code do
         "NCR" ->
           "NCR"
        "CAR" ->
          "CAR"
        "ARMM" ->
          "ARMM"
        _ ->
          rcode =
            region_code
            |> String.upcase()
            |> String.replace("-", "")
            |> String.split(" ")
            |> List.delete_at(0)
          "R-#{rcode}"
      end
    end)
    put_change(changeset, :regions, new_region)
  end

  defp validate_region_name(changeset, regions, field) do
    valid_region = ["region i", "region ii", "region iii",
                    "region iv-a", "region iv-b", "car",
                    "ncr", "region v", "region vi", "region vii",
                    "region viii", "region ix", "region x",
                    "region xi", "region xii", "region xiii",
                    "armm"
    ]
    for region_record <- regions do
      if !Enum.member?(valid_region, String.downcase(region_record)) do
        add_error(changeset, field, "#{region_record} is invalid.")
      end
    end
    |> Enum.uniq
    |> List.delete(nil)
    |> check_duplicate_region(changeset, field, regions, valid_region)
  end

  defp check_duplicate_region(result, changeset, field, region, valid_region) do
    if Enum.empty?(result) do
      downcased_region = for region_record <- region do
        String.downcase(region_record)
      end

      regions = downcased_region -- valid_region
      region_case = validate_casing_region(regions)

      if Enum.empty?(regions) do
        changeset
      else
        changeset
        |> add_error(field, "Duplicate Regions: #{Enum.join(region_case, ", ")}")
      end
    else
      merge_changeset_errors(result, changeset)
    end
  end

  defp validate_casing_region(list) do
    regions =
      list
      |> Enum.map(fn(x) -> String.downcase(x) end)

    for region <- regions do
      case region do
        "ncr" ->
          "NCR"
        "car" ->
          "CAR"
        "armm" ->
          "ARMM"
        _ ->
          region
          |> String.split(" ")
          |> Enum.map(fn(x) -> capitalize_word(x) end)
          |> Enum.join(" ")
      end
    end
  end

  defp capitalize_word(word) do
    field =
      word
      |> String.split("  ")
      |> List.delete("")

    first_letter =
      field
      |> List.first
      |> String.upcase

    field
    |> List.replace_at(0, first_letter)
    |> List.to_string
  end

  ### SELECTING TYPE FACILITY

  defp set_facility_params(changeset, params) do
    fields = %{facility_codes: {:array, :string}}
    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.merge(changeset)
    |> validate_facility_code()
  end

  defp validate_facility_code(changeset) do
    with true <- Map.has_key?(changeset.changes, :facility_codes),
         {:ok, facility} <- check_if_exist?(:facility_code,
                                            !Enum.empty?(changeset.changes.facility_codes),
                                            changeset.changes.facility_codes),
         changeset <- get_invalid_values(:facility_code,
                                         changeset,
                                        facility,
                                         changeset.changes.facility_codes)
    do
      changeset
    else
      _ ->
        add_error(changeset, :facility_codes, "Enter facility code.")
    end
  end

  defp get_invalid_values(key, changeset, val1, val2) do
    changeset
    |> return_invalid_facility_codes(Enum.empty?(val2), key, val1, val2)
  end

  defp return_invalid_facility_codes(changeset, true, _key, _val1, _val2), do: changeset
  defp return_invalid_facility_codes(changeset, false, key, val1, val2) do
    val = Enum.uniq(val2) -- val1
    changeset
    |> return_invalid_facility_codes(Enum.empty?(val), key, val)
  end

  defp return_invalid_facility_codes(changeset, true, _key, _val), do: changeset
  defp return_invalid_facility_codes(changeset, false, key, val) do
    changeset
    |> add_error(key, "Facility Code #{Enum.join(val, ", ")} does not exist.")
  end

  defp check_if_exist?(:facility_code, false, facility_codes), do: {:error, facility_codes}
  defp check_if_exist?(:facility_code, true, facility_codes) do
    f_code =
      Facility
      |> where([f], f.code in ^facility_codes)
      |> select([f], f.code)
      |> Repo.all()
    {:ok, f_code}
  end

  defp check_if_exist?(:name, name) do
    FacilityGroup
    |> where([fg], fg.name == ^name)
    |> select([fg], fg.code)
    |> Repo.one()
  end

  defp validate_facility_group_name(changeset) do
    with true <- Map.has_key?(changeset.changes, :name),
         nil <- check_if_exist?(:name, changeset.changes.name) do
        changeset
    else
      false ->
        changeset #returns name is required
      _ ->
        add_error(changeset, :name, "Facility group name already exist.")
    end
  end

  def insert_facility_group({:error, changeset}), do: {:error, changeset}
  def insert_facility_group(params) do
    sequence = get_sequence("facility_group_code")
    params =
      params
      |> Map.put(:code, "FG-#{sequence.number}")
    {:ok, facility_group} =
      %FacilityGroup{}
      |> FacilityGroup.changeset(params)
      |> Repo.insert

    facility_group
  end

  def get_sequence(type) do
    query =
      from(s in Sequence,
      order_by: [desc: s.inserted_at],
      limit: 1)

    sequence =
      query
      |> where([s], s.type == ^type)
      |> Repo.one()

    Repo.update(Changeset.change sequence, number: "#{String.to_integer(sequence.number) + 1}")

    sequence
  end

  defp check_changeset(changeset), do: {changeset.valid?, changeset}

  defp merge_changeset_errors([head|tails], changeset), do: merge_changeset_errors(tails, Changeset.merge(changeset, head))
  defp merge_changeset_errors([], changeset), do: changeset

  def validate_params(:view, params) do
    fields = %{
      code: :string
    }

    changeset =
      {%{}, fields}
      |> Changeset.cast(params, Map.keys(fields))
      |> Changeset.validate_required([:code], message: "code entered is invalid!")

    {changeset.valid?, changeset}
  end

  def get_facility_group({:error, changeset}), do: {:error, changeset}
  def get_facility_group(%{code: code} = params) do
    params
    |> case_insensetive()
    |> existing_facility_group?()
  end

  defp case_insensetive(params) do
    FacilityGroup
    |> where([fg], fragment("LOWER(?)", fg.code) == fragment("LOWER(?)", ^params.code))
    |> select([fg], fg)
    |> Repo.one()
  end

  defp existing_facility_group?(params) when is_nil(params),  do: {:error_message, "code entered is invalid"}
  defp existing_facility_group?(params), do: params

end
