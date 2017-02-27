defmodule Blackvue.Cloud.Client do
  use HTTPoison.Base
  require Logger

  @options [recv_timeout: 50_000]

  def default_headers() do
    [
      {"Accept", "*/*"},
      {"Accept-Language", "en-gb"},
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"User-Agent", "BlackVueC/2126 CFNetwork/811.4.16 Darwin/16.5.0"}
    ]
  end

  def add_auth(body),
  do: body ++ Blackvue.Cloud.Auth.session_params

  def get(uri = %URI{}, params, custom_headers \\ []) when is_list(params) do
    payload =
      params
      |> add_auth
      |> URI.encode_query
    headers = default_headers() ++ custom_headers
    uri = %{uri | query: payload}

    Logger.debug("GET request to: #{uri}")
    case uri.path == "/proc/vod_file" do
      true ->
        Logger.warn("TODO: Make it possible to download large files from VOD")
        Logger.warn("Not executing request")
      false ->
        handle_response(request(:get, uri, [], headers, @options))
    end
  end

  def call_api(verb, uri = %URI{}, body, custom_headers \\ []) when is_list(body) do
    payload =
      body
      |> add_auth
      |> URI.encode_query
    headers = default_headers() ++ custom_headers

    Logger.debug("Sending #{verb} request: #{payload} to #{uri}")
    handle_response(request(verb, uri, payload, headers, @options))
  end

  def handle_response({:ok, %HTTPoison.Response{body: nil}}),
  do: nil

  def handle_response({:ok, %HTTPoison.Response{body: body}}) do
    case Poison.decode(body) do
      {:ok, json} -> {:ok, json}
      _other -> body
    end
  end

end
