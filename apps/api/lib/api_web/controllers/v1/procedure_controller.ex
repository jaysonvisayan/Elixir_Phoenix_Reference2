defmodule ApiWeb.V1.ProcedureController do
  use ApiWeb, :controller
  @moduledoc false

  alias Data.{
    Contexts.ProcedureContext,
    Contexts.ValidationContext,
    Contexts.UtilityContext,
  }
  alias ApiWeb.{
    ProcedureView,
    ErrorView
  }

  def get_procedures(conn, params) do
      :search
      |> ProcedureContext.validate_params(params)
      |> ValidationContext.valid_changeset()
      |> ProcedureContext.get_procedures(:search)
      |> return_result("procedures.json", conn)
  end

  def download_procedures(conn, params) do
    :download
    |> ProcedureContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> ProcedureContext.get_procedures(:download)
    |> UtilityContext.generate_csv([
      "Procedure Code",
      "Procedure Description",
      "CPT/CDT",
      "Standard",
      "Type"
    ], "Procedure")
    |> UtilityContext.upload_to_s3(conn)
    |> return_result("download_procedures.json", conn)
  end

  defp return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  defp return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(ProcedureView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  defp return_result([], json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(ProcedureView)
    |> render(json_name, result: [])
  end

  defp return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(ProcedureView)
    |> render(json_name, procedures: result)
  end

end
