use std::env;
use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result, bail};
use clap::Args;
use schemars::{JsonSchema, schema_for};

use crate::catalog::{Bundle, InfoFile};

/// Arguments controlling JSON Schema generation.
#[derive(Debug, Args)]
pub(crate) struct SchemaArgs {
    /// Destination for the schema describing parsed `info.toml` files.
    #[arg(long, default_value = "schemas/info-toml.schema.json")]
    input: PathBuf,

    /// Destination for the schema describing the generated ABI catalog.
    #[arg(long, default_value = "schemas/abi-catalog.schema.json")]
    output: PathBuf,

    /// Verify that the tracked schemas match the Rust types without writing files.
    #[arg(long)]
    check: bool,
}

/// Generate both JSON Schema documents from the catalog Rust types.
pub(crate) fn run(args: SchemaArgs) -> Result<()> {
    let root = env::current_dir().context("failed to resolve the repository root")?;
    let input_path = resolve(&root, &args.input);
    let output_path = resolve(&root, &args.output);

    process_schema::<InfoFile>(&input_path, args.check)?;
    process_schema::<Bundle>(&output_path, args.check)?;

    let action = if args.check { "Checked" } else { "Wrote" };
    eprintln!("{action} {}", display_path(&root, &input_path));
    eprintln!("{action} {}", display_path(&root, &output_path));
    Ok(())
}

/// Serialize one Rust type's JSON Schema with stable pretty formatting.
fn process_schema<T: JsonSchema>(path: &Path, check: bool) -> Result<()> {
    let parent = path
        .parent()
        .context("schema output path has no parent directory")?;
    fs::create_dir_all(parent).with_context(|| format!("failed to create {}", parent.display()))?;

    let schema = schema_for!(T);
    let mut json = serde_json::to_vec_pretty(&schema).context("failed to serialize JSON Schema")?;
    json.push(b'\n');

    if check {
        let existing = fs::read(path)
            .with_context(|| format!("failed to read tracked schema {}", path.display()))?;
        if existing != json {
            bail!(
                "schema is out of date: {}; run `cargo xtask schema`",
                path.display()
            );
        }
        return Ok(());
    }

    fs::write(path, json).with_context(|| format!("failed to write {}", path.display()))
}

/// Resolve a command-line path relative to the repository root.
fn resolve(root: &Path, path: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_owned()
    } else {
        root.join(path)
    }
}

/// Format a path relative to the repository root for CLI diagnostics.
fn display_path(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}

#[cfg(test)]
mod tests {
    use serde_json::Value;

    use super::*;

    /// Convert a generated schema to JSON so descriptions can be asserted.
    fn schema_json<T: JsonSchema>() -> Value {
        serde_json::to_value(schema_for!(T)).unwrap()
    }

    /// Assert that every object and named object property carries documentation.
    fn assert_all_described(value: &Value, path: &str) {
        match value {
            Value::Object(object) => {
                if object.contains_key("properties") {
                    assert!(
                        object.get("description").is_some_and(Value::is_string),
                        "object schema at {path} has no description"
                    );
                }

                if let Some(Value::Object(properties)) = object.get("properties") {
                    for (name, property) in properties {
                        assert!(
                            property.get("description").is_some_and(Value::is_string),
                            "property {path}.{name} has no description"
                        );
                    }
                }

                for (name, child) in object {
                    assert_all_described(child, &format!("{path}.{name}"));
                }
            }
            Value::Array(items) => {
                for (index, child) in items.iter().enumerate() {
                    assert_all_described(child, &format!("{path}[{index}]"));
                }
            }
            _ => {}
        }
    }

    #[test]
    fn input_schema_contains_type_and_field_descriptions() {
        let schema = schema_json::<InfoFile>();
        assert!(schema["description"].is_string());
        assert!(schema["properties"]["project"]["description"].is_string());
        assert!(schema["$defs"]["Project"]["description"].is_string());
        assert!(schema["$defs"]["Project"]["properties"]["name"]["description"].is_string());
    }

    #[test]
    fn output_schema_contains_type_and_field_descriptions() {
        let schema = schema_json::<Bundle>();
        assert!(schema["description"].is_string());
        assert!(schema["properties"]["schemaVersion"]["description"].is_string());
        assert!(schema["$defs"]["BundledContract"]["description"].is_string());
        assert!(
            schema["$defs"]["BundledContract"]["properties"]["compilerAbi"]["description"]
                .is_string()
        );
    }

    #[test]
    fn every_input_type_and_field_is_documented() {
        assert_all_described(&schema_json::<InfoFile>(), "InfoFile");
    }

    #[test]
    fn every_output_type_and_field_is_documented() {
        assert_all_described(&schema_json::<Bundle>(), "Bundle");
    }
}
