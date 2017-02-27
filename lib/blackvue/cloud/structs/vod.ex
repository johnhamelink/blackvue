defmodule Blackvue.Cloud.Structs.VOD do

  defstruct time: nil,
            mode: nil,
            camera: nil,
            extension: nil,
            file: nil

  def modes do
    %{
      "P" => :parked,
      "M" => :manual,
      "E" => :event,
      "N" => :normal
    }
  end

  def modes(mode) when is_bitstring(mode),
  do: modes[mode]

  def modes(nil), do: nil

  def cameras do
    %{
      "F" => :front,
      "R" => :rear
    }
  end

  def cameras(cam) when is_bitstring(cam),
  do: cameras[cam]

  def cameras(nil), do: nil

  def into({:ok, %{"filelist" => files}}) do
    Enum.map(files, fn(file) ->
      into(:vod, file)
    end)
  end

  def into(:vod, file) do
    vod_parse_regex = ~r/^(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})_(?<mode>\w{1})(?<camera>\w{0,1})\.(?<extension>\w+)$/

    vod = Regex.named_captures(vod_parse_regex, file)
    vod =
      case vod["camera"] == "" do
        true -> %{vod | "camera" => nil}
        false -> vod
      end

    {:ok, timestamp} = NaiveDateTime.new(
      String.to_integer(vod["year"]),
      String.to_integer(vod["month"]),
      String.to_integer(vod["day"]),
      String.to_integer(vod["hour"]),
      String.to_integer(vod["minute"]),
      String.to_integer(vod["second"]))

    %Blackvue.Cloud.Structs.VOD{
      time:      timestamp,
      mode:      modes(vod["mode"]),
      camera:    cameras(vod["camera"]),
      extension: vod["extension"],
      file:      file
    }
  end

end
