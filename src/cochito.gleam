import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import mist.{type Connection, type ResponseData}
import nakai
import nakai/html

// ------ App startup ------ //

pub fn main() {
  io.println("Hello from cochito!")

  let assert Ok(_) = serve()

  process.sleep_forever()
}

// ------ Server logic ------ //

fn serve() {
  mist.new(pipeline)
  |> mist.port(8088)
  |> mist.start_http()
}

fn pipeline(request: Request(Connection)) -> Response(ResponseData) {
  request
  |> router()
}

fn router(request: Request(Connection)) -> Response(ResponseData) {
  case request.path_segments(request) {
    [] -> index()
    _other -> not_found()
  }
}

fn index() -> Response(ResponseData) {
  let page =
    page_index()
    |> nakai.to_string_builder()
    |> bytes_builder.from_string_builder()

  response.new(200)
  |> response.prepend_header("content-type", "text/html; charset=utf-8")
  |> response.set_body(mist.Bytes(page))
}

fn not_found() -> Response(ResponseData) {
  let page =
    page_error()
    |> nakai.to_string_builder()
    |> bytes_builder.from_string_builder()

  response.new(404)
  |> response.set_body(mist.Bytes(page))
}

// ------ HTML pages ------ //

fn page_index() -> html.Node {
  html.h1([], [html.Text("Hello World")])
}

fn page_error() -> html.Node {
  html.h1([], [html.Text("Not found")])
}
