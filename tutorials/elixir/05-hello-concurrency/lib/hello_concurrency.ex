defmodule HelloConcurrency do
  @moduledoc """
  Demonstrates Elixir concurrency with Task.async_stream and Erlang's :httpc.
  """

  @doc """
  Fetches multiple URLs in parallel using Task.async_stream.
  Returns a list of `{url, {:ok, status_code}}` or `{url, {:error, reason}}`.
  """
  def fetch_all(urls) do
    urls
    |> Task.async_stream(fn url -> {url, fetch(url)} end, max_concurrency: 5, timeout: 15_000)
    |> Enum.map(fn
      {:ok, {url, result}} -> {url, result}
      {:exit, reason} -> {"unknown", {:error, reason}}
    end)
  end

  @doc """
  Fetches a single URL using :httpc.request/1.
  Returns `{:ok, status_code}` or `{:error, reason}`.
  """
  def fetch(url) do
    case :httpc.request(:get, {to_charlist(url), []}, [{:ssl, ssl_opts()}], []) do
      {:ok, {{_http_version, status_code, _reason_phrase}, _headers, _body}} ->
        {:ok, status_code}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ssl_opts do
    [
      verify: :verify_peer,
      cacerts: :public_key.cacerts_get(),
      depth: 3,
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ]
  end

  @doc """
  Fetches a few URLs and prints the results.
  """
  def demo do
    urls = [
      "https://httpbin.org/get",
      "https://httpbin.org/status/404",
      "https://httpbin.org/status/500"
    ]

    IO.puts("Fetching #{length(urls)} URLs in parallel...\n")

    results = fetch_all(urls)

    Enum.each(results, fn {url, result} ->
      case result do
        {:ok, status} -> IO.puts("  #{url} -> #{status}")
        {:error, reason} -> IO.puts("  #{url} -> ERROR: #{inspect(reason)}")
      end
    end)

    IO.puts("\nDone!")
  end
end
