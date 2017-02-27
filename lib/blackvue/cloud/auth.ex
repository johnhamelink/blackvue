defmodule Blackvue.Cloud.Auth do

  require Logger

  def start_link do
    Logger.info "Booting up Client Agent"
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def user_token,
    do: state()[:user_token]

  def email,
  do: state()[:email]

  def was_server do
    %URI{
      scheme: "https",
      host: state()[:was_server],
      port: state()[:was_port]
    }
  end

  def session_params do
    [
      email: state()[:email],
      user_token: state()[:user_token]
    ]
  end

  def state,
  do: Agent.get(__MODULE__, & &1)

  def should_request? do
    !(Map.has_key?(state(), :user_token) && state()[:user_token] != nil)
  end

  def auth(),
  do: auth(Application.get_env(:blackvue, :email), Application.get_env(:blackvue, :password))

  def auth(email, password) do
    if should_request?() do
      reauth(email, password)
    end

    state()
  end

  def reauth(email, password) do
    password_hash = :crypto.hash(:sha256, password) |> Base.encode16
    url = "https://pitta.blackvuecloud.com/app/user_login.php"

    payload = [
      email: email,
      passwd: password_hash,
      mobile_name: "iPhone",
      app_ver: "2.56",
      mobile_uuid: "A241C1BD-E0F9-4B56-B3FD-AD3BAE06DC02",
      mobile_os_type: "ios",
      time_interval: 0
    ] |> URI.encode_query

    case HTTPoison.post(url, payload, Blackvue.Cloud.Client.default_headers) do
      {:ok, %{body: body, status_code: 200}} ->
        json = Poison.decode!(body)

        state = %{
          gps_port:   String.to_integer(json["gps_port"]),
          gps_server: json["gps_server"],
          user_token: json["user_token"],
          was_port:   String.to_integer(json["was_port"]),
          was_server: json["was_server"],
          email:      email,
          password:   password_hash
        }

        Agent.update(__MODULE__, fn _ -> state end)
        Logger.info("Updated Client state")
      err ->
        Logger.error("Bad response from server: #{err}")
    end
  end

end
