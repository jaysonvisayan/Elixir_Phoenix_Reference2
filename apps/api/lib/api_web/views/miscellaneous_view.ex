defmodule ApiWeb.Views.MiscellaneousView do

  use ApiWeb, :view

  def render("version.json", %{result: nil}) do
    %{
      errors: %{"code": "Code not existing"}
    }
  end

  def render("version.json", %{result: result}) do
    render_many(
      result.miscellaneous_archives,
      ApiWeb.Views.MiscellaneousView,
      "miscellaneous_archives.json",
      as: :miscellaneous
    )
    ++
    [
      %{
        version: result.version,
        updated_by: result.updated_by,
        updated_at: result.updated_at,
        change_logs: "current"
      }
    ]
  end

  def render("miscellaneous_archives.json", %{miscellaneous: miscellaneous}) do
    %{
      version: miscellaneous.version,
      updated_by: miscellaneous.updated_by,
      updated_at: miscellaneous.updated_at,
      change_logs: miscellaneous.change_logs
    }
  end

  def render("version_details.json", %{result: {:not_found}}) do
    %{
      errors: %{"code": "Code not existing"}
    }
  end

  def render("version_details.json", %{result: nil}) do
    %{
      errors: %{"version": "Version not existing"}
    }
  end

  def render("version_details.json", %{result: []}) do
    %{
      errors: %{"version": "Version not existing"}
    }
  end

  def render("version_details.json", %{result: miscellany}) do
    %{
      miscellany: miscellany
    }
  end

  def render("miscellany.json", %{result: []}) do
    %{
      errors: %{"search": "No item matched your search"}
    }
  end

  def render("miscellany.json", %{result: miscellany}) do
    %{
      miscellany: miscellany
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("download_miscellany.json", %{result: result}) do
    %{
      url: result.url
    }
  end

  def render("miscellaneous.json", %{result: miscellany}) do
    %{
      item_code: miscellany.code,
      desc: miscellany.description,
      maximum_price: miscellany.max_price,
      status: miscellany.status,
      version: miscellany.version,
      inserted_by: miscellany.inserted_by,
      inserted_at: miscellany.inserted_at,
      updated_by: miscellany.updated_by,
      updated_at: miscellany.updated_at
    }
  end
end
