defmodule ApiWeb.StatusView do
  def render("index.json", %{version: version}) do
    %{
      status: "ok",
      version: version
    }
  end
end
