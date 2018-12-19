defmodule ApiWeb.V1.FacilityController do
  use ApiWeb, :controller

  alias Data.Contexts.{
    FacilityContext,
    ValidationContext,
    UtilityContext
  }
  alias ApiWeb.FacilityView

  alias ApiWeb.{
    ErrorView,
    FacilityView
  }

  def get_facilities(conn, params) do
    :search
    |> FacilityContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> FacilityContext.get_facilities(:search)
    |> return_result("facilities.json", conn, :search)
  end
  def get_facilities(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn, :search)

  def request_facility(conn, params) when is_map(params) do
    :create
    |> FacilityContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> FacilityContext.create_facility(:create)
    |> return_result("create_facility.json", conn, :create)
  end

  def request_facility(conn, _), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn, :create)

  def return_result({:error, changeset}, _, conn, :create) do
    if changeset.valid? do
      error =
        %{}
        |> UtilityContext.check_errors(:addresses, changeset.error_addresses)
        |> UtilityContext.check_errors(:contacts, changeset.error_contacts)
        |> UtilityContext.check_errors(:service_fee, changeset.error_service_fee)
        |> UtilityContext.check_errors(:ppd, changeset.error_ppd)

      conn
      |> put_status(400)
      |> put_view(FacilityView)
      |> render("error.json", error: error)
    else
      error =
        changeset
        |> UtilityContext.transform_error_message()
        |> UtilityContext.check_errors(:addresses, changeset.error_addresses)
        |> UtilityContext.check_errors(:contacts, changeset.error_contacts)
        |> UtilityContext.check_errors(:service_fee, changeset.error_service_fee)
        |> UtilityContext.check_errors(:ppd, changeset.error_ppd)
      conn
      |> put_status(400)
      |> put_view(FacilityView)
      |> render("error.json", error: error)
    end
  end

  def return_result({:ok, result}, json_name, conn, :create) do
    conn
    |> put_status(200)
    |> put_view(FacilityView)
    |> render(json_name, result: result)
  end

  def return_result({:error_message, message}, _, conn, _) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  def return_result({:error, changeset}, _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(FacilityView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  def return_result([], _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(FacilityView)
    |> render("error.json", error: "No facility matched your search")
  end

  def return_result(nil, _, conn, _) do
    conn
    |> put_status(400)
    |> put_view(FacilityView)
    |> render("error.json", error: "Facility not found!")
  end

  def return_result(result, json_name, conn, _) do
    conn
    |> put_status(200)
    |> put_view(FacilityView)
    |> render(json_name, facilities: result)
  end
end
