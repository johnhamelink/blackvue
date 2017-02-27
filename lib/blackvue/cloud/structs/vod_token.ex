defmodule Blackvue.Cloud.Structs.VODToken do

  defstruct token: nil,
            limit: 0,
            usage: 0

  def into({:ok, data}) do
    %Blackvue.Cloud.Structs.VODToken{
      token: data["vod_token"],
      limit: String.to_integer(data["vod_limit"]),
      usage: String.to_integer(data["vod_usage"])
    }
  end

  def into("Invalid Parameter") do
    {:error, "Invalid Parameter in request"}
  end

end
