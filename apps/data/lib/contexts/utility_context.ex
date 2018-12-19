defmodule Data.Contexts.UtilityContext do
  @moduledoc false

  use Arc.Ecto.Schema
  alias Data.Schemas.RoomArchive
  alias Ecto.Changeset
  alias Phoenix.HTML

  def generate_csv({:error, changeset}, _, _), do: {:error, changeset}
  def generate_csv([], _, _), do: {:error_message, "No results found"}
  def generate_csv(map, headers, module) do
    list = transform_values(map, module)
    datetime = get_download_date(DateTime.utc_now())
    path = get_application_path(Application.get_env(:data, :env))

    File.mkdir_p!(path)

    file = File.open!("#{path}/#{module}_#{datetime}.csv", [:write, :utf8])

    [headers] ++ list
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))

    generated_file = %{
      filename: "#{module}_#{datetime}.csv",
      path: path
    }

    {generated_file, "csv"}
  end

  # Comments until storage is changed

  # def upload_to_google({:error, changeset}), do: {:error, changeset}
  # def upload_to_google({:error_message, message}), do: {:error_message, message}
  # def upload_to_google(file) do
  #   file
  # end

  def upload_to_s3({:error, changeset}, _), do: {:error, changeset}
  def upload_to_s3({:error_message, message}, _), do: {:error_message, message}
  def upload_to_s3({file, _type}, conn) do
    path = get_application_path(Application.get_env(:data, :env))
    scope = %RoomArchive{id: Ecto.UUID.generate()}

    Data.FileUploader.store({%{filename: "#{file.filename}", path: "#{path}/#{file.filename}"}, scope})
    url = Data.FileUploader.url({file.filename, scope}, :original)
    File.rm_rf("#{path}/#{file.filename}")

    %{url: url, conn: conn}
  end

  def upload_to_s31({:error, _}), do: ""
  def upload_to_s31({:error, _}), do: ""
  def upload_to_s31(file) do
    path = get_application_path(Application.get_env(:data, :env))
    scope = %RoomArchive{id: Ecto.UUID.generate()}

    Data.FileUploader.store({%{filename: "#{file.filename}", path: "#{path}/#{file.filename}"}, scope})
    url = Data.FileUploader.url({file.filename, scope}, :original)
    File.rm_rf("#{path}/#{file.filename}")

    %{url: url}
  end

  def transform_error_message(changeset) do
    errors = Enum.map(changeset.errors, fn({key, {message, _}}) ->
      %{
         key => transform_message(key, message)
      }
    end)

    Enum.reduce(errors, fn(head, tail) ->
      Map.merge(head, tail)
    end)
  end

  defp transform_message(key, "is required"), do: "Enter #{key}"
  defp transform_message(key, "room is required"), do: "Enter Room #{key}"
  defp transform_message(:error, message), do: "#{message}"
  defp transform_message(key, message), do: "#{key} #{message}"
  defp transform_message(key, "room is required", :room_update), do: "Enter Room #{key}"
  defp transform_message(key, message, :room_update), do: "Room #{key} #{message}"

  def transform_error_message(changeset, :create) do
    errors = Enum.map(changeset.errors, fn({key, {message, _}}) ->
      %{
         key => "Room #{key} #{message}"
      }
    end)

    Enum.reduce(errors, fn(head, tail) ->
      Map.merge(head, tail)
    end)
  end

  def transform_error_message(changeset, :facility_group) do
    errors = Enum.map(changeset.errors, fn({key, {message, _}}) ->
      %{
         key => transform_message_v2(key, "#{message}")
      }
    end)

    Enum.reduce(errors, fn(head, tail) ->
      Map.merge(head, tail)
    end)
  end
  defp transform_message_v2(key, "is required"), do: "Enter #{key}"
  defp transform_message_v2(_key, message), do: "#{message}"

  def transform_error_message(changeset, :room_update) do
    errors = Enum.map(changeset.errors, fn({key, {message, _}}) ->
      %{
         key => transform_message(key, message, :room_update)
      }
    end)

    Enum.reduce(errors, fn(head, tail) ->
      Map.merge(head, tail)
    end)
  end

  def transform_error_message_package(changeset) do
    errors = Enum.map(changeset.errors, fn({key, {message, _}}) ->
      %{
         key => transform_message_v2(key, "#{message}")
      }
    end)

    Enum.reduce(errors, fn(head, tail) ->
      Map.merge(head, tail)
    end)
  end
  defp transform_message_package(key, "is required"), do: "Enter #{key}"
  defp transform_message_package(key, "is invalid"), do: "Invaid #{key}"
  defp transform_message_package(_key, message), do: "#{message}"

  defp get_download_date(datetime) do
    {year, month, date} = transform_date(datetime)
    {hour, minute, _second} = transform_time(datetime)
    ph_hour = get_ph_time(hour)
    char_month = transform_month(month)

    "#{char_month}-#{date}-#{year}-#{ph_hour}-#{minute}"
  end

  defp transform_date(datetime) do
    datetime
    |> to_string
    |> String.split(" ")
    |> Enum.at(0)
    |> String.split("-")
    |> List.to_tuple()
  end

  defp transform_time(datetime) do
    datetime
    |> to_string
    |> String.split(" ")
    |> Enum.at(1)
    |> String.split(":")
    |> List.to_tuple()
  end

  defp get_ph_time(hour) do
    hour = String.to_integer(hour)
    ph_hour = hour + 8

    if ph_hour > 24 do
      (24 - ph_hour)
      |> Integer.to_string()
    else
      Integer.to_string(ph_hour)
    end
  end

  defp transform_values(map, "Diagnosis") do
    Enum.map(map, &(Map.values(%{
      a_group_code: &1.group_code,
      b_code: &1.code,
      c_group_desc: &1.group_desc,
      d_standard: &1.standard,
      e_is_dreaded: &1.is_dreaded,
      f_is_congenital: &1.is_congenital
    }))
    )
  end

  defp transform_values(map, "Procedure") do
    Enum.map(map, &(Map.values(%{
      a_code: &1.code,
      b_desc: &1.desc,
      c_type: &1.type,
      d_standard: &1.standard,
      e_rate_type: &1.rate_type,
    }))
    )
  end

  defp transform_values(map, "Rooms") do
    Enum.map(map, &(Map.values(%{
      a_code: &1.code,
      b_category: &1.category,
      c_hierarchy: &1.hierarchy,
      d_updated_at: &1.updated_at,
      e_updated_by: &1.updated_by,
    }))
    )
  end

  defp transform_values(map, "Miscellany") do
    Enum.map(map, &(Map.values(%{
      a_item_code: &1.code,
      b_description: &1.description,
      c_max_price: &1.max_price,
      d_updated_at: &1.updated_at,
      e_updated_by: &1.updated_by,
    }))
    )
  end

  def get_application_path(:test), do: Path.expand('./../../uploads/files/')
  def get_application_path(:dev), do: Path.expand('./uploads/files/')
  def get_application_path(:prod), do: Path.expand('./uploads/files/')
  def get_application_path(_), do: nil

  defp transform_month("01"), do: "JAN"
  defp transform_month("02"), do: "FEB"
  defp transform_month("03"), do: "MAR"
  defp transform_month("04"), do: "APR"
  defp transform_month("05"), do: "MAY"
  defp transform_month("06"), do: "JUN"
  defp transform_month("07"), do: "JUL"
  defp transform_month("08"), do: "AUG"
  defp transform_month("09"), do: "SEP"
  defp transform_month("10"), do: "OCT"
  defp transform_month("11"), do: "NOV"
  defp transform_month("12"), do: "DEC"

  def do_randomizer(length, lists) do
    range = get_range(length)
    range
    |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end

  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  def check_errors(changeset, _, []), do: changeset
  def check_errors(changeset, key, errors), do: changeset |> Map.put(key, errors)

  def valdiate_file(changeset, nil, _, key, _, required) do
    if required do
      changeset |> Changeset.add_error(key, "is required")
    else
      changeset
    end
  end
  def valdiate_file(changeset, "", _, key, _, required) do
    if required do
      changeset |> Changeset.add_error(key, "is required")
    else
      changeset
    end
  end
  def validate_file(changeset, base64, name, key, key_name, _) do
    if !String.contains?(base64, "data:") || !String.contains?(base64, ";base64,") do
      changeset |> Changeset.add_error(key, "is invalid")
    else
      changeset |> Changeset.put_change(key, base64)
    end
  end

  def convert_file(changeset, _, "", _, _), do: {:error, changeset}
  def convert_file(changeset, _, nil, _, _), do: {:error, changeset}
  def convert_file(changeset, base64, filename, key, key_name) do
    if is_nil(base64) || base64 == "" do
      {:error, changeset}
    else
      ss = String.split(base64, [":", ";"])

      file_type =
        ss
        |> Enum.at(1)
        |> String.split("/")
        |> Enum.at(0)

      extension =
        ss
        |> Enum.at(1)
        |> String.split("/")
        |> Enum.at(1)

        {start, length} = :binary.match(base64, ";base64,")
        base64_encoded = :binary.part(base64, start +
          length, byte_size(base64) - start - length)

          pathsample = case Application.get_env(:data, :env) do
            :test ->
              Path.expand('./../../uploads/files/')
            :dev ->
              Path.expand('./uploads/files/')
            :prod ->
              Path.expand('./uploads/files/')
          end

          File.mkdir_p!(pathsample)
          File.write!(pathsample <> "/#{key_name}_#{filename}.#{extension}", Base.decode64!(base64_encoded))

          %{
            path: pathsample,
            filename: "#{key_name}_#{filename}.#{extension}"
          }
    end
  end

  def delete_upload_folder() do
    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
    end
    File.rm_rf(pathsample)

    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/files/')
      :dev ->
        Path.expand('./uploads/files/')
      :prod ->
        Path.expand('./uploads/files/')
    end
    File.rm_rf(pathsample)
  end

  def sanitize([map | list], result) when is_list(list) do
    sanitize_map =  Map.new(%{})

    sanitize_map =
      Map.new(
        map, fn {k, v} ->
          {k, sanitize(v)}
        end
      )

    list
    |> sanitize(result ++ [sanitize_map])
  end

  def sanitize([], result), do: result

  def sanitize(value) do
    {:safe, data} = HTML.html_escape(value)

    data
    |> HTML.raw()
    |> HTML.safe_to_string()
  end
end
