defmodule Blackvue.Cloud.S3 do
  alias Blackvue.Cloud.{Client, Auth}
  alias Blackvue.Cloud.Structs.Device, as: DeviceStruct
  alias Blackvue.Cloud.Structs.S3File

  def list(device = %DeviceStruct{}) do
    uri = %{Auth.was_server | path: "/app/s3_filelist2.php"}
    Client.get(uri, [psn: device.psn])
    |> S3File.into
  end

  def download_url(device = %DeviceStruct{}, %S3File{filename: filename}) do
    uri = %{DeviceStruct.lb_server(device) | path: "/app/user_s3_presigned_url.php"}
    Client.get(uri, [psn: device.psn, filename: filename])
  end
end
