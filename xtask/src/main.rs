mod bundle;
mod catalog;
mod schema;

use anyhow::Result;
use clap::{Parser, Subcommand};

/// Command-line interface for repository maintenance tasks.
#[derive(Debug, Parser)]
#[command(name = "xtask", about = "Repository maintenance tasks")]
struct Cli {
    /// Repository task to execute.
    #[command(subcommand)]
    command: Command,
}

/// Repository maintenance tasks exposed through `cargo xtask`.
#[derive(Debug, Subcommand)]
enum Command {
    /// Compile catalog interfaces and build the public ABI bundle.
    Bundle(bundle::BundleArgs),

    /// Generate JSON Schemas for info.toml and the public ABI catalog.
    Schema(schema::SchemaArgs),
}

fn main() -> Result<()> {
    match Cli::parse().command {
        Command::Bundle(args) => bundle::run(args),
        Command::Schema(args) => schema::run(args),
    }
}
