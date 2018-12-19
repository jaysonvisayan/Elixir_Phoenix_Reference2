defmodule ApiWeb.PackageView do
  use ApiWeb, :view

  def render("package.json", %{result: result}) do
    %{
      code: result.code,
      name: result.name,
      version: result.version,
      status: display_status(result.status),
      inserted_by: result.inserted_by,
      inserted_at: result.inserted_at,
      procedure_total_count: result.procedure |> Enum.count(),
      procedure: result.procedure
    }
  end

  def render("view_package.json", %{result: result}) do
    render_many(
      result, ApiWeb.PackageView, "package_procedures.json", as: :package_procedure
    )
  end

  def render("package_procedures.json", %{package_procedure: result}) do
    %{
      code: result.code,
      name: result.name,
      procedure_total_count: result.procedure |> Enum.count(),
      procedure: result.procedure,
      status: display_status(result.status),
      updated_at: result.updated_at,
      updated_by: result.updated_by
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("packages.json", %{result: []}) do
    %{
      error: %{search: "No packages matched your search"}
    }
  end

  def render("packages.json", %{result: result}) do
    %{
      total_number: length(result),
      packages: result
    }
  end

  def display_status(status) do
    case status do
      "A" -> "Active"
      "DR" -> "Draft"
      "DE" -> "Deleted"
      _ -> "Active"
    end
  end
end
