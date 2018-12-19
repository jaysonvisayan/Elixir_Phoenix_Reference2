defmodule ApiWeb.V1.RuvController do
  use ApiWeb, :controller

  alias Data.{
    Contexts.RuvContext,
    Contexts.UtilityContext,
    Contexts.ValidationContext
  }

  alias ApiWeb.{
    RuvView
  }

  defp return_result({:error, changeset}, _, conn) do
    conn
    |> put_status(400)
    |> put_view(RuvView)
    |> render("error.json", error: UtilityContext.transform_error_message(changeset))
  end

  defp return_result([], json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(RuvView)
    |> render(json_name, result: [])
  end

  defp return_result(nil, json_name, conn) do
    conn
    |> put_status(400)
    |> put_view(RuvView)
    |> render(json_name, result: nil)
  end

  defp return_result(result, json_name, conn) do
    conn
    |> put_status(200)
    |> put_view(RuvView)
    |> render(json_name, result: result)
  end

  def get_ruvs(conn, params) when is_map(params) do
    :search
    |> RuvContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RuvContext.get_ruvs()
    |> return_result("ruvs.json", conn)
  end

  def get_ruvs(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)

  def get_ruv(conn, params) when is_map(params) do
    :view
    |> RuvContext.validate_params(params)
    |> ValidationContext.valid_changeset()
    |> RuvContext.get_ruv()
    |> return_result("ruv.json", conn)
  end

  def get_ruv(conn, _params), do: return_result({:error_message, "Invalid arguments!"}, "error.json", conn)
end
