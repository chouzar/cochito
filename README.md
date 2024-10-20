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

After exporting files for release and preparing the package version for [DeployEx](https://github.com/thiagoesteves/deployex), run the following commands if testing locally:
```sh
export app_name=cochito
export release_path=erlang-shipment
cd build
tar -czvf ${release_path}/${app_name}-0.1.0.tar.gz ${release_path}
cp ${release_path}/${app_name}-0.1.0.tar.gz /tmp/${app_name}/dist/${app_name}
echo "{\"version\":\"0.1.0\",\"pre_commands\": [],\"hash\":\"local\"}" | jq > /tmp/${app_name}/versions/${app_name}/local/current.json
```

## Architecture

Currently the whole server just sits as a single file at `src/cochito.gleam`, these are the main libraries being used:

* [Gleam standard library](https://hexdocs.pm/gleam_stdlib/), basic structs and functions.
* [Gleam Erlang](https://hexdocs.pm/gleam_erlang/), access to processes, nodes, ports, etc.
* [Gleam OTP](https://hexdocs.pm/gleam_otp/), primitives for task, actor and supervisor.
* [mist](https://hexdocs.pm/mist/), a Gleam web server.
* [Gleam HTTP](https://hexdocs.pm/gleam_http/gleam/http.html), composable http middleware.
* [nakai](https://hexdocs.pm/nakai/), generate HTML through Gleam.
