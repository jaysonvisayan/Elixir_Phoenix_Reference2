defmodule ApiWeb.PractitionerView do
  use ApiWeb, :view

  alias Data.{
    Schemas.Practitioner
  }

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("search_practitioners.json", %{result: practitioners}) do
    %{
      total_number: Enum.count(practitioners),
      practitioners: practitioners
    }
  end

  def render("get_practitioner.json", %{result: practitioners}) do
    %{
      step: practitioners.step,
      status: practitioners.status,
      version: practitioners.version,
      code: practitioners.code,
      photo: practitioners.photo,
      first_name: practitioners.first_name,
      middle_name: practitioners.middle_name,
      last_name: practitioners.last_name,
      suffix: practitioners.suffix,
      is_active: practitioners.is_active,
      is_suspected: practitioners.is_suspected,
      birth_date: practitioners.birth_date,
      gender: practitioners.gender,
      specialization: practitioners.specialization,
      sub_specialization: practitioners.sub_specialization,
      prc_no: practitioners.prc_no,
      phic_accredited: practitioners.phic_accredited,
      phic_accreditation_from: practitioners.phic_accreditation_from,
      phic_accreditation_to: practitioners.phic_accreditation_to,
      phones: render_many(
        practitioners.phones,
        ApiWeb.PractitionerView,
        "practitioner.json",
        as: :practitioner
      ),
      email: practitioners.email,
      email2: practitioners.email2,
      exclusive: practitioners.exclusive,
      vat_status: practitioners.vat_status,
      prescription_inpatient: practitioners.prescription_inpatient,
      prescription_outpatient: practitioners.prescription_outpatient,
      tin: practitioners.tin,
      withholding_tax: practitioners.withholding_tax,
      mode_of_payment: practitioners.mode_of_payment,
      bank_name: practitioners.bank_name,
      bank_account_no: practitioners.bank_account_no,
      xp_card_no: practitioners.xp_card_no,
      payee_name: practitioners.payee_name,
      mode_of_releasing: practitioners.mode_of_releasing
      }
  end

  def render("practitioner.json", %{practitioner: practitioner}) do
    %{
      type: practitioner.type,
      country_code: practitioner.country_code,
      area_code: practitioner.area_code,
      number: practitioner.number,
      local: practitioner.local
    }
  end

end
