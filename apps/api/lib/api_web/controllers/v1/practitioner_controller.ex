defmodule ApiWeb.V1.PractitionerController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.PractitionerContext,
    Contexts.UtilityContext,
    Contexts.ValidationContext
  }

  alias ApiWeb.{
    ErrorView,
    PractitionerView
  }

  def get_practitioners(conn, params) when is_map(params) do
    :search
    |> PractitionerContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> PractitionerContext.get_practitioners(:search)
    |> return_result("search_practitioners.json", conn)
  end

  def get_practitioner(conn, params) do
    :view
    |> PractitionerContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> PractitionerContext.get_practitioner(params["tab"])
    |> return_result("get_practitioner.json", conn)
  end

  def return_result({:error_message, message}, _, conn) do
    conn
    |> put_status(412)
    |> put_view(ErrorView)
    |> render("error.json", message: message)
  end

  def return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(PractitionerView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  def return_result([], _, conn) do
    conn
    |> put_status(400)
    |> put_view(PractitionerView)
    |> render("error.json", error: "No practitioner matched your search")
  end

  def return_result({:ok, result}, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(PractitionerView)
    |> render(json_name, result: result)
  end

  def return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(PractitionerView)
    |> render(json_name, result: result)
  end
end
