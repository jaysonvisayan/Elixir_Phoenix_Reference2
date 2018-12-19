defmodule Data.Seeders.PackageSeeder do
  @moduledoc false

  alias Data.Contexts.PackageContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case PackageContext.insert_package_seed(params) do
        {:ok, package} ->
          package
      end
    end)
  end
end
