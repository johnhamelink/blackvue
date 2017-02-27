defmodule Blackvue.Cloud.Device do
  alias Blackvue.Cloud.{Client, Auth}
  alias Blackvue.Cloud.Structs.Device, as: DeviceStruct

  def list do
    uri = %{Auth.was_server | path: "/app/device_list.php"}
    Client.get(uri, [])
    |> DeviceStruct.into
  end

  def get_config(device = %DeviceStruct{}) do
    uri = %{DeviceStruct.lb_server(device) | path: "/proc/get_config"}
    Client.get(uri, [filename: "config.ini", psn: device.psn])
  end

  def set_config(device = %DeviceStruct{}, config) do
    uri = %{DeviceStruct.lb_server(device) | path: "/proc/set_config"}
    Client.get(uri, [filename: "config.ini", psn: device.psn, data: Base.encode64(config)])
  end

end
