defmodule Blackvue.Cloud.VOD do
  alias Blackvue.Cloud.Client
  alias Blackvue.Cloud.Structs.Device, as: DeviceStruct
  alias Blackvue.Cloud.Structs.VOD, as: VODStruct
  alias Blackvue.Cloud.Structs.VODToken

  def list(device = %DeviceStruct{}) do
    uri = %{DeviceStruct.lb_server(device) | path: "/proc/vod_list"}
    Client.get(uri, [psn: device.psn])
    |> VODStruct.into
  end

  # TODO: Use an Agent to manage the API backpressure here.
  defp request_vod_token(device = %DeviceStruct{}, file) do
    uri = %{DeviceStruct.lb_server(device) | path: "/app/vod_play_req.php"}
    Client.get(uri, [psn: device.psn, filename: file])
    |> VODToken.into
  end

  # TODO: Make this into a GenServer
  # TODO: Make this async because it can be very slow.
  # TODO: Maybe use Stream somehow?
  def retrieve_file(device = %DeviceStruct{}, %VODStruct{file: file}) do
    # Retrieve permission to download file
    %VODToken{token: token} = request_vod_token(device, file)
    # Actually download the file
    uri = %{DeviceStruct.lb_server(device) | path: "/proc/vod_file"}
    Client.get(uri, [psn: device.psn, filename: file, vod_token: token])
  end

end
