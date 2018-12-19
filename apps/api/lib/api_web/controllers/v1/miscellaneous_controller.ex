defmodule ApiWeb.V1.MiscellaneousController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.MiscellaneousContext,
    Contexts.UtilityContext,
    Contexts.ValidationContext
  }

  alias ApiWeb.{
    ErrorView
  }

  alias ApiWeb.Views.{
    MiscellaneousView
  }

  def create_miscellaneous_draft(conn, params) do
      :create_draft
      |> MiscellaneousContext.validate_params(params)
      |> ValidationContext.valid_changeset()
      |> MiscellaneousContext.insert_miscellaneous()
      |> return_result("miscellaneous.json", conn)
  end

  def create_miscellaneous(conn, params) do
      :create
      |> MiscellaneousContext.validate_params(params)
      |> ValidationContext.valid_changeset()
      |> MiscellaneousContext.insert_miscellaneous()
      |> return_result("miscellaneous.json", conn)
  end

  def get_miscellany(conn, params) do
     :search
     |> MiscellaneousContext.validate_params(params)
     |> ValidationContext.valid_changeset()
     |> MiscellaneousContext.get_miscellaneous()
     |> return_result("miscellany.json", conn)
  end

  def get_miscellaneous_versions(conn, params) do
    :version
    |> MiscellaneousContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> MiscellaneousContext.get_miscellaneous_versions()
    |> return_result("version.json", conn)
  end

  def get_miscellaneous_version_details(conn, params) do
    :version_details
    |> MiscellaneousContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> MiscellaneousContext.get_miscellaneous_version_details()
    |> return_result("version_details.json", conn)
  end

  def get_miscellaneous(conn, params) do
     :view
     |> MiscellaneousContext.validate_params(params)
     |> ValidationContext.valid_changeset()
     |> MiscellaneousContext.get_miscellaneous(:view)
     |> return_result("miscellaneous.json", conn)
  end

  def download_miscellany(conn, params) do
    :download
    |> MiscellaneousContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> MiscellaneousContext.get_miscellany(:download)
    |> UtilityContext.generate_csv([
      "Item Code",
      "Item Description",
      "Maximum Price",
      "Last Updated",
      "Updated By"
    ], "Miscellany")
    |> UtilityContext.upload_to_s3(conn)
    |> return_result("download_miscellany.json", conn)
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
    |> put_view(MiscellaneousView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  defp return_result([], json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(MiscellaneousView)
    |> render(json_name, result: [])
  end

  defp return_result(nil, json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(MiscellaneousView)
    |> render(json_name, result: nil)
  end

  defp return_result({:not_found}, json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(MiscellaneousView)
    |> render(json_name, result: {:not_found})
  end

  defp return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(MiscellaneousView)
    |> render(json_name, result: result)
  end
end
