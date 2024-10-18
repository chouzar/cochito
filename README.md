# cochito

[![Package Version](https://img.shields.io/hexpm/v/cochito)](https://hex.pm/packages/cochito)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cochito/)

To run the from `localhost` port `8088`:

```sh
gleam run
```

To get precompiled erlang suitable for deployment:

```sh
gleam export erlang-shipment
```

## Architecture

Currently the whole server just sits as a single file at `src/cochito.gleam`, these are the main libraries being used:

* [Gleam standard library](https://hexdocs.pm/gleam_stdlib/), basic structs and functions.
* [Gleam Erlang](https://hexdocs.pm/gleam_erlang/), access to processes, nodes, ports, etc.
* [Gleam OTP](https://hexdocs.pm/gleam_otp/), OTP primitives (task, actor and supervisor).
* [mist](https://hexdocs.pm/mist/), basic API for a web server.
