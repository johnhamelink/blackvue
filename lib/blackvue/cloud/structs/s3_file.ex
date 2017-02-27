defmodule Blackvue.Cloud.Structs.S3File do

  defstruct filename: nil,
            expires: nil

  def into({:ok, %{"filelist" => files}}) do
    Enum.map(files, fn(file) ->
      Blackvue.Cloud.Structs.S3File.into(:file, file)
    end)
  end

  def into(:file, file = %{}) do
    %Blackvue.Cloud.Structs.S3File{
      filename: file["filename"],
      expires: NaiveDateTime.from_iso8601!(file["exp"])
    }
  end

end
