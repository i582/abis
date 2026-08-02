use std::collections::HashSet;
use std::env;
use std::ffi::OsStr;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc;
use std::thread;

use anyhow::{Context, Result, bail};
use clap::Args;
use serde_json::Value as JsonValue;
use tempfile::{NamedTempFile, tempdir};
use walkdir::WalkDir;

use crate::catalog::{Bundle, BundledContract, InfoFile, Link};

const BUNDLE_SCHEMA_VERSION: u32 = 1;

/// Arguments controlling ABI catalog generation.
#[derive(Debug, Args)]
pub struct BundleArgs {
    /// Directory scanned recursively for info.toml files.
    #[arg(long, default_value = "data")]
    data: PathBuf,

    /// Destination JSON file.
    #[arg(short, long, default_value = ".gen/abi-catalog.json")]
    out: PathBuf,

    /// Acton executable used to compile Tolk interface files.
    #[arg(long, env = "ACTON_BIN", default_value = "acton")]
    acton: PathBuf,

    /// Pretty-print the output JSON.
    #[arg(long)]
    pretty: bool,

    /// Maximum number of concurrent Acton compiler processes.
    #[arg(short = 'j', long, value_name = "N")]
    jobs: Option<usize>,
}

/// Fully resolved source data needed to compile one contract ABI.
#[derive(Debug)]
struct ContractSource {
    /// Stable catalog identifier in `<project>.<contract>` form.
    id: String,

    /// Human-readable contract name.
    display_name: String,

    /// Validated code hashes associated with this ABI.
    hashes: Vec<String>,

    /// Known friendly addresses associated with this ABI.
    known_addresses: Vec<String>,

    /// Project-level and contract-level external references.
    links: Vec<Link>,

    /// Absolute path to the Tolk ABI interface.
    types_path: PathBuf,

    /// Absolute path to the declaring `info.toml`, used in diagnostics.
    info_path: PathBuf,
}

/// Failure reported by one parallel Acton compiler worker.
#[derive(Debug)]
struct CompileFailure {
    /// Stable catalog identifier of the failed contract.
    id: String,

    /// ABI interface passed to Acton.
    types_path: PathBuf,

    /// Declaring `info.toml`, used to locate the source entry.
    info_path: PathBuf,

    /// Process output when Acton started but returned unsuccessfully.
    output: Option<Output>,

    /// Launch or I/O error when Acton could not produce process output.
    error: Option<anyhow::Error>,
}

pub fn run(args: BundleArgs) -> Result<()> {
    let root = env::current_dir().context("failed to resolve the repository root")?;
    let data_dir = resolve(&root, &args.data);
    let out_path = resolve(&root, &args.out);

    if !data_dir.is_dir() {
        bail!(
            "data directory does not exist: {}",
            display_path(&root, &data_dir)
        );
    }

    let (contracts, skipped) = load_contracts(&root, &data_dir)?;
    let jobs = effective_jobs(args.jobs, contracts.len())?;
    eprintln!(
        "Compiling {} ABI sources with {jobs} parallel job(s)",
        contracts.len()
    );
    let bundle = compile_bundle(&root, &args.acton, contracts, jobs)?;
    let mut json = if args.pretty {
        serde_json::to_vec_pretty(&bundle)
    } else {
        serde_json::to_vec(&bundle)
    }
    .context("failed to serialize ABI bundle")?;
    json.push(b'\n');

    write_atomic(&out_path, &json)?;
    update_readme_stats(&root, &bundle)?;

    eprintln!(
        "Wrote {} ({} contracts, {} bytes)",
        display_path(&root, &out_path),
        bundle.contracts.len(),
        json.len()
    );
    if skipped > 0 {
        eprintln!("Skipped {skipped} catalog entries without a types field");
    }

    Ok(())
}

fn update_readme_stats(root: &Path, bundle: &Bundle) -> Result<()> {
    let readme_path = root.join("README.md");
    let readme = fs::read_to_string(&readme_path)
        .with_context(|| format!("failed to read {}", display_path(root, &readme_path)))?;

    let mut hashes = HashSet::new();
    let mut addresses = HashSet::new();
    let mut opcode_prefixes = HashSet::new();
    let mut get_methods = HashSet::new();

    for contract in &bundle.contracts {
        hashes.extend(contract.hashes.iter().cloned());
        addresses.extend(contract.known_addresses.iter().cloned());

        if let Some(declarations) = contract
            .compiler_abi
            .get("declarations")
            .and_then(JsonValue::as_array)
        {
            for declaration in declarations {
                if let Some(prefix) = declaration.get("prefix") {
                    opcode_prefixes.insert(prefix.to_string());
                }
            }
        }

        if let Some(methods) = contract
            .compiler_abi
            .get("get_methods")
            .and_then(JsonValue::as_array)
        {
            for method in methods {
                if let Some(name) = method.get("name").and_then(JsonValue::as_str) {
                    get_methods.insert(name.to_owned());
                }
            }
        }
    }

    let catalog_line = format!(
        "Current catalog size: **{} contract entries**, **{} unique contract code hashes**, and **{} unique known contract addresses**.",
        bundle.contracts.len(),
        hashes.len(),
        addresses.len(),
    );
    let abi_line = format!(
        "Across the generated public catalog, the repository declares **{} unique opcode prefixes** and **{} unique get-method names**.",
        opcode_prefixes.len(),
        get_methods.len(),
    );

    let mut replaced_catalog = false;
    let mut replaced_abi = false;
    let updated = readme
        .lines()
        .map(|line| {
            if line.starts_with("Current catalog size:") {
                replaced_catalog = true;
                catalog_line.as_str()
            } else if line.starts_with("Across the generated public catalog,") {
                replaced_abi = true;
                abi_line.as_str()
            } else {
                line
            }
        })
        .collect::<Vec<_>>()
        .join("\n")
        + "\n";

    if !replaced_catalog || !replaced_abi {
        bail!("README.md does not contain the catalog statistics markers");
    }

    write_atomic(&readme_path, updated.as_bytes())?;
    eprintln!("Updated README.md catalog statistics");
    Ok(())
}

fn load_contracts(root: &Path, data_dir: &Path) -> Result<(Vec<ContractSource>, usize)> {
    let mut info_paths = WalkDir::new(data_dir)
        .follow_links(false)
        .into_iter()
        .filter_map(|entry| match entry {
            Ok(entry)
                if entry.file_type().is_file() && entry.file_name() == OsStr::new("info.toml") =>
            {
                Some(Ok(entry.into_path()))
            }
            Ok(_) => None,
            Err(error) => Some(Err(error)),
        })
        .collect::<Result<Vec<_>, _>>()
        .context("failed to scan data directory")?;
    info_paths.sort();

    let mut contracts = Vec::new();
    let mut ids = HashSet::new();
    let mut skipped = 0;

    for info_path in info_paths {
        let contents = fs::read_to_string(&info_path)
            .with_context(|| format!("failed to read {}", display_path(root, &info_path)))?;
        let info: InfoFile = toml::from_str(&contents)
            .with_context(|| format!("failed to parse {}", display_path(root, &info_path)))?;
        require_non_empty(&info.project.name, "project.name", root, &info_path)?;

        let info_dir = info_path
            .parent()
            .context("info.toml has no parent directory")?;

        for (name, contract) in info.contracts {
            let id = format!("{}.{}", info.project.name, name);
            if !ids.insert(id.clone()) {
                bail!("duplicate contract id {id}");
            }

            let Some(types) = contract.types else {
                skipped += 1;
                continue;
            };

            let types_path = info_dir.join(types);
            if !types_path.is_file() {
                bail!(
                    "types file for {id} does not exist: {}",
                    display_path(root, &types_path)
                );
            }

            let mut hashes = contract.hashes;
            for hash in &hashes {
                validate_hash(hash, &id)?;
            }
            sort_dedup(&mut hashes);

            let mut known_addresses = contract.known_addresses;
            known_addresses.retain(|address| !address.trim().is_empty());
            sort_dedup(&mut known_addresses);

            let mut links = info.links.clone();
            links.extend(contract.links);
            for link in &links {
                validate_link(link, &id)?;
            }
            links.sort_by(|left, right| {
                (&left.kind, &left.url, &left.title).cmp(&(&right.kind, &right.url, &right.title))
            });
            links.dedup();

            contracts.push(ContractSource {
                id,
                display_name: contract.display_name.unwrap_or(name),
                hashes,
                known_addresses,
                links,
                types_path,
                info_path: info_path.clone(),
            });
        }
    }

    contracts.sort_by(|left, right| left.id.cmp(&right.id));
    Ok((contracts, skipped))
}

fn compile_bundle(
    root: &Path,
    acton: &Path,
    contracts: Vec<ContractSource>,
    jobs: usize,
) -> Result<Bundle> {
    let temp_dir = tempdir().context("failed to create temporary ABI directory")?;
    let mut bundled = Vec::with_capacity(contracts.len());
    let mut failures = Vec::new();

    let next_index = AtomicUsize::new(0);
    let mut results = thread::scope(|scope| {
        let (sender, receiver) = mpsc::channel();

        for _ in 0..jobs {
            let sender = sender.clone();
            let contracts = &contracts;
            let next_index = &next_index;
            let temp_path = temp_dir.path();

            scope.spawn(move || {
                loop {
                    let index = next_index.fetch_add(1, Ordering::Relaxed);
                    let Some(contract) = contracts.get(index) else {
                        break;
                    };
                    let result = compile_contract(root, acton, temp_path, index, contract);
                    if sender.send((index, result)).is_err() {
                        break;
                    }
                }
            });
        }

        drop(sender);
        receiver.into_iter().collect::<Vec<_>>()
    });

    results.sort_by_key(|(index, _)| *index);
    for (_, result) in results {
        match result {
            Ok(contract) => bundled.push(contract),
            Err(failure) => failures.push(*failure),
        }
    }

    if !failures.is_empty() {
        bail!(format_failures(root, &failures));
    }

    Ok(Bundle {
        schema_version: BUNDLE_SCHEMA_VERSION,
        contracts: bundled,
    })
}

fn compile_contract(
    root: &Path,
    acton: &Path,
    temp_dir: &Path,
    index: usize,
    contract: &ContractSource,
) -> std::result::Result<BundledContract, Box<CompileFailure>> {
    let abi_path = temp_dir.join(format!("{index}.json"));
    let result = Command::new(acton)
        .arg("compile")
        .arg(&contract.types_path)
        .arg("--allow-no-entrypoint")
        .arg("--abi")
        .arg(&abi_path)
        .arg("--base64-only")
        .arg("--color")
        .arg("never")
        .current_dir(root)
        .env("NO_COLOR", "1")
        .output();

    let output = match result {
        Ok(output) if output.status.success() => output,
        Ok(output) => return Err(compile_failure(contract, Some(output), None)),
        Err(error) => return Err(compile_failure(contract, None, Some(error.into()))),
    };

    if !abi_path.is_file() {
        return Err(compile_failure(
            contract,
            Some(output),
            Some(anyhow::anyhow!("Acton did not produce an ABI file")),
        ));
    }

    let compiler_abi = read_json(&abi_path)
        .map_err(|error| compile_failure(contract, Some(output), Some(error)))?;

    Ok(BundledContract {
        id: contract.id.clone(),
        display_name: contract.display_name.clone(),
        hashes: contract.hashes.clone(),
        known_addresses: contract.known_addresses.clone(),
        links: contract.links.clone(),
        compiler_abi,
    })
}

fn compile_failure(
    contract: &ContractSource,
    output: Option<Output>,
    error: Option<anyhow::Error>,
) -> Box<CompileFailure> {
    Box::new(CompileFailure {
        id: contract.id.clone(),
        types_path: contract.types_path.clone(),
        info_path: contract.info_path.clone(),
        output,
        error,
    })
}

fn effective_jobs(requested: Option<usize>, task_count: usize) -> Result<usize> {
    if requested == Some(0) {
        bail!("--jobs must be greater than zero");
    }

    let available = thread::available_parallelism()
        .map(usize::from)
        .unwrap_or(1);
    Ok(requested.unwrap_or(available).min(task_count.max(1)))
}

fn read_json(path: &Path) -> Result<JsonValue> {
    let contents = fs::read(path).with_context(|| format!("failed to read {}", path.display()))?;
    serde_json::from_slice(&contents).with_context(|| format!("invalid JSON in {}", path.display()))
}

fn write_atomic(path: &Path, contents: &[u8]) -> Result<()> {
    let parent = path
        .parent()
        .context("bundle output path has no parent directory")?;
    fs::create_dir_all(parent).with_context(|| format!("failed to create {}", parent.display()))?;

    let mut temp = NamedTempFile::new_in(parent)
        .with_context(|| format!("failed to create temporary file in {}", parent.display()))?;
    temp.write_all(contents)
        .context("failed to write temporary bundle")?;
    temp.as_file_mut()
        .sync_all()
        .context("failed to flush temporary bundle")?;
    temp.persist(path)
        .map_err(|error| error.error)
        .with_context(|| format!("failed to replace {}", path.display()))?;
    Ok(())
}

fn validate_hash(hash: &str, id: &str) -> Result<()> {
    if hash.len() != 64 || !hash.bytes().all(|byte| byte.is_ascii_hexdigit()) {
        bail!("invalid code hash for {id}: {hash}");
    }
    if hash.bytes().any(|byte| byte.is_ascii_uppercase()) {
        bail!("code hash for {id} must use lowercase hex: {hash}");
    }
    Ok(())
}

fn validate_link(link: &Link, id: &str) -> Result<()> {
    require_value(&link.kind, "link.kind", id)?;
    require_value(&link.title, "link.title", id)?;
    require_value(&link.url, "link.url", id)?;
    if !(link.url.starts_with("https://") || link.url.starts_with("http://")) {
        bail!("link.url for {id} must be an HTTP(S) URL: {}", link.url);
    }
    Ok(())
}

fn require_value(value: &str, field: &str, id: &str) -> Result<()> {
    if value.trim().is_empty() {
        bail!("{field} for {id} must not be empty");
    }
    Ok(())
}

fn require_non_empty(value: &str, field: &str, root: &Path, info_path: &Path) -> Result<()> {
    if value.trim().is_empty() {
        bail!(
            "{field} must not be empty in {}",
            display_path(root, info_path)
        );
    }
    Ok(())
}

fn sort_dedup(values: &mut Vec<String>) {
    values.sort();
    values.dedup();
}

fn resolve(root: &Path, path: &Path) -> PathBuf {
    if path.is_absolute() {
        path.to_owned()
    } else {
        root.join(path)
    }
}

fn display_path(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}

fn format_failures(root: &Path, failures: &[CompileFailure]) -> String {
    let mut message = format!("failed to compile {} ABI source(s)", failures.len());

    for failure in failures {
        message.push_str(&format!(
            "\n\n- {}\n  types: {}\n  info: {}",
            failure.id,
            display_path(root, &failure.types_path),
            display_path(root, &failure.info_path)
        ));

        if let Some(output) = &failure.output {
            message.push_str(&format!("\n  exit status: {}", output.status));
            append_output(&mut message, "stderr", &output.stderr);
            append_output(&mut message, "stdout", &output.stdout);
        }
        if let Some(error) = &failure.error {
            message.push_str(&format!("\n  error: {error:#}"));
        }
    }

    message
}

fn append_output(message: &mut String, label: &str, output: &[u8]) {
    let value = String::from_utf8_lossy(output);
    let value = value.trim();
    if value.is_empty() {
        return;
    }

    let truncated = value.chars().take(4_000).collect::<String>();
    message.push_str(&format!("\n  {label}:\n"));
    for line in truncated.lines() {
        message.push_str("    ");
        message.push_str(line);
        message.push('\n');
    }
    if value.chars().count() > 4_000 {
        message.push_str("    ... truncated ...\n");
    }
    while message.ends_with('\n') {
        message.pop();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sorts_and_deduplicates_values() {
        let mut values = vec!["b".to_owned(), "a".to_owned(), "b".to_owned()];
        sort_dedup(&mut values);
        assert_eq!(values, ["a", "b"]);
    }

    #[test]
    fn validates_lowercase_code_hashes() {
        let valid = "a".repeat(64);
        let uppercase = "A".repeat(64);
        assert!(validate_hash(&valid, "test.Contract").is_ok());
        assert!(validate_hash(&uppercase, "test.Contract").is_err());
        assert!(validate_hash("abc", "test.Contract").is_err());
    }

    #[test]
    fn validates_http_links() {
        let valid = Link {
            kind: "docs".to_owned(),
            title: "Docs".to_owned(),
            url: "https://example.com/docs".to_owned(),
        };
        let invalid = Link {
            url: "docs/readme.md".to_owned(),
            ..valid.clone()
        };
        assert!(validate_link(&valid, "test.Contract").is_ok());
        assert!(validate_link(&invalid, "test.Contract").is_err());
    }

    #[test]
    fn caps_parallel_jobs_to_the_task_count() {
        assert_eq!(effective_jobs(Some(8), 3).unwrap(), 3);
        assert_eq!(effective_jobs(Some(1), 3).unwrap(), 1);
        assert!(effective_jobs(Some(0), 3).is_err());
    }
}
