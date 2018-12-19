defmodule ApiWeb.V1.DiagnosisController do
  use ApiWeb, :controller

  alias Data.Contexts.DiagnosisContext, as: DC
  alias Data.Contexts.ValidationContext, as: VC
  alias Data.Contexts.UtilityContext, as: UC
  alias ApiWeb.{
    DiagnosisView,
    ErrorView
  }

  def download_diagnoses(conn, params) when is_map(params) do
    :download
    |> DC.validate_params(params)
    |> VC.valid_changeset()
    |> DC.get_diagnoses()
    |> UC.generate_csv([
      "Diagnosis Group Code",
      "Diagnosis Code",
      "Diagnosis Group Code Name",
      "Standard",
      "Dreaded",
      "Congenital"
    ], "Diagnosis")
    |> UC.upload_to_s3(conn)
    |> return_result("download_diagnoses.json", conn)
  end

  def download_diagnoses(conn, _params), do: return_result({:error_message, "Invalid arguments"}, "error.json", conn)

  def get_diagnoses(conn, params) when is_map(params) do
      :search
      |> DC.validate_params(params)
      |> VC.valid_changeset()
      |> DC.get_diagnoses()
      |> return_result("diagnoses.json", conn)
  end

  def get_diagnoses(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  def return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(DiagnosisView)
    |> render("error.json", error: UC.transform_error_message(changeset))
  end

  def return_result([], json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(DiagnosisView)
    |> render(json_name, result: [])
  end

  def return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(DiagnosisView)
    |> render(json_name, diagnoses: result)
  end

end
