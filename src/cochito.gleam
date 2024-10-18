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
import nakai/attr
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

// ------ Server logic and middleware ------ //

fn serve() {
  let middleware = fn(request: Request(Connection)) -> Response(ResponseData) {
    request
    |> router()
    |> from_document()
  }

  mist.new(middleware)
  |> mist.port(8088)
  |> mist.start_http()
}

fn from_document(response: Response(html.Node)) -> Response(ResponseData) {
  response
  |> response.prepend_header("content-type", "text/html; charset=utf-8")
  |> response.map(fn(page: html.Node) -> ResponseData {
    page
    |> nakai.to_string_builder()
    |> bytes_builder.from_string_builder()
    |> mist.Bytes()
  })
}

fn router(request: Request(Connection)) -> Response(html.Node) {
  case request.path_segments(request) {
    [] ->
      response.new(200)
      |> response.set_body(page_index())

    _other ->
      response.new(400)
      |> response.set_body(page_error())
  }
}

// ------ HTML pages ------ //

fn page_index() -> html.Node {
  html.Fragment([
    html.h1([], [html.Text("Vaquita Marino o Cochito")]),
    html.p([], [html.Text("From wikipedia:")]),
    html.blockquote(
      [attr.cite("https://es.wikipedia.org/wiki/Phocoena_sinus")],
      [
        html.Text(
          "The vaquita (/vəˈkiːtə/ və-KEE-tə; Phocoena sinus) is a species of porpoise endemic
          to the northern end of the Gulf of California in Baja California, Mexico.
          Reaching a maximum body length of 150 cm (4.9 ft) (females) or 140 cm (4.6 ft) (males),
          it is the smallest of all living cetaceans.

          The species is currently on the brink of extinction, and is listed as Critically
          Endangered by the IUCN Red List; the steep decline in abundance is primarily due to
          bycatch in gillnets from the illegal totoaba fishery.",
        ),
      ],
    ),
  ])
}

fn page_error() -> html.Node {
  html.h1([], [html.Text("Not found")])
}
