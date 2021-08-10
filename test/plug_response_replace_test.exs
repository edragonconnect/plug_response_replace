defmodule PlugResponseReplaceTest do
  use ExUnit.Case

  use Plug.Test

  describe "replace resp_body" do
    test "json response body" do
      data =
        Jason.encode_to_iodata!(%{
          "url" => "https://www.foobar.com",
          "hello" => "world",
          "content" => "测试内容"
        })

      opts = [
        resp_body: %{
          pattern: "https://www.foobar.com",
          replacement: "https://www.barfoo.com"
        }
      ]

      conn =
        conn(:get, "/")
        |> put_req_header("content-type", "application/json")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, data)

      assert conn.resp_body =~ ~s(https://www.barfoo.com)
      assert conn.resp_body =~ ~s("hello":"world")
      assert conn.status == 200

      opts = [
        resp_body: %{
          pattern: ~r("https://www.foobar.com"),
          replacement: "https://www.barfoo2.com"
        }
      ]

      conn =
        conn(:get, "/")
        |> put_req_header("content-type", "application/json")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, data)

      assert conn.resp_body =~ ~s(https://www.barfoo2.com)
      assert conn.resp_body =~ ~s("hello":"world")
      assert conn.status == 200
    end

    test "binary response body" do
      opts = [
        resp_body: %{
          pattern: "hello",
          replacement: "hi"
        }
      ]

      conn =
        conn(:get, "/")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, "hello, this test, hello, yes")

      assert conn.resp_body == "hi, this test, hi, yes"
      assert conn.status == 200
    end

    test "replace resp_body with global as false" do
      opts = [
        resp_body: %{
          pattern: "hello",
          replacement: "hi",
          options: [global: false]
        }
      ]

      conn =
        conn(:get, "/")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, "hello, this test, hello, yes")

      assert conn.resp_body == "hi, this test, hello, yes"
      assert conn.status == 200
    end
  end

  describe "replace resp_cookies" do
    test "replace resp_cookies" do
      value_to_key2 = Jason.encode!(%{"name" => "testname"})

      opts = [
        resp_cookies: [
          {"key1", "new"},
          {"key2", value_to_key2}
        ]
      ]

      conn =
        conn(:get, "/")
        |> put_resp_cookie("key1", "1")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, "hello")

      resp_cookies = conn.resp_cookies
      assert resp_cookies["key1"].value == "new"
      assert resp_cookies["key2"].value == value_to_key2
    end

    test "replace and sign resp_cookies" do
      opts = [
        resp_cookies: [
          {"key1", %{"session" => "abcdef", "timestamp" => 123}, [sign: true]}
        ]
      ]

      conn =
        conn(:get, "/")
        |> Map.put(:secret_key_base, "abcdef0123456789")
        |> put_resp_cookie("key1", "1")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, "hello")

      assert conn.resp_cookies["key1"].value != "1"
      assert conn.status == 200 and conn.resp_body == "hello"
    end
  end

  describe "replace resp_headers" do
    test "replace resp_headers" do
      opts = [
        resp_headers: [
          {"content-type", "text/plain"}
        ]
      ]

      conn =
        conn(:get, "/")
        |> put_resp_header("content-type", "application/json")
        |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
        |> send_resp(200, "ok")

      assert List.keyfind(conn.resp_headers, "content-type", 0) == {"content-type", "text/plain"}
      assert conn.status == 200 and conn.resp_body == "ok"
    end
  end

  test "integration" do
    body =
      Jason.encode_to_iodata!(%{
        "url1" => "https://www2.foo.com",
        "url2" => "https://www.foo.com"
      })

    opts = [
      resp_body: %{
        pattern: "https://www2.foo.com",
        replacement: "https://www.bar.com"
      },
      status: 201,
      resp_headers: [
        {"content-type", "application/json; charset=utf-8"}
      ],
      resp_cookies: [
        {"key1", "newabc"}
      ]
    ]

    conn =
      conn(:post, "/")
      |> PlugResponseReplace.call(PlugResponseReplace.init(opts))
      |> put_resp_cookie("key1", "abc")
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)

    assert conn.status == 201
    assert conn.resp_cookies["key1"].value == "newabc"
    {_, content_type} = List.keyfind(conn.resp_headers, "content-type", 0)
    assert content_type == "application/json; charset=utf-8"
    resp_body = conn.resp_body
    assert resp_body =~ ~r"https://www.foo.com"
    assert resp_body =~ ~r"https://www.bar.com"
  end
end
