defmodule Data.Seeders.PractitionerPrimaryRoomSeeder do
  @moduledoc false

  alias Data.Contexts.PractitionerContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case PractitionerContext.insert_practitioner_primary_room_seed(params) do
        {:ok, p} ->
          p
      end
    end)
  end
end



