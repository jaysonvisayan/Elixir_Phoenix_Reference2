defmodule Data.Contexts.RoomContext do
  @moduledoc false
  alias Ecto.Changeset
  import Ecto.Query

  alias Data.{
    Repo,
    Schemas.Facility,
    Schemas.FacilityRoom,
    Schemas.Room,
    Schemas.RoomArchive
  }

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
    |> Changeset.validate_required([:page_number, :display_per_page, :sort_by, :order_by], message: "is required")
    |> validate_key(params["search_value"])
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

  def validate_params(:version, params) do
    fields = %{
      code: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([
      :code,
    ])
    |> fetch_room_by_code(:code)
    |> is_valid_changeset?()
  end

  def validate_params(:version_details, params) do
    fields = %{
      code: :string,
      version: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([
      :code,
      :version
    ])
    |> fetch_room_by_code(:code)
    |> fetch_room_version_details(:version)
    |> is_valid_changeset?()
  end

  def validate_params(:create, params) do
    :create
    |> Room.changeset(%Room{}, params)
    |> validate_room_exist(:create)
    |> validate_room_category_exist(:create)
    |> is_valid_changeset?()
  end

  def validate_params(:create_draft, params) do
    :create_draft
    |> Room.changeset_draft(%Room{}, params)
    |> validate_room_exist(:create_draft)
    |> validate_room_category_exist(:create_draft)
    |> is_valid_changeset?()
  end

  def validate_params(:view, %{"code" => _code, "facility_room" => params2 } = params) do
    fields = %{
      code: :string,
      facility_room: :map
    }

    changeset =
      {%{}, fields}
      |> Changeset.cast(params, Map.keys(fields))
      |> Changeset.validate_required([:code, :facility_room], message: "is required")
    if changeset.valid? do
      fields1 = %{
        search_value: :string,
        page_number: :integer,
        display_per_page: :integer,
        sort_by: :string,
        order_by: :string
      }

      changeset1 =
        {%{}, fields1}
        |> Changeset.cast(params2, Map.keys(fields1))
        |> Changeset.validate_required([:page_number, :display_per_page, :sort_by, :order_by], message: "is required")

        {changeset1.valid?, Map.put(changeset1, :changes, Map.put(changeset.changes, :facility_room, changeset1.changes))}
    else
      {changeset.valid?, changeset}
    end
  end

  def validate_params(:view, %{"code" => _code} = params) do
    fields = %{
      code: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code], message: "is required")
    |> is_valid_changeset?()
  end

  def validate_params(:view, %{"facility_room" => _params2 } = params) do
    fields = %{
      code: :string,
      facility_room: :map
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code, :facility_room], message: "is required")
    |> is_valid_changeset?()
  end

  def validate_params(:delete, params) do
    {map, changeset} =
      :delete
      |> Room.changeset(%Room{}, params)
      |> validate_room_exist(:delete)
      |> validate_room_status()
      |> validate_room_facilities_exist()

    {changeset.valid?, {map, changeset}}
  end

  def validate_params(:update, params) do
    changeset =
      :update
      |> Room.changeset(%Room{}, params)

    {map, changeset} =
      :update
      |> validate_room_exists(changeset.valid?, changeset)

    {changeset.valid?, {map, changeset}}
  end

  def get_rooms({:error, changeset}, :search), do: {:error, changeset}

  def get_rooms(params, :search) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Room
    |> where([r],
             ilike(r.code, ^"%#{search_value}%") or
             ilike(r.category, ^"%#{search_value}%") or
             ilike(fragment("CAST(? AS TEXT)", r.hierarchy), ^"%#{search_value}%") or
             ilike(fragment("to_char(?, 'MON DD, YYYY')", r.updated_at), ^("%#{search_value}%")) or
             ilike(r.updated_by, ^"%#{search_value}%")
    )
    |> select([r], %{
      code: r.code,
      category: r.category,
      hierarchy: r.hierarchy,
      updated_at: fragment("to_char(?, 'MON DD, YYYY')", r.updated_at),
      updated_by: r.updated_by
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

  def get_rooms({:error, changeset}, :download), do: {:error, changeset}
  def get_rooms(params, :download) do
    search_value = params.search_value

    Room
    |> where([r],
             ilike(r.code, ^"%#{search_value}%") or
             ilike(r.category, ^"%#{search_value}%") or
             ilike(fragment("CAST(? AS TEXT)", r.hierarchy), ^"%#{search_value}%") or
             ilike(fragment("to_char(?, 'MON DD, YYYY')", r.updated_at), ^("%#{search_value}%")) or
             ilike(r.updated_by, ^"%#{search_value}%")
    )
    |> select([r], %{
      code: r.code,
      category: r.category,
      hierarchy: r.hierarchy,
      updated_at: fragment("to_char(?, 'MON DD, YYYY')", r.updated_at),
      updated_by: r.updated_by
    })
    |> Repo.all()
  end

  defp validate_key(changeset) do
    changeset
    |> validate_search_value(changeset.changes)
    |> is_valid_changeset?()
  end

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end
  defp validate_search_value(changeset, _changes), do: changeset

  def get_room({:error, changeset}), do: {:error, changeset}
  def get_room(params) do
    room =
      Room
      |> Repo.get_by(code: params.code)

    frr = if Map.has_key?(params, :facility_room), do: params.facility_room

    {room, frr}
  end

  def get_room_facilities({:error, changeset}), do: {:error, changeset}
  def get_room_facilities({nil, _}), do: nil

  def get_room_facilities({room, nil}) do
    Map.put(room, :facility_room,
            initialize_query()
            |> select([fr, f, r],
                      %{
                        facility_code: f.code,
                        facility_name: f.name,
                        facility_room_type: fr.room_type,
                        facility_room_rate: fr.room_rate
                      }
            )
            |> Repo.all()
    )
  end

  def get_room_facilities({room, params}) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Map.put(room, :facility_room,
            initialize_query()
            |> where([fr, f, r], r.code == ^room.code)
            |> where([fr, f, r],
                     ilike(f.code, ^"%#{search_value}%") or
                     ilike(f.name, ^"%#{search_value}%") or
                     ilike(fr.room_type, ^"%#{search_value}%") or
                     ilike(fragment("CAST(? AS TEXT)", fr.room_rate), ^"%#{search_value}%")
            )
            |> select([fr, f, r],
                      %{
                        facility_code: f.code,
                        facility_name: f.name,
                        facility_room_type: fr.room_type,
                        facility_room_rate: fr.room_rate
                      }
            )
            |> order_datatable(
              params.sort_by,
              params.order_by
            )
            |> offset(^offset)
            |> limit(^params.display_per_page)
            |> Repo.all()
    )
  end

  defp initialize_query do
    # Sets initial query of the table.

    FacilityRoom
    |> join(:inner, [fr], f in Facility, on: fr.facility_code == f.code)
    |> join(:inner, [fr, f], r in Room, on: fr.room_code == r.code)
  end

  # Ascending
  defp order_datatable(query, nil, nil), do: query
  defp order_datatable(query, "", ""), do: query
  defp order_datatable(query, "code", "asc"), do: query |> order_by([r], asc: r.code)
  defp order_datatable(query, "category", "asc"), do: query |> order_by([r], asc: r.category)
  defp order_datatable(query, "hierarchy", "asc"), do: query |> order_by([r], asc: r.hierarchy)
  defp order_datatable(query, "updated_at", "asc"), do: query |> order_by([r], asc: r.updated_at)
  defp order_datatable(query, "updated_by", "asc"), do: query |> order_by([r], asc: r.updated_by)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([r], desc: r.code)
  defp order_datatable(query, "category", "desc"), do: query |> order_by([r], desc: r.category)
  defp order_datatable(query, "hierarchy", "desc"), do: query |> order_by([r], desc: r.hierarchy)
  defp order_datatable(query, "updated_at", "desc"), do: query |> order_by([r], desc: r.updated_at)
  defp order_datatable(query, "updated_by", "desc"), do: query |> order_by([r], desc: r.updated_by)

  # Ascending
  defp order_datatable(query, "facility_code", "asc"), do: query |> order_by([fr, f], asc: f.code)
  defp order_datatable(query, "facility_name", "asc"), do: query |> order_by([fr, f], asc: f.name)
  defp order_datatable(query, "facility_room_type", "asc"), do: query |> order_by([fr, f], asc: fr.room_type)
  defp order_datatable(query, "facility_room_rate", "asc"), do: query |> order_by([fr, f], asc: fr.room_rate)

  # Descending
  defp order_datatable(query, "facility_code", "desc"), do: query |> order_by([f], desc: f.code)
  defp order_datatable(query, "facility_name", "desc"), do: query |> order_by([f], desc: f.name)
  defp order_datatable(query, "facility_room_type", "desc"), do: query |> order_by([f, fr], desc: fr.room_type)
  defp order_datatable(query, "facility_room_rate", "desc"), do: query |> order_by([f, fr], desc: fr.room_rate)

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  defp fetch_room_by_code(%{changes: %{code: code }} = changeset, key) do
    with true <- changeset.valid?,
         %Room{} <- fetch_using_lowercase(%{code: code})
    do
      changeset
    else
      false ->
        changeset
      nil ->
        Changeset.add_error(changeset, key, "is not existing!")
    end
  end
  defp fetch_room_by_code(changeset, _key), do: changeset

  defp fetch_using_lowercase(param) do
    Room
    |> where([r], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^param.code))
    |> Repo.one()
  end

  def get_room_versions({:error, changeset}), do: {:error, changeset}
  def get_room_versions(%{code: _code} = params) do
    params
    |> fetch_using_lowercase()
    |> preload_struct([:room_archives])
  end

  defp preload_struct(struct, load) do
    struct
    |> Repo.preload(load)
  end

  defp get_by(params) do
    Room |> Repo.get_by(params)
  end

  defp fetch_room_version_details(%{changes: %{code: _code, version: _version}} = changeset, key) do
    changeset.valid?
    |> changeset_valid?(changeset, key)
  end
  defp fetch_room_version_details(changeset, _key), do: changeset

  defp changeset_valid?(true, changeset, key) do
    case get_room_version_details(changeset, key) do
      {:ok, result} ->
        changeset |> Changeset.put_change(:result, result |> check_struct())

      nil ->
        changeset |> Changeset.add_error(key, "is not existing!")
    end
  end
  defp changeset_valid?(false, changeset, _key), do: changeset

  defp check_struct(%Room{} = result), do: result
  defp check_struct(%RoomArchive{} = result), do: result

  def get_room_version_details(%{changes: params = %{code: _code, version: _version}} = changeset, key) do
    params
    |> fetch_code_and_version()
    |> filter_room_version(changeset, key)
  end

  defp fetch_code_and_version(%{code: code, version: version}) do
    Room
    |> join(:left, [r], ra in RoomArchive, ra.room_code == r.code)
    |> where([r, ra], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^code) and ra.version == ^version)
    |> or_where([r, ra], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^code) and r.version == ^version)
    |> select([r, ra], [r, ra])
    |> distinct([r, ra], [r.code, r.version])
    |> Repo.one()
  end
  defp fetch_code_and_version(changeset), do: changeset

  defp filter_room_version(nil, _changeset, _key), do: nil
  defp filter_room_version(result, %{changes: %{version: version}}, _key) do
    {:ok, result |> Enum.find(fn(x) -> x.version == version end)}
  end

  def room_version_detail_result({:error, changeset}), do: {:error, changeset}
  def room_version_detail_result(params), do: params.result

  def map_has_key({:error, changeset}, _key, _create_room), do: {:error, changeset}
  def map_has_key(changeset, key, _create_room) do
    changeset.changes
    |> Map.has_key?(key)
    |> has_key(changeset)
  end

  def has_key(true, changeset), do: changeset
  def has_key(false, changeset), do: {:error, changeset}

  defp validate_room_exist({:error, changeset}, :create), do: {:error, changeset}
  defp validate_room_exist(changeset, :create) do
    changeset
    |> map_has_key(:code, :create)
    |> check_room()
    |> is_room_exist(changeset, :create)
  end

  defp validate_room_exist({:error, changeset}, :delete), do: {:error, changeset}
  defp validate_room_exist(changeset, :delete) do
    check_room_code(Map.has_key?(changeset.changes, :code), changeset)
  end

  defp check_room_code(false, changeset), do: {:error, changeset}
  defp check_room_code(true, changeset) do
    changeset.changes.code
    |> get_room_for_update_delete()
    |> is_room_exist(changeset, :delete)
  end

  def validate_room_status({:error, changeset}), do: {:error, changeset}
  def validate_room_status({map, changeset}) do
    map.status |> check_status({map, changeset})
  end

  defp check_status(nil, {_, changeset}) do
    {:error, changeset |> Changeset.add_error(:error, "Room is not Active")}
  end

  defp check_status("", {_, changeset}) do
    {:error, changeset |> Changeset.add_error(:error, "Room is not Active")}
  end

  defp check_status("Draft", {_, changeset}) do
    {:error, changeset |> Changeset.add_error(:error, "Room is not Active")}
  end

  defp check_status("Deleted", {_, changeset}) do
    {:error, changeset |> Changeset.add_error(:error, "Room is already deleted")}
  end

  defp check_status("Active", {map, changeset}), do: {map, changeset}

  def validate_room_facilities_exist({:error, changeset}), do: {:error, changeset}

  def validate_room_facilities_exist({map, changeset}) do
    map.facility_rooms |> check_facility_room_exist({map, changeset})
  end

  defp check_facility_room_exist([], {map, changeset}), do: {map, changeset}
  defp check_facility_room_exist(_, {_, changeset}) do
    {:error, changeset |> Changeset.add_error(:error, "Room cannot be deleted, already attached in facilities")}
  end

  defp validate_room_exist({:error, changeset}, :create_draft), do: {:error, changeset}
  defp validate_room_exist(changeset, :create_draft) do
    changeset
    |> map_has_key(:code, :create_draft)
    |> check_room()
    |> is_room_exist(changeset, :create_draft)
  end

  defp validate_room_category_exist({:error, changeset}, :create), do: changeset
  defp validate_room_category_exist(changeset, :create) do
    changeset
    |> map_has_key(:category, :create)
    |> get_room_category()
    |> is_room_category_exist(changeset, :create)
  end

  defp validate_room_category_exist({:error, changeset}, :create_draft), do: changeset
  defp validate_room_category_exist(changeset, :create_draft) do
    changeset
    |> map_has_key(:category, :create_draft)
    |> get_room_category()
    |> is_room_category_exist(changeset, :create_draft)
  end

  def validate_room_exists(:update, false, changeset), do: {:error, changeset}
  def validate_room_exists(:update, true, changeset) do
    changeset.changes.code
    |> get_room_for_update_delete()
    |> is_room_exist(changeset, :update)
  end

  def validate_room_exists(changeset) do
    changeset.changes.code
    |> get_room_for_update_delete()
    |> is_room_exist(changeset)
  end

  defp get_room_for_update_delete({:error, changeset}), do: {:error, changeset}
  defp get_room_for_update_delete(code) do
    Room
    |> where([r], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^code))
    |> select([r], r)
    |> Repo.one()
    |> Repo.preload(:facility_rooms)
  end

  defp check_room({:error, changeset}), do: {:error, changeset}
  defp check_room(changeset) do
    Room
    |> where([r], fragment("LOWER(?)", r.code) == fragment("LOWER(?)", ^changeset.changes.code))
    |> select([r], r)
    |> Repo.one()
  end

  defp get_room_category({:error, changeset}), do: {:error, changeset}
  defp get_room_category(changeset) do
    Room
    |> where([r], fragment("LOWER(?)", r.category) == fragment("LOWER(?)", ^changeset.changes.category))
    |> select([r], r)
    |> Repo.one()
  end

  defp is_room_exist(map, changeset) when is_nil(map), do: changeset
  defp is_room_exist(_, changeset), do: Changeset.add_error(changeset, :code, "is already taken")

  defp is_room_exist(map, changeset, :update) when is_nil(map), do: {:error, Changeset.add_error(changeset, :code, "not found!")}
  defp is_room_exist(map, changeset, :update), do: {map, changeset}

  defp is_room_exist({:error, changeset}, changeset, :create), do: changeset
  defp is_room_exist(map, changeset, :create) when is_nil(map), do: changeset
  defp is_room_exist(_, changeset, :create), do: Changeset.add_error(changeset, :code, "is already taken")

  defp is_room_exist({:error, changeset}, changeset, :create_draft), do: changeset
  defp is_room_exist(map, changeset, :create_draft) when is_nil(map), do: changeset
  defp is_room_exist(_, changeset, :create_draft), do: Changeset.add_error(changeset, :code, "is already taken")

  defp is_room_category_exist({:error, changeset}, changeset, :create), do: changeset
  defp is_room_category_exist(map, changeset, :create) when is_nil(map), do: changeset
  defp is_room_category_exist(_, changeset, :create), do: Changeset.add_error(changeset, :category, "is already taken")

  defp is_room_facilities_exist(map, changeset, :update) when is_nil(map), do: {:error, Changeset.add_error(changeset, :code, "not found!")}

  defp is_room_facilities_exist(map, changeset, :update), do: {map, changeset}

  defp is_room_facilities_exist(map, changeset) when is_nil(map), do: {map, changeset}
  defp is_room_facilities_exist(_, changeset), do: Changeset.add_error(changeset, :code, "already exist")

  defp is_room_category_exist({:error, changeset}, changeset, :create_draft), do: changeset
  defp is_room_category_exist(map, changeset, :create_draft) when is_nil(map), do: changeset
  defp is_room_category_exist(_, changeset, :create_draft), do: Changeset.add_error(changeset, :category, "is already taken")

  defp is_room_exist(map, changeset, :delete) when is_nil(map), do: {:error, Changeset.add_error(changeset, :code, "not found!")}
  defp is_room_exist(map, changeset, :delete), do: {map, changeset}

  def insert_rooms({:error, changeset}, :create), do: {:error, changeset}
  def insert_rooms(changeset, :create) do
    :create
    |> Room.changeset(%Room{}, changeset)
    |> Repo.insert!()
  end

  def insert_rooms({:error, changeset}, :create_draft), do: {:error, changeset}
  def insert_rooms(changeset, :create_draft) do
    :create_draft
    |> Room.changeset_draft(%Room{}, changeset)
    |> Repo.insert!()
  end

  def insert_version({:error, changeset}), do: {:error, changeset}
  def insert_version({room, changeset}) do
    :insert
    |> RoomArchive.changeset(%RoomArchive{}, get_room_version_params(room, changeset))
    |> Repo.insert()

    {changeset.changes, room}
  end

  defp get_room_version_params(room, changeset) do
    %{
      room_code: room.code,
      category: room.category,
      hierarchy: room.hierarchy,
      version: room.version,
      updated_by: room.updated_by,
      updated_at: room.updated_at,
      change_logs: room_changes_to_string(room, changeset)
    }
  end

  defp room_changes_to_string(room, changeset) do
    Enum.map(Map.drop(changeset.changes, [:code]), fn {key, new_value} ->
      "Room #{transform_atom(key)} updated from #{Map.get(room, key)} to #{new_value}."
    end)
  end

  defp transform_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&(String.capitalize(&1)))
    |> Enum.join(" ")
  end

  def update_room({:error, changeset}, :update), do: {:error, changeset}

  def update_room({params, room}, :update) do
    {:ok, room} =
      :update
      |> Room.changeset(room, params |> Map.merge(%{version: "#{String.to_integer(room.version) + 1}", updated_by: "masteradmin"}))
      |> Repo.update()
    room
  end

  def update_room({:error, changeset}, :delete), do: {:error, changeset}
  def update_room({nil, changeset}, :delete), do: nil
  def update_room({room, changeset}, :delete) do
    {:ok, room} =
      :delete
      |> Room.changeset(room, changeset.changes)
      |> Repo.update()
    room
  end

end
