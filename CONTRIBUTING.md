# Contributing

## Build the ABI catalog

Build the deterministic public ABI catalog at `.gen/abi-catalog.json` with:

```sh
cargo xtask bundle --pretty
```

ABI compilation runs in parallel by default. Use `--jobs N` to set an explicit limit.

## Generate JSON Schemas

Generate the tracked schemas for input `info.toml` files and the public ABI catalog with:

```sh
cargo xtask schema
```

This writes `schemas/info-toml.schema.json` and `schemas/abi-catalog.schema.json`.
Verify that both files match the current Rust types without modifying them with:

```sh
cargo xtask schema --check
```

## Run all Tolk tests

Run every tracked `*.test.tolk` file exactly once with:

```sh
acton run run-all-tests
```
