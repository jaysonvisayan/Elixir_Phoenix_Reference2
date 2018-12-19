defmodule ApiWeb.V1.StatusController do
  use ApiWeb, :controller

  def index(conn, _params) do
    version = :api |> Application.spec(:vsn) |> String.Chars.to_string
    render(conn, "index.json", %{version: version})
  end
end
