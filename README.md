# PlugResponseReplace

A tiny plug for replacing [response fields](https://hexdocs.pm/plug/Plug.Conn.html#module-response-fields).

## Installation

Add a dependency to your application's mix.exs file:

```elixir
def deps do
  [
    {:plug_response_replace, "~> 0.1"}
  ]
end
```

then run `mix deps.get`.


## Usage

Replace `:resp_body` of `Plug.Conn`, the `iodata()` response body with the following `:pattern`, `:replacement`, and `options`
fields are completely used to `String.replace/4`.

```
defmodule MyHandler do
  use Plug.Builder

  plug PlugResponseReplace, 
    resp_body: %{
      pattern: "...",
      replacement: "...",
      options: [] # optional
    }

  # ... rest of the pipeline
end
```

Replace `:resp_cookies` of `Plug.Conn`, the item of the following `:resp_cookies` is a tuple contains a pair of response cookie key
and value used to `Plug.Conn.put_resp_cookie/4`, the item may contain an optional options, see `Plug.Conn.put_resp_cookie/4` for details.

```
defmodule MyHandler do
  use Plug.Builder

  plug PlugResponseReplace, 
    resp_cookies: [
      {"key1", "new"},
      {"key1", %{"session" => "abcdef", "timestamp" => 123}, [sign: true]}
    ]

  # ... rest of the pipeline
end
```

Replace `:resp_headers` of `Plug.Conn`, the item of the following `:resp_headers` is a tuple contains a pair of header key and value
used to `Plug.Conn.put_resp_header/3`.

```
defmodule MyHandler do
  use Plug.Builder

  plug PlugResponseReplace, 
    resp_headers: [
      {"content-type", "text/plain"}
    ]

  # ... rest of the pipeline
end
```

Replace `:status` of `Plug.Conn`, override the status of repsonse with a proper value.

```
defmodule MyHandler do
  use Plug.Builder

  plug PlugResponseReplace, 
    status: 401

  # ... rest of the pipeline
end
```
