defmodule ApiWeb.FacilityGroupView do
  use ApiWeb, :view

  def render("facility_groups.json", %{facility_groups: facility_groups}) do
    %{
      total_number: length(facility_groups),
      facility_groups: facility_groups
    }
  end

  def render("error.json", %{error: error}) do
    %{
      errors: error
    }
  end

  def render("success_insert_facility_group.json", %{facility_groups: facility_groups}) do
    %{
      code: facility_groups.code,
      name: facility_groups.name,
      description: facility_groups.description,
      selecting_type: show_selecting_type(facility_groups.selecting_type),
      facility_codes: facility_groups.facility_codes,
      regions: %{
        all_luzon: facility_groups.all_luzon,
        all_visayas: facility_groups.all_visayas,
        all_mindanao: facility_groups.all_mindanao,
        regions: show_region_names(facility_groups.regions)
      },
      status: facility_groups.status,
      version: facility_groups.version,
      inserted_by: facility_groups.inserted_by,
      inserted_at: facility_groups.inserted_at,
      updated_by: facility_groups.updated_by,
      updated_at: facility_groups.updated_at
    }
  end

  defp show_region_names(nil), do: nil
  defp show_region_names(region_codes) do
    Enum.map(region_codes, fn(region_code) ->
      case region_code do
        "NCR" ->
          "NCR"
        "CAR" ->
          "CAR"
        "ARMM" ->
          "ARMM"
        "R-IVA" ->
          "Region IV-A"
        "R-IVB" ->
          "Region IV-B"
        _ ->
          rcode =
            region_code
            |> String.split("-")
            |> List.delete_at(0)
          "Region #{rcode}"
      end
    end)
  end

  defp show_selecting_type(nil), do: nil
  defp show_selecting_type(selecting_type) do
    if String.upcase(selecting_type) == "F" do
      "Facility"
    else
      "Region"
    end
  end
end
