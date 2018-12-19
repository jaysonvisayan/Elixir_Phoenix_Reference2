defmodule ApiWeb.V1.PackageController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.PackageContext,
    Contexts.UtilityContext,
    Contexts.ValidationContext
  }

  alias ApiWeb.{
    PackageView,
    ErrorView
  }

  def create_package(conn, params) when is_map(params) do
    map = %{
      "inserted_by" => "masteradmin",
      "updated_by" => "masteradmin",
      "version" => "1",
      "status" => "A"
    }

    params =
      params
      |> Map.merge(map)

    :create
    |> PackageContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> PackageContext.insert_package(:create)
    |> return_result("package.json", conn)
  end
  def create_package(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def get_package(conn, params) when is_map(params) do
    :view
    |> PackageContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> PackageContext.get_package_procedures()
    |> return_result("view_package.json", conn)
  end
  def get_package(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def get_packages(conn, params) when is_map(params) do
    :search
    |> PackageContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> PackageContext.get_packages()
    |> return_result("packages.json", conn)
  end
  def get_packages(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def get_package_procedures(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)
  def get_package_procedures({:error, changeset}), do: {:error, changeset}
  def get_package_procedures(params), do: params

  defp return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  defp return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(PackageView)
    |> render("error.json", error: UtilityContext.transform_error_message_package(changeset))
  end

  defp return_result([], json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(PackageView)
    |> render(json_name, result: [])
  end

  defp return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(PackageView)
    |> render(json_name, result: result)
  end
end

