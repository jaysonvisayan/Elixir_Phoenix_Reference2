defmodule ApiWeb.ProcedureView do
  use ApiWeb, :view

  def render("procedures.json", %{procedures: procedures}) do
    %{
      procedures: procedures
    }
  end

  def render("download_procedures.json", %{procedures: result}) do
    %{
      url: result.url
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("procedures.json", %{result: []}) do
    %{
      error: %{"search": "No procedures macthed your search"}
    }
  end
end
