defmodule ApiWeb.V1.FacilityGroupController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.FacilityGroupContext,
    Contexts.ValidationContext,
    Contexts.UtilityContext
  }
  alias ApiWeb.{
    FacilityGroupView,
    ErrorView
  }

  def get_facility_groups(conn, params) when is_map(params) do
    :search
    |> FacilityGroupContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> FacilityGroupContext.get_facility_groups()
    |> return_result("facility_groups.json", conn)
  end

  def get_facility_groups(conn, _params) when is_nil(_params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def get_facility_group(conn, params) when is_map(params) do
    :view
    |> FacilityGroupContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> FacilityGroupContext.get_facility_group()
    |> return_result("success_insert_facility_group.json", conn)
  end

  def get_facility_group(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  defp return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  defp return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(FacilityGroupView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset, :facility_group))
  end

 defp return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(FacilityGroupView)
    |> render(json_name, facility_groups: result)
  end

  def create_facility_group(conn, params) when is_map(params) do
    :create
    |> FacilityGroupContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> FacilityGroupContext.insert_facility_group()
    |> return_result("success_insert_facility_group.json", conn)
  end

  def create_facility_group(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)
end
