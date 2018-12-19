defmodule ApiWeb.FacilityControllerTest do

  use ApiWeb.ConnCase
  @moduledoc """

  """

  setup do
    params = %{
      photo: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
      name: "Makati Medical Center",
      code: "123ABC",
      type: "A",
      license_name: "Makati Medical Center",
      category: "P",
      affiliation_date: "Jan-13-2010",
      disaffiliation_date: "Jan-13-2010",
      website: "www.mmc.ph",
      cut_off_time: "01:12",
      status: "pending",
      phic_accreditation_from: "Jan-13-2010",
      phic_accreditation_to: "Jan-13-2010",
      phic_accreditation_no: "000000000000",
      billing_same_as_permanent_address: false,
      addresses: [
        %{
          type: "Permanent",
          address_line_1: "Address line 1",
          address_line_2: "Address line 2",
          city: "Makati City",
          province: "Metro Manila",
          region: "NCR",
          country: "Philippines",
          postal_code: "001",
          longitude: "1.000011212",
          latitude: "12221.12121212"
        }
      ],
      contacts: [
        %{
          first_name: "Jose Pedro",
          middle_name: "Villar",
          last_name: "Velasco",
          suffix: "JR",
          department: "Solutions Design Development and Deployment Dept.",
          designation: "Multimedia Designer - Business Analyst",
          email_address: "jose_velasco@yahoo.com",
          email_address2: "jose_velasco@yahoo.com",
          mobile_nos: [
            %{
              country_code: "+63",
              number: "9123456789"
            }
          ],
          tel_nos: [
            %{
              country_code: "+63",
              area_code: "02",
              number: "1234567",
              local: "880"
            }
          ],
          fax_nos: [
            %{
              country_code: "+63",
              area_code: "02",
              number: "1234567",
              local: "880"
            }
          ]
        }
      ],
      tin: "123-456-780-000",
      vat_status: "VAT status",
      prescription_term: "10",
      prescription_clause_percentage: 50,
      prescription_clause_days: 30,
      credit_term: "100",
      credit_limit: "100000",
      bank_charge: "12.11",
      withholding_tax: "12.11",
      authorization_form: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
      payment_mode: "Bank",
      bank_name: "Equicom",
      bank_account_no: "0123456789012",
      payee_name: "Makati Medical Center",
      releasing_mode: "ADA",
      no_of_beds: 2,
      bond: 3,
      exclusive: [
        "Exclusive",
        "Umbrella"
      ],
      service_fee: [
        %{
          coverage: "OPC",
          payment_mode: "Individual",
          service_fee: "FF",
          rate: "10"
        }
      ],
      gross_bill: true,
      effective_date: "Jan-21-2012",
      ppd: [
        %{
          coverage: "Outpatient",
          subcoverage: "Medicine",
          discount_mode: "Outright",
          percent_days: [
            %{
              percent: 10,
              days: 2
            }
          ]
        }
      ]
    }

    invalid_params = %{
      photo: "",
      name: "Makati Medical Center",
      code: "123ABC",
      type: "",
      license_name: "Makati Medical Center",
      category: "",
      affiliation_date: "Jan-13-2010",
      disaffiliation_date: "Jan-13-2010",
      website: "www.mmc.ph",
      cut_off_time: "01:12",
      status: "",
      phic_accreditation_from: "Jan-13-2010",
      phic_accreditation_to: "Jan-13-2010",
      phic_accreditation_no: "000000000000",
      billing_same_as_permanent_address: false,
      addresses: [
        %{
          type: "",
          address_line_1: "Address line 1",
          address_line_2: "Address line 2",
          city: "Makati City",
          province: "Metro Manila",
          region: "NCR",
          country: "Philippines",
          postal_code: "001",
          longitude: "1.000011212",
          latitude: "12221.12121212"
        }
      ],
      contacts: [
        %{
          first_name: "",
          middle_name: "Villar",
          last_name: "Velasco",
          suffix: "JR",
          department: "Solutions Design Development and Deployment Dept.",
          designation: "Multimedia Designer - Business Analyst",
          email_address: "jose_velasco@yahoo.com",
          email_address2: "jose_velasco@yahoo.com",
          mobile_nos: [
            %{
              country_code: "+63",
              number: ""
            }
          ],
          tel_nos: [
            %{
              country_code: "+63",
              area_code: "02",
              number: "1234567",
              local: "880"
            }
          ],
          fax_nos: [
            %{
              country_code: "+63",
              area_code: "02",
              number: "1234567",
              local: "880"
            }
          ]
        }
      ],
      tin: "123-456-780-000",
      vat_status: "VAT status",
      prescription_term: "",
      prescription_clause_percentage: 50,
      prescription_clause_days: 30,
      credit_term: "100",
      credit_limit: "",
      bank_charge: "12.11",
      withholding_tax: "12.11",
      authorization_form: "",
      payment_mode: "Bank",
      bank_name: "Equicom",
      bank_account_no: "0123456789012",
      payee_name: "Makati Medical Center",
      releasing_mode: "ADA",
      no_of_beds: 2,
      bond: 3,
      exclusive: [
        "Exclusive",
        "Umbrella"
      ],
      service_fee: [
        %{
          coverage: "OPC",
          payment_mode: "Individual",
          service_fee: "FF",
          rate: "10"
        }
      ],
      gross_bill: true,
      effective_date: "Jan-21-2012",
      ppd: [
        %{
          coverage: "Outpatient",
          subcoverage: "Medicine",
          discount_mode: "Outright",
          percent_days: [
            %{
              percent: 10,
              days: 2
            }
          ]
        }
      ]
    }

    insert(:generic_look_up, %{
      code: "A",
      type: "facility_type",
      name: "Ambulance",
      description: "Ambulance"
    })

    insert(:generic_look_up, %{
      code: "FF",
      type: "facility_service_fee",
      name: "Fixed fee",
      description: "Fixed fee"
    })

    insert(:generic_look_up, %{
      code: "P",
      type: "facility_category",
      name: "Primary",
      description: "Primary"
    })

    insert(:address_look_up, %{
      region: "NCR",
      region_name: "",
      province: "Metro Manila",
      city_municipal: "Makati City"
    })

    insert(:coverage, %{
      code: "OPC",
      name: "OP Consult"
    })

    {:ok, %{
      params: params,
      invalid_params: invalid_params
    }}
  end

  describe "request_facility" do
    test "with valid params", %{params: params} do
      conn = post(build_conn(), "/api/v1/facilities/request_facility", params)
      assert json_response(conn, 200)
    end

    test "with invalid params", %{invalid_params: ip} do
      conn = post(build_conn(), "/api/v1/facilities/request_facility", ip)
      assert json_response(conn, 400)
    end
  end
end
