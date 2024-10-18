import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/otp/actor
import gleam/otp/supervisor
import gleam/result
import mist.{type Connection, type ResponseData}
import nakai
import nakai/html

// ------ App startup ------ //

pub fn main() {
  io.println("Starting up server...")
  let assert Ok(_) = supervisor()
  process.sleep_forever()
}

fn supervisor() {
  supervisor.start(fn(children) {
    children
    |> supervisor.add(server_childspec())
  })
}

fn server_childspec() {
  let to_init_failed = fn(_error) {
    let reason = process.Abnormal("server start error")
    actor.InitFailed(reason)
  }

  supervisor.supervisor(fn(_caller) {
    serve()
    |> result.map_error(to_init_failed)
  })
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
