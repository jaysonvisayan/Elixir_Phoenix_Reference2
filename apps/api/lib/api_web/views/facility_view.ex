defmodule ApiWeb.FacilityView do
  use ApiWeb, :view

  def render("create_facility.json", %{result: struct}) do
    %{
      facility: %{
        code: struct.code,
        name: struct.name,
        photo: struct.photo,
        type: struct.type,
        license_name: struct.license_name,
        category: struct.category,
        affiliation_date: struct.affiliation_date,
        disaffiliation_date: struct.disaffiliation_date,
        website: struct.website,
        cut_off_time: struct.cut_off_time,
        status: struct.status,
        phic_accreditation_from: struct.phic_accreditation_from,
        phic_accreditation_to: struct.phic_accreditation_to,
        phic_accreditation_no: struct.phic_accreditation_no,
        billing_same_as_permanent_address: struct.billing_same_as_permanent_address,
        tin: struct.tin,
        vat_status: struct.vat_status,
        prescription_term: struct.prescription_term,
        prescription_clause_percentage: struct.prescription_clause_percentage,
        prescription_clause_days: struct.prescription_clause_days,
        credit_term: struct.credit_term,
        credit_limit: struct.credit_limit,
        bank_charge: struct.bank_charge,
        withholding_tax: struct.withholding_tax,
        authorization_form: struct.authorization_form,
        payment_mode: struct.payment_mode,
        bank_name: struct.bank_name,
        bank_account_no: struct.bank_account_no,
        payee_name: struct.payee_name,
        releasing_mode: struct.releasing_mode,
        number_of_beds: struct.number_of_beds,
        bond: struct.bond,
        exclusive: struct.exclusive,
        gross_bill: struct.gross_bill,
        effective_date: struct.effective_date,
        addresses: Enum.map(struct.facility_addresses, fn(address) ->
          %{
            type: address.type,
            address_line_1: address.address_line_1,
            address_line_2: address.address_line_2,
            city: address.city,
            province: address.province,
            region: address.region,
            country: address.country,
            postal_code: address.postal_code,
            longitude: address.longitude,
            latitude: address.latitude
          }
        end),
        contacts: Enum.map(struct.facility_contacts, fn(contact) ->
          %{
            first_name: contact.first_name,
            middle_name: contact.middle_name,
            last_name: contact.last_name,
            suffix: contact.suffix,
            department: contact.department,
            designation: contact.designation,
            email_address: contact.email_address,
            email_address_2: contact.email_address_2,
            mobile_nos: contact.mobile_nos,
            tel_nos: contact.tel_nos,
            fax_nos: contact.fax_nos
          }
        end),
        service_fee: Enum.map(struct.facility_service_fees, fn(service_fee) ->
          %{
            coverage: service_fee.coverage,
            payment_mode: service_fee.payment_mode,
            service_fee: service_fee.service_fee,
            rate: service_fee.rate
          }
        end),
        ppd: Enum.map(struct.facility_ppds, fn(ppd) ->
          %{
            coverage: ppd.coverage,
            subcoverage: ppd.subcoverage,
            discount_mode: ppd.discount_mode,
            percent_days: Enum.map(ppd.facility_percent_days, fn(percent_day) ->
              %{
                percent: percent_day.percent,
                days: percent_day.days
              }
            end)
          }
        end)
      }
    }
  end

  def render("facilities.json", %{facilities: facilities}) do
    %{
      facilities: facilities
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end
end
