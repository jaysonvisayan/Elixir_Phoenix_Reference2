defmodule Data.Contexts.PractitionerContext do
  @moduledoc false
  alias Ecto.Changeset
  import Ecto.Query

  alias Data.{
    Repo,
    Schemas.Practitioner,
    Schemas.PractitionerPhone,
    Schemas.PractitionerCorporate,
    Schemas.PractitionerCorporateSchedule,
    Schemas.PractitionerPrimary,
    Schemas.PractitionerPrimaryRoom,
    Schemas.PractitionerPrimarySpecialization,
    Schemas.PractitionerPrimarySchedule
  }

  def get_practitioners({:error, changeset}, _), do: {:error, changeset}
  def get_practitioners({nil, _}, :search), do: nil
  def get_practitioners(params, :search) do
    search_value = if Map.has_key?(params, :search_value), do: params.search_value, else: ""
    offset = (params.page_number * params.display_per_page) - params.display_per_page

    Practitioner
    |> where([p],
             ilike(p.code, ^"%#{search_value}%") or
             ilike(p.first_name, ^"%#{search_value}%") or
             ilike(p.middle_name, ^"%#{search_value}%") or
             ilike(p.last_name, ^"%#{search_value}%") or
             ilike(p.specialization, ^"%#{search_value}%") or
             ilike(fragment("CAST(? AS TEXT)", p.sub_specialization), ^"%#{search_value}%") or
             ilike(p.status, ^"%#{search_value}%")
    )
    |> select([p], %{
      code: p.code,
      name: fragment("concat(?,' ',?,' ',?)", p.first_name, p.middle_name, p.last_name),
      specialization: p.specialization,
      sub_specialization: p.sub_specialization,
      status: p.status
    })
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
  defp order_datatable(query, "code", "asc"), do: query |> order_by([p], asc: p.code)
  defp order_datatable(query, "first_name", "asc"), do: query |> order_by([p], asc: p.first_name)
  defp order_datatable(query, "middle_name", "asc"), do: query |> order_by([p], asc: p.middle_name)
  defp order_datatable(query, "last_name", "asc"), do: query |> order_by([p], asc: p.last_name)
  defp order_datatable(query, "specialization", "asc"), do: query |> order_by([p], asc: p.specialization)
  defp order_datatable(query, "sub_specialization", "asc"), do: query |> order_by([p], asc: p.sub_specialization)
  defp order_datatable(query, "status", "asc"), do: query |> order_by([p], asc: p.status)

  # Descending
  defp order_datatable(query, "code", "desc"), do: query |> order_by([p], desc: p.code)
  defp order_datatable(query, "first_name", "desc"), do: query |> order_by([p], desc: p.first_name)
  defp order_datatable(query, "middle_name", "desc"), do: query |> order_by([p], desc: p.middle_name)
  defp order_datatable(query, "last_name", "desc"), do: query |> order_by([p], desc: p.last_name)
  defp order_datatable(query, "specialization", "desc"), do: query |> order_by([p], desc: p.specialization)
  defp order_datatable(query, "sub_specialization", "desc"), do: query |> order_by([p], desc: p.sub_specialization)
  defp order_datatable(query, "status", "desc"), do: query |> order_by([p], desc: p.status)

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
    |> Changeset.validate_number(:page_number, greater_than: 0)
    |> Changeset.validate_number(:display_per_page, greater_than: 0)
    |> Changeset.validate_inclusion(:sort_by, [
      "code",
      "CODE",
      "first_name",
      "FIRST_NAME",
      "middle_name",
      "MIDDLE_NAME",
      "last_name",
      "LAST_NAME",
      "specialization",
      "SPECIALIZATION",
      "sub_specialization",
      "SUB_SPECIALIZATION",
      "status",
      "STATUS"
    ], message: "invalid parameters")
    |> Changeset.validate_inclusion(:order_by, [
    "asc",
    "desc",
    "ASC",
    "DESC"
    ], message: "invalid parameters")
    |> validate_key_search(params["search_value"])
    |> is_valid_changeset?()
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}
  defp validate_key_search(changeset, ""), do: changeset |> Changeset.put_change(:search_value, "")
  defp validate_key_search(changeset, nil), do: changeset |> Changeset.add_error(:search_value, "is not in the parameters")
  defp validate_key_search(changeset, _params), do: changeset |> validate_search_value(changeset.changes)

  defp validate_search_value(changeset, changes) when map_size(changes) == 0 do
    changeset
    |> Changeset.add_error(:search_value, "is not in the parameters")
  end

  defp validate_search_value(changeset, _changes), do: changeset

  def validate_params(:view, params) do
    fields = %{
      code: :string,
      tab: :string
    }

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.validate_required([:code, :tab], message: "is required")
    |> check_tab(params["tab"], params)
    |> is_valid_changeset?()
  end

  defp check_tab(changeset, tab, _params) when is_nil(tab), do: changeset
  defp check_tab(changeset, tab, _params) when tab == "", do: changeset
  defp check_tab(changeset, _tab, _params) do
    changeset.changes.tab
    |> check_valid_tab(changeset)
    |> is_tab_valid?()
  end

  defp check_valid_tab("Profile", changeset, _params), do: {true, changeset}
  defp check_valid_tab("Affiliation", changeset, params) do
    fields = %{corporate_retainer: :map}

    {%{}, fields}
    |> Changeset.cast(params, Map.keys(fields))
    |> Changeset.merge(changeset)
    |> check_corporate_retainer_params(params)
  end

  defp check_valid_tab(_, changeset), do: {:error, changeset}

  defp is_tab_valid?({true, changeset}), do: changeset
  defp is_tab_valid?({:error, changeset}), do: Changeset.add_error(changeset, :tab, "is an invalid tab")

  defp check_corporate_retainer_params(changeset, params) do
    fields = %{
      search_value: :string,
      page_number: :integer,
      display_per_page: :integer
    }
    corporate_retainer_keys =
      {%{}, fields}
      |> Changeset.cast(params["pec"], Map.keys(fields))
      |> Changeset.validate_required([
        :page_number,
        :display_per_page,
      ], message: "is required")

    changeset =
      changeset
      |> Changeset.put_change(:corporate_retainer, corporate_retainer_keys)
  end

  def get_practitioner({:error, changeset}, _tab), do: {:error, changeset}
  def get_practitioner(params, "Profile") do
    Practitioner
    |> where([p], fragment("LOWER(?)", p.code) == fragment("LOWER(?)", ^params.code))
    |> select([p], %{
      step: p.step,
      status: p.status,
      version: p.version,
      code: p.code,
      photo: p.photo,
      first_name: p.first_name,
      middle_name: p.middle_name,
      last_name: p.last_name,
      suffix: p.suffix,
      is_active: p.is_active,
      is_suspected: p.is_suspected,
      birth_date: p.birth_date,
      gender: p.gender,
      specialization: p.specialization,
      sub_specialization: p.sub_specialization,
      prc_no: p.prc_no,
      phic_accredited: p.phic_accredited,
      phic_accreditation_from: p.phic_accreditation_from,
      phic_accreditation_to: p.phic_accreditation_to,
      email: p.email,
      email2: p.email2,
      exclusive: p.exclusive,
      vat_status: p.vat_status,
      prescription_inpatient: p.prescription_inpatient,
      prescription_outpatient: p.prescription_outpatient,
      tin: p.tin,
      withholding_tax: p.tin,
      mode_of_payment: p.mode_of_payment,
      bank_name: p.bank_name,
      bank_account_no: p.bank_account_no,
      xp_card_no: p.xp_card_no,
      payee_name: p.payee_name,
      mode_of_releasing: p.mode_of_releasing
      })
      |> Repo.all()
      |> get_practitioner_profile(:Profile)
  end

  defp get_practitioner_profile([practitioner], :Profile) do
    {
      :ok,
      practitioner
      |> load_phones()
    }
  end

  defp load_phones(practitioner) do
    phones =
      PractitionerPhone
      |> where([pp], pp.practitioner_code == ^practitioner.code)
      |> Repo.all()

    Map.put(practitioner, :phones, phones)
  end

  def get_practitioner(params, "Affiliation") do
    Practitioner
    |> where([p], fragment("LOWER(?)", p.code) == fragment("LOWER(?)", ^params.code))
    |> select([p], %{
      step: p.step,
      status: p.status,
      version: p.version,
      code: p.code,
      photo: p.photo,
      first_name: p.first_name,
      middle_name: p.middle_name,
      last_name: p.last_name,
      suffix: p.suffix,
      is_active: p.is_active,
      is_suspected: p.is_suspected,
      birth_date: p.birth_date,
      gender: p.gender,
      specialization: p.specialization,
      sub_specialization: p.sub_specialization,
      prc_no: p.prc_no,
      phic_accredited: p.phic_accredited,
      phic_accreditation_from: p.phic_accreditation_from,
      phic_accreditation_to: p.phic_accreditation_to,
      email: p.email,
      email2: p.email2,
      exclusive: p.exclusive,
      vat_status: p.vat_status,
      prescription_inpatient: p.prescription_inpatient,
      prescription_outpatient: p.prescription_outpatient,
      tin: p.tin,
      withholding_tax: p.tin,
      mode_of_payment: p.mode_of_payment,
      bank_name: p.bank_name,
      bank_account_no: p.bank_account_no,
      xp_card_no: p.xp_card_no,
      payee_name: p.payee_name,
      mode_of_releasing: p.mode_of_releasing
      })
      |> Repo.all()
      |> get_practitioner_affiliation(:Affiliation)
  end

  defp get_practitioner_affiliation([practitioner], :Affiliation) do
    {
      :ok,
      practitioner
      |> load_phones()
    }
  end

  defp is_valid_changeset?(changeset), do: {changeset.valid?, changeset}

  ###Seed data###

  ###Practitioner
  def insert_practitioner_seed(params) do
    params
    |> get_by(:practitioner)
    |> create_update_practitioner(params)
  end

  defp create_update_practitioner(nil, params) do
    %Practitioner{}
    |> Practitioner.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner(practitioner, params) do
    practitioner
    |> Practitioner.changeset(params)
    |> Repo.update()
  end

  ###Practitioner_corporate
  def insert_practitioner_corporate_seed(params) do
    params
    |> get_by(:practitioner_corporate)
    |> create_update_practitioner_corporate_seed(params)
  end

  defp create_update_practitioner_corporate_seed(nil, params) do
    %PractitionerCorporate{}
    |> PractitionerCorporate.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_corporate_seed(practitioner, params) do
    practitioner
    |> PractitionerCorporate.changeset(params)
    |> Repo.update()
  end

  ###Practitioner_corporate_schedule
  def insert_practitioner_corporate_schedule_seed(params) do
    params
    |> get_by(:practitioner_corporate_schedule)
    |> create_update_practitioner_corporate_schedule_seed(params)
  end

  defp create_update_practitioner_corporate_schedule_seed(nil, params) do
    %PractitionerCorporateSchedule{}
    |> PractitionerCorporateSchedule.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_corporate_schedule_seed(practitioner, params) do
    practitioner
    |> PractitionerCorporateSchedule.changeset(params)
    |> Repo.update()
  end

  ###PractitionerPrimary
  def insert_practitioner_primary_seed(params) do
    params
    |> get_by(:practitioner_primary)
    |> create_update_practitioner_primary(params)
  end

  defp create_update_practitioner_primary(nil, params) do
    %PractitionerPrimary{}
    |> PractitionerPrimary.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_primary(practitioner, params) do
    practitioner
    |> PractitionerPrimary.changeset(params)
    |> Repo.update()
  end

  ###PractitionerPrimaryRoom
  def insert_practitioner_primary_room_seed(params) do
    params
    |> get_by(:practitioner_primary_room)
    |> create_update_practitioner_primary_room(params)
  end

  defp create_update_practitioner_primary_room(nil, params) do
    %PractitionerPrimaryRoom{}
    |> PractitionerPrimaryRoom.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_primary_room(practitioner, params) do
    practitioner
    |> PractitionerPrimaryRoom.changeset(params)
    |> Repo.update()
  end

    ###PractitionerPrimarySpecialization
  def insert_practitioner_primary_specialization_seed(params) do
    params
    |> get_by(:practitioner_primary_specializations)
    |> create_update_practitioner_primary_specialization(params)
  end

  defp create_update_practitioner_primary_specialization(nil, params) do
    %PractitionerPrimarySpecialization{}
    |> PractitionerPrimarySpecialization.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_primary_specialization(practitioner, params) do
    practitioner
    |> PractitionerPrimarySpecialization.changeset(params)
    |> Repo.update()
  end

    ###PractitionerPrimarySchedule
  def insert_practitioner_primary_schedule_seed(params) do
    params
    |> get_by(:practitioner_primary_schedules)
    |> create_update_practitioner_primary_schedule(params)
  end

  defp create_update_practitioner_primary_schedule(nil, params) do
    %PractitionerPrimarySchedule{}
    |> PractitionerPrimarySchedule.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_primary_schedule(practitioner, params) do
    practitioner
    |> PractitionerPrimarySchedule.changeset(params)
    |> Repo.update()
  end

    ###PractitionerPhone
  def insert_practitioner_phone_seed(params) do
    params
    |> get_by(:practitioner_phones)
    |> create_update_practitioner_phone(params)
  end

  defp create_update_practitioner_phone(nil, params) do
    %PractitionerPhone{}
    |> PractitionerPhone.changeset(params)
    |> Repo.insert()
  end

  defp create_update_practitioner_phone(practitioner, params) do
    practitioner
    |> PractitionerPhone.changeset(params)
    |> Repo.update()
  end

  defp get_by(params, :practitioner) do
    Practitioner
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_primary) do
    PractitionerPrimary
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_phones) do
    PractitionerPhone
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_corporate) do
    PractitionerCorporate
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_corporate_schedule) do
    PractitionerCorporateSchedule
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_primary_room) do
    PractitionerPrimaryRoom
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_primary_specializations) do
    PractitionerPrimarySpecialization
    |> Repo.get_by(params)
  end

  defp get_by(params, :practitioner_primary_schedules) do
    PractitionerPrimarySchedule
    |> Repo.get_by(params)
  end

end
