defmodule Blackvue.Cloud.Structs.Device do

  defstruct valid: nil,
            model: nil,
            psn: nil,
            active: false,
            dev_name: nil,
            lb_server_name: nil,
            lb_http_port: 0,
            lb_rtmp_port: 0,
            share_video: false,
            share_audio: false,
            share_dev_name: false,
            share_gps: true,
            fw_ver: nil,
            dev_shared_cnt: 0

  def lb_server(device = %Blackvue.Cloud.Structs.Device{}) do
    %URI{
      scheme: "https",
      port: device.lb_http_port,
      host: device.lb_server_name
    }
  end

  def into({:ok, %{"device list" => %{"info" => list}}}) do
    Enum.map(list, fn(data) ->
      Blackvue.Cloud.Structs.Device.into(:device, data)
    end)
  end

  def into(:device, device = %{}) do
    %Blackvue.Cloud.Structs.Device{
      active:         (device["active"] == "on"),
      valid:          (device["valid"] == "valid"),
      dev_name:       device["dev_name"],
      dev_shared_cnt: device["dev_shared_cnt"],
      fw_ver:         device["fw_ver"],
      lb_http_port:   String.to_integer(device["lb_http_port"]),
      lb_rtmp_port:   String.to_integer(device["lb_rtmp_port"]),
      lb_server_name: device["lb_server_name"],
      model:          device["model"],
      psn:            device["psn"],
      share_audio:    (device["share_audio"] == "on"),
      share_dev_name: (device["share_dev_name"] == "on"),
      share_gps:      (device["share_gps"] == "on"),
      share_video:    (device["share_video"] == "on")
    }
  end

end
