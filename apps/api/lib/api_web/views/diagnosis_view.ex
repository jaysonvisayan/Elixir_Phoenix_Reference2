defmodule ApiWeb.DiagnosisView do
  use ApiWeb, :view

  def render("download_diagnoses.json", %{diagnoses: result}) do
    %{
      url: result.url
    }
  end

  def render("diagnoses.json", %{diagnoses: diagnoses}) do
    %{
      diagnoses: diagnoses
    }
  end


  def render("diagnoses.json", %{result: []}) do
    %{
      error: %{"search": "No diagnoses macthed your search"}
    }
  end


  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

end
