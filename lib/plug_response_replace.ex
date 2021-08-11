defmodule PlugResponseReplace do
  @behaviour Plug

  @response_fields [:resp_body, :resp_cookies, :resp_headers, :status]

  def init(opts \\ []), do: opts

  def call(conn, []), do: conn

  def call(conn, opts) do
    Plug.Conn.register_before_send(conn, fn conn ->
      opts
      |> Keyword.take(@response_fields)
      |> Enum.reduce(conn, fn
        {:resp_body, settings}, conn ->
          replace(:resp_body, Map.new(settings), conn)
        {response_field, settings}, conn ->
          replace(response_field, settings, conn)
      end)
    end)
  end

  defp replace(
         :resp_body,
         %{pattern: pattern, replacement: replacement} = resp_body_replace,
         %Plug.Conn{resp_body: resp_body} = conn
       ) do
    options = Map.get(resp_body_replace, :options, [])
    resp_body = replace_resp_body(resp_body, pattern, replacement, options)
    Map.put(conn, :resp_body, resp_body)
  end

  defp replace(:resp_cookies, cookies, conn) when is_list(cookies) do
    Enum.reduce(cookies, conn, fn
      {key, value, opts}, conn ->
        Plug.Conn.put_resp_cookie(conn, key, value, opts)

      {key, value}, conn ->
        Plug.Conn.put_resp_cookie(conn, key, value)
    end)
  end

  defp replace(:resp_headers, new_headers, conn) when is_list(new_headers) do
    Enum.reduce(new_headers, conn, fn {key, value}, conn ->
      Plug.Conn.put_resp_header(conn, key, value)
    end)
  end

  defp replace(:status, status, conn) when is_integer(status) or is_atom(status) do
    Plug.Conn.put_status(conn, status)
  end

  defp replace_resp_body(resp_body, pattern, replacement, options) when is_list(resp_body) do
    resp_body
    |> IO.chardata_to_string()
    |> String.replace(pattern, replacement, options)
  end

  defp replace_resp_body(resp_body, pattern, replacement, options) when is_binary(resp_body) do
    String.replace(resp_body, pattern, replacement, options)
  end
end
