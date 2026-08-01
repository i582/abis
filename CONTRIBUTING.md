# Contributing

Thanks for helping improve the catalog.

Changes should be reproducible, backed by public provenance or fixtures, and
safe for downstream tools that consume stable contract IDs and compiler ABIs.

## Useful references

- Project overview: [README.md](README.md)
- Release process: [RELEASING.md](RELEASING.md)
- Production readiness: [docs/production-readiness.md](docs/production-readiness.md)

## Prerequisites

- Rust and Cargo
- Acton
- `TONCENTER_MAINNET_API_KEY` for reliable mainnet fork tests

Run commands from the repository root.

## Build the ABI catalog

Build the deterministic public ABI catalog at `.gen/abi-catalog.json` with:

```sh
cargo xtask bundle --pretty
```

ABI compilation runs in parallel by default. Use `--jobs N` to set an explicit
limit.

## Generate JSON Schemas

Generate the tracked schemas for input `info.toml` files and the public ABI
catalog with:

```sh
cargo xtask schema
```

This writes `schemas/info-toml.schema.json` and
`schemas/abi-catalog.schema.json`.

Verify that both files match the current Rust types without modifying them:

```sh
cargo xtask schema --check
```

Commit schema changes together with the Rust type change that produced them.

## Run checks

Run the local checks used by CI:

```sh
cargo fmt --all -- --check
cargo check --workspace --all-targets --locked
cargo clippy --workspace --all-targets --all-features --locked -- -D warnings
cargo test --workspace --all-features --locked
cargo xtask schema --check
acton build
acton fmt --check
acton check --output-format github
```

Run every tracked `*.test.tolk` file exactly once with:

```sh
acton run run-all-tests
```

To run one CI shard:

```sh
acton run run-test-shard-1
```

The four shards require network access because they include mainnet fork tests.

## Catalog changes

For a new or updated contract entry:

1. Edit the appropriate `data/**/info.toml`.
2. Keep the stable ID in `<project.name>.<contract-key>` form.
3. Add or update the Tolk ABI interface referenced by `types`.
4. Add immutable public provenance under `[sources]` and structured `links`.
5. Add verified lowercase hexadecimal code hashes and friendly
   `known_addresses` when available.
6. Add repeatable fixtures and tests. Pin mainnet fork tests to a block.
7. Regenerate schemas only if Rust schema types changed.
8. Build the catalog and run the relevant tests before opening a pull request.

Do not add local paths to `[sources]`, runtime transaction snapshots, API keys,
wallet credentials, or research-only fields to public catalog metadata.

## Pull requests

- Keep unrelated catalog and tooling changes in separate commits when
  practical.
- Explain the provenance and verification method for ABI or hash changes.
- Call out stable-ID, schema, or compatibility changes explicitly.
- Update `CHANGELOG.md` for user-visible changes.
- Do not weaken tests, lint rules, or warning budgets to make CI pass.

By contributing, you agree that your contribution is licensed under the
[MIT License](LICENSE).
