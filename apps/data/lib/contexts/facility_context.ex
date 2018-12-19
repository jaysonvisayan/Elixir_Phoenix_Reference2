defmodule Data.Contexts.FacilityContext do
  @moduledoc false

  import Ecto.{Query}, warn: false
  alias Data.Repo
  alias Ecto.Changeset
  alias Data.Schemas.{
    Facility,
    FacilityAddress,
    FacilityContact,
    FacilityServiceFee,
    FacilityPpd,
    FacilityPercentDay,
    GenericLookUp,
    AddressLookUp,
    Coverage
  }
  alias Data.Contexts.{
    UtilityContext
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

  def validate_params(:create, params) do
    changeset = :create
    |> Facility.changeset(%Facility{}, params)
    |> validate_facility_address(%FacilityAddress{}, params["addresses"])
    |> validate_facility_contact(%FacilityContact{}, params["contacts"])
    |> validate_facility_service_fee(%FacilityServiceFee{}, params["service_fee"])
    |> validate_facility_ppd(%FacilityPpd{}, params["ppd"])

    if Enum.empty?(changeset.error_addresses) && Enum.empty?(changeset.error_contacts) && Enum.empty?(changeset.error_service_fee) && Enum.empty?(changeset.error_ppd) && changeset.valid? do
      {true, {%{}, changeset}}
    else
      {false, {%{}, changeset}}
    end
  end

  defp validate_key(changeset, ""), do: changeset |> Changeset.change(search_value: "")
  defp validate_key(changeset, _params), do: changeset |> validate_search_value(changeset.changes)

  defp validate_key(changeset) do
    changeset
    |> validate_search_value(changeset.changes)
    |> is_valid_changeset?()
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end
  defp validate_search_value(changeset, _changes), do: changeset

  def get_facilities({:error, changeset}, :search), do: {:error, changeset}
  def get_facilities(params, :search) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Facility
    |> where([f],
             ilike(f.code, ^"%#{search_value}%") or
             ilike(f.name, ^"%#{search_value}%") or
             ilike(fragment("to_char(?, 'MON DD, YYYY')", f.affiliation_date), ^("%#{search_value}%")) or
             ilike(fragment("to_char(?, 'MON DD, YYYY')", f.disaffiliation_date), ^("%#{search_value}%")) or
             ilike(f.status, ^"%#{search_value}%")
    )
    |> select([f], %{
      code: f.code,
      name: f.name,
      affiliation_date: fragment("to_char(?, 'MON DD, YYYY')", f.affiliation_date),
      disaffiliation_date: fragment("to_char(?, 'MON DD, YYYY')", f.disaffiliation_date),
      status: f.status
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
  defp order_datatable(query, "name", "asc"), do: query |> order_by([f], asc: f.category)
  defp order_datatable(query, "affiliation_date", "asc"), do: query |> order_by([f], asc: f.affiliation_date)
  defp order_datatable(query, "disaffiliation_date", "asc"), do: query |> order_by([f], asc: f.disaffiliation_date)
  defp order_datatable(query, "status", "asc"), do: query |> order_by([f], asc: f.status)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([f], desc: f.code)
  defp order_datatable(query, "name", "desc"), do: query |> order_by([f], desc: f.name)
  defp order_datatable(query, "affiliation_date", "desc"), do: query |> order_by([f], desc: f.affiliation_date)
  defp order_datatable(query, "disaffiliation_date", "desc"), do: query |> order_by([f], desc: f.disaffiliation_date)
  defp order_datatable(query, "status", "desc"), do: query |> order_by([f], desc: f.status)

  defp validate_facility_address(changeset, _, nil), do: changeset |> Map.put(:error_addresses, []) |> Changeset.add_error(:addresses, "is required")
  defp validate_facility_address(changeset, _, []), do: changeset |> Map.put(:error_addresses, []) |> Changeset.add_error(:addresses, "is required")

  defp validate_facility_address(changeset, struct, params) do
    address_changeset = for address <- params do
      changeset_address = :create |> FacilityAddress.changeset(struct, address)
      {changeset_address.valid?, changeset_address}
    end

    if Enum.all?(address_changeset, fn({valid, _}) -> valid end) do
      address_changeset = Enum.map(address_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:addresses, address_changeset)
        |> Map.put(:error_addresses, [])
    else
      address_changeset = Enum.map(address_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_addresses, Enum.map(address_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  defp validate_facility_contact(changeset, _, nil), do: changeset |> Map.put(:error_contacts, []) |> Changeset.add_error(:contacts, "is required")
  defp validate_facility_contact(changeset, _, []), do: changeset |> Map.put(:error_contacts, []) |> Changeset.add_error(:contacts, "is required")
  defp validate_facility_contact(changeset, struct, params) do
    contact_changeset = for contact <- params do
      changeset_contact =
        :create
        |> FacilityContact.changeset(struct, contact)
        |> validate_mobile_nos(contact["mobile_nos"])
        |> validate_tel_nos(contact["tel_nos"])
        |> validate_fax_nos(contact["fax_nos"])
      if (!Enum.empty?(changeset_contact.error_mobile) ||
          !Enum.empty?(changeset_contact.error_tel) ||
          !Enum.empty?(changeset_contact.error_fax)) do
            {false, changeset_contact}
      else
        {changeset_contact.valid?, changeset_contact}
      end
    end

    if Enum.all?(contact_changeset, fn({valid, _}) -> valid end) do
      contact_changeset = Enum.map(contact_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:contacts, contact_changeset)
        |> Map.put(:error_contacts, [])
    else
      contact_changeset = Enum.map(contact_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_contacts, Enum.map(contact_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
          |> UtilityContext.check_errors(:mobile_nos, changeset.error_mobile)
          |> UtilityContext.check_errors(:tel_nos, changeset.error_tel)
          |> UtilityContext.check_errors(:fax_nos, changeset.error_fax)
        else
          changeset
          |> UtilityContext.transform_error_message()
          |> UtilityContext.check_errors(:mobile_nos, changeset.error_mobile)
          |> UtilityContext.check_errors(:tel_nos, changeset.error_tel)
          |> UtilityContext.check_errors(:fax_nos, changeset.error_fax)
        end
      end))
    end
  end

  defp validate_mobile_nos(changeset, nil), do: changeset
  defp validate_mobile_nos(changeset, []), do: changeset
  defp validate_mobile_nos(changeset, mobile_nos) do
    fields = %{
      country_code: :string,
      number: :string
    }

    mobile_changeset = for mobile_no <- mobile_nos do
      changeset_mobile =
        {%{}, fields}
        |> Changeset.cast(mobile_no, Map.keys(fields))
        |> Changeset.validate_required([:country_code, :number], message: "is required")
        |> Changeset.validate_inclusion(:country_code, ["+63"])
        |> Changeset.validate_length(:number, max: 10, message: "must be at most 10 numeric characters")
        |> Changeset.validate_format(:number, ~r/^[0-9]*$/)

      {changeset_mobile.valid?, changeset_mobile}
    end

    if Enum.all?(mobile_changeset, fn({valid, _}) -> valid end) do
      changeset |> Map.put(:error_mobile, [])
    else
      mobile_changeset = Enum.map(mobile_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_mobile, Enum.map(mobile_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  defp validate_tel_nos(changeset, []), do: changeset
  defp validate_tel_nos(changeset, nil), do: changeset
  defp validate_tel_nos(changeset, tel_nos) do
    fields = %{
      country_code: :string,
      area_code: :string,
      number: :string,
      local: :string
    }

    tel_changeset = for tel_no <- tel_nos do
      changeset_tel =
        {%{}, fields}
        |> Changeset.cast(tel_no, Map.keys(fields))
        |> Changeset.validate_required([:country_code, :number, :local], message: "is required")
        |> Changeset.validate_required([:area_code], message: "Please include your Area Code")
        |> Changeset.validate_inclusion(:country_code, ["+63"])
        |> Changeset.validate_length(:area_code, max: 6, message: "must be at most 6 numeric characters")
        |> Changeset.validate_format(:area_code, ~r/^[0-9]*$/)
        |> Changeset.validate_length(:number, max: 7, message: "must be at most 7 numeric characters")
        |> Changeset.validate_format(:number, ~r/^[0-9]*$/)
        |> Changeset.validate_length(:local, max: 3, message: "must be at most 3 numeric characters")
        |> Changeset.validate_format(:local, ~r/^[0-9]*$/)

      {changeset_tel.valid?, changeset_tel}
    end

    if Enum.all?(tel_changeset, fn({valid, _}) -> valid end) do
      changeset |> Map.put(:error_tel, [])
    else
      tel_changeset = Enum.map(tel_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_tel, Enum.map(tel_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  defp validate_fax_nos(changeset, []), do: changeset
  defp validate_fax_nos(changeset, nil), do: changeset
  defp validate_fax_nos(changeset, fax_nos) do
    fields = %{
      country_code: :string,
      area_code: :string,
      number: :string,
      local: :string
    }

    fax_changeset = for fax_no <- fax_nos do
      changeset_fax =
        {%{}, fields}
        |> Changeset.cast(fax_no, Map.keys(fields))
        |> Changeset.validate_required([:country_code, :number, :local], message: "is required")
        |> Changeset.validate_required([:area_code], message: "Please include your Area Code")
        |> Changeset.validate_inclusion(:country_code, ["+63"])
        |> Changeset.validate_length(:area_code, max: 6, message: "must be at most 6 numeric characters")
        |> Changeset.validate_format(:area_code, ~r/^[0-9]*$/)
        |> Changeset.validate_length(:number, max: 7, message: "must be at most 7 numeric characters")
        |> Changeset.validate_format(:number, ~r/^[0-9]*$/)
        |> Changeset.validate_length(:local, max: 3, message: "must be at most 3 numeric characters")
        |> Changeset.validate_format(:local, ~r/^[0-9]*$/)

      {changeset_fax.valid?, changeset_fax}
    end

    if Enum.all?(fax_changeset, fn({valid, _}) -> valid end) do
      changeset |> Map.put(:error_fax, [])
    else
      fax_changeset = Enum.map(fax_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_fax, Enum.map(fax_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  defp validate_facility_service_fee(changeset, _, nil), do: changeset |> Map.put(:error_service_fee, []) |> Changeset.add_error(:service_fee, "is required")
  defp validate_facility_service_fee(changeset, _, []), do: changeset |> Map.put(:error_service_fee, []) |> Changeset.add_error(:service_fee, "is required")
  defp validate_facility_service_fee(changeset, struct, params) do
    service_fee_changeset = for service_fee <- params do
      changeset_service_fee = :create |> FacilityServiceFee.changeset(struct, service_fee)
      {changeset_service_fee.valid?, changeset_service_fee}
    end

    if Enum.all?(service_fee_changeset, fn({valid, _}) -> valid end) do
      service_fee_changeset = Enum.map(service_fee_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:service_fee, service_fee_changeset)
        |> Map.put(:error_service_fee, [])
    else
      service_fee_changeset = Enum.map(service_fee_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_service_fee, Enum.map(service_fee_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  defp validate_facility_ppd(changeset, _, nil), do: changeset |> Map.put(:error_ppd, []) |> Changeset.add_error(:ppds, "is required")
  defp validate_facility_ppd(changeset, _, []), do: changeset |> Map.put(:error_ppd, []) |> Changeset.add_error(:ppds, "is required")
  defp validate_facility_ppd(changeset, struct, params) do
    ppd_changeset = for ppd <- params do
      changeset_ppd =
        :create
        |> FacilityPpd.changeset(struct, ppd)
        |> validate_percent_days(ppd["percent_days"])

      {changeset_ppd.valid?, changeset_ppd}
    end

    if Enum.all?(ppd_changeset, fn({valid, _}) -> valid end) do
      ppd_changeset = Enum.map(ppd_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:ppds, ppd_changeset)
        |> Map.put(:error_ppd, [])
    else
      ppd_changeset = Enum.map(ppd_changeset, fn({_, changeset}) -> changeset end)
      changeset |> Map.put(:error_ppd, Enum.map(ppd_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
          |> UtilityContext.check_errors(:percent_days, changeset.error_percent_day)
        else
          changeset
          |> UtilityContext.transform_error_message()
          |> UtilityContext.check_errors(:percent_days, changeset.error_percent_day)
        end
      end))
    end
  end

  defp validate_percent_days(changeset, nil), do: changeset
  defp validate_percent_days(changeset, []), do: changeset
  defp validate_percent_days(changeset, percent_days) do
    percent_day_changeset = for percent_day <- percent_days do
      changeset_percent_day =
        :create
        |> FacilityPercentDay.changeset(%FacilityPercentDay{}, percent_day)

      {changeset_percent_day.valid?, changeset_percent_day}
    end

    if Enum.all?(percent_day_changeset, fn({valid, _}) -> valid end) do
      percent_day_changeset = Enum.map(percent_day_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:percent_day, percent_day_changeset)
        |> Map.put(:error_percent_day, [])
    else
      percent_day_changeset = Enum.map(percent_day_changeset, fn({_, changeset}) -> changeset end)
        changeset
        |> Changeset.put_change(:percent_days, percent_day_changeset)
        |> Map.put(:error_percent_day, Enum.map(percent_day_changeset, fn(changeset) ->
        if Enum.empty?(changeset.errors) do
          %{}
        else
          UtilityContext.transform_error_message(changeset)
        end
      end))
    end
  end

  def create_facility({:error, changeset}, :create), do: {:error, changeset}
  def create_facility({_, changeset}, :create) do
    params = changeset.changes
    changeset = Map.put(changeset, :changes, Map.drop(params, [:photo, :authorization_form]))

    {:ok, facility} =
      changeset
      |> generate_facility_code()
      |> Repo.insert()

    upload = get_urls(changeset, facility, params)

    {:ok, facility} =
      facility
      |> Facility.changeset_upload(upload)
      |> Repo.update()

    UtilityContext.delete_upload_folder()

    for params <- params.addresses do
      params
        |> Map.put(:changes, params.changes |> Map.put(:facility_code, facility.code))
        |> Repo.insert()
    end

    for params <- params.contacts do
      params
        |> Map.put(:changes, params.changes |> Map.put(:facility_code, facility.code))
      |> Repo.insert()
    end

    for params <- params.service_fee do
      params
        |> Map.put(:changes, params.changes |> Map.put(:facility_code, facility.code))
      |> Repo.insert()
    end

    for params <- params.ppds do
      {:ok, ppd} =
        params
        |> Map.put(:changes, params.changes |> Map.put(:facility_code, facility.code))
        |> Repo.insert()
      for params <- params.changes.percent_day do
        params
        |> Map.put(:changes, params.changes |> Map.put(:facility_ppd_id, ppd.id))
        |> Repo.insert()
      end
    end

    {:ok, facility |> Repo.preload([:facility_addresses, :facility_contacts, :facility_service_fees, facility_ppds: :facility_percent_days])}
  end

  defp get_urls(changeset, facility, params) do
    photo =
      changeset
      |> UtilityContext.convert_file(params.photo, facility.code, :photo, "facility_photo")
      |> UtilityContext.upload_to_s31()

    authorization_form =
      changeset
      |> UtilityContext.convert_file(params.authorization_form, facility.code, :authorization_form, "facility_authorization_form")
      |> UtilityContext.upload_to_s31()

    upload = %{}
    upload = if is_map(photo) && Map.has_key?(photo, :url) do
      upload |> Map.put(:photo, photo.url)
    else
      upload |> Map.put(:photo, "")
    end

    upload = if is_map(authorization_form) && Map.has_key?(authorization_form, :url) do
      upload |> Map.put(:authorization_form, authorization_form.url)
    else
      upload |> Map.put(:authorization_form, "")
    end
  end

  defp generate_facility_code({:error, changeset}), do: {:error, changeset}
  defp generate_facility_code(changeset) do
    random = String.upcase(generate_random_facility_code())
    Facility
    |> where([f], f.code == ^random)
    |> Repo.all()
    |> generate_random(changeset, random)
  end

  defp generate_random([], changeset, random) do
    changeset
    |> Map.put(:changes, changeset.changes
    |> Map.merge(%{code: random, inserted_by: "Masteradmin", updated_by: "Masteradmin"}))
  end
  defp generate_random(_facility, changeset, _random), do: generate_facility_code(changeset)

  defp generate_random_facility_code do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"
    random = UtilityContext.do_randomizer(8, String.split("#{alphabets}#{numbers}", "", trim: true))

    validate_alphabets(String.contains?(random, String.split(alphabets, "", trim: true)), numbers, random)
  end

  defp validate_alphabets(true, numbers, random), do: validate_numbers(String.contains?(random, String.split(numbers, "", trim: true)), random)
  defp validate_alphabets(false, _numbers, _random), do: generate_random_facility_code()

  defp validate_numbers(true, random), do: random
  defp validate_numbers(false, _random), do: generate_random_facility_code()

  def validate_dropdown(changeset, nil, _, _), do: changeset
  def validate_dropdown(changeset, "", _, _), do: changeset
  def validate_dropdown(changeset, code, type, key) do
    validate_data_dropdown(
      changeset,
      key,
      GenericLookUp
      |> where([glp], glp.code == ^code and glp.type == ^type)
      |> Repo.one()
    )
  end

  def validate_address_dropdown(changeset, _, nil, _), do: changeset
  def validate_address_dropdown(changeset, _, "", _), do: changeset
  def validate_address_dropdown(changeset, params, _, key) do
    city = if is_nil(params["city"]), do: "", else: params["city"]
    region = if is_nil(params["region"]), do: "", else: params["region"]
    province = if is_nil(params["province"]), do: "", else: params["province"]
    validate_data_dropdown(
      changeset,
      key,
      AddressLookUp
      |> where([alu], like(alu.city_municipal, ^city))
      |> where([alu], like(alu.region, ^region))
      |> where([alu], like(alu.province, ^province))
      |> Repo.all()
    )
  end

  def validate_coverage_dropdown(changeset, nil, _), do: changeset
  def validate_coverage_dropdown(changeset, "", _), do: changeset
  def validate_coverage_dropdown(changeset, code, key) do
    validate_data_dropdown(
      changeset,
      key,
      Coverage
      |> where([c], c.code == ^code)
      |> Repo.one()
    )
  end

  defp validate_data_dropdown(changeset, key, nil) do
    changeset
    |> Changeset.add_error(key, "is invalid")
  end
  defp validate_data_dropdown(changeset, _, _), do: changeset
end
