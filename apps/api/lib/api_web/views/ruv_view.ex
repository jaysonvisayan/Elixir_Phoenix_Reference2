defmodule ApiWeb.RuvView do
  use ApiWeb, :view

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("ruvs.json", %{result: []}) do
    %{
      error: %{search: "No ruvs matched your search"}
    }
  end

  def render("ruvs.json", %{result: result}) do
    %{
      total_number: length(result),
      ruvs: result
    }
  end

  def render("ruv.json", %{result: nil}) do
    %{
      error: %{view: "Bad request. Validation failed"}
    }
  end

  def render("ruv.json", %{result: result}) do
    ruv = render_many(result.ruv_multipliers, ApiWeb.RuvView, "ruv_multipliers.json", as: :ruv_multiplier)
    %{
      code: result.code,
      desc: result.desc,
      unit: result.unit,
      updated_by: result.updated_by,
      updated_at: result.updated_at,
      ruv_multipliers: ruv |> ruv_multipliers()
    }
  end

  defp ruv_multipliers([]), do: "No records found on ruv multipliers"
  defp ruv_multipliers(frr), do: frr

  def render("ruv_multipliers.json", %{ruv_multiplier: ruv_multiplier}) do
    %{
      room_category: ruv_multiplier.room_category,
      room_multiplier: ruv_multiplier.amount,
      effective_date: ruv_multiplier.effective_date
    }
  end
end
