use std::collections::BTreeMap;
use std::path::PathBuf;

use schemars::JsonSchema;
use serde::{Deserialize, Serialize};
use serde_json::Value as JsonValue;

/// Parsed portion of an `info.toml` file consumed by the ABI catalog builder.
///
/// Additional TOML fields are allowed and ignored by the builder.
#[derive(Debug, Deserialize, JsonSchema)]
#[schemars(title = "ABI catalog info.toml schema")]
pub(crate) struct InfoFile {
    /// Project metadata used to namespace contract entries.
    pub(crate) project: Project,

    /// Links inherited by every contract declared in this file.
    #[serde(default)]
    pub(crate) links: Vec<Link>,

    /// Named source references used to establish data provenance.
    #[allow(dead_code)]
    #[serde(default)]
    pub(crate) sources: BTreeMap<String, String>,

    /// Contracts keyed by their project-local contract names.
    pub(crate) contracts: BTreeMap<String, Contract>,
}

/// Project identity shared by all contracts in one `info.toml` file.
#[derive(Debug, Deserialize, JsonSchema)]
#[allow(dead_code)]
pub(crate) struct Project {
    /// Stable project name used as the contract namespace.
    pub(crate) name: String,

    /// Human-readable project name when it differs from the namespace.
    pub(crate) project: Option<String>,

    /// Short description of the project and its contracts.
    pub(crate) description: Option<String>,

    /// Catalog category used to group related projects.
    pub(crate) category: Option<String>,

    /// Public project website.
    pub(crate) website: Option<String>,

    /// Public web application URL.
    pub(crate) app: Option<String>,

    /// Project documentation URL.
    pub(crate) docs: Option<String>,

    /// Source repository URL.
    pub(crate) repository: Option<String>,

    /// Telegram community or announcement channel URL.
    pub(crate) telegram: Option<String>,

    /// Security audit report URL.
    pub(crate) audit: Option<String>,
}

/// Contract fields required to compile and publish one ABI catalog entry.
///
/// Additional contract metadata and nested tables are allowed and ignored by
/// the builder.
#[derive(Debug, Deserialize, JsonSchema)]
#[allow(dead_code)]
pub(crate) struct Contract {
    /// Short description of the contract's role.
    pub(crate) description: Option<String>,

    /// Human-readable contract name; defaults to the contract table key.
    pub(crate) display_name: Option<String>,

    /// Path to the Tolk ABI interface, relative to the containing `info.toml`.
    pub(crate) types: Option<PathBuf>,

    /// Lowercase hexadecimal code hashes associated with this contract ABI.
    #[serde(default)]
    pub(crate) hashes: Vec<String>,

    /// Known friendly TON addresses that use this contract ABI.
    #[serde(default)]
    pub(crate) known_addresses: Vec<String>,

    /// Links specific to this contract.
    #[serde(default)]
    pub(crate) links: Vec<Link>,

    /// Named compatibility or interface profile implemented by the contract.
    pub(crate) profile: Option<String>,

    /// Observed deployed instances of the contract.
    #[serde(default)]
    pub(crate) instances: BTreeMap<String, Instance>,

    /// Named variants of the contract ABI or deployment.
    #[serde(default)]
    pub(crate) variants: BTreeMap<String, Variant>,
}

/// One observed on-chain contract instance and its semantic relationships.
#[derive(Debug, Deserialize, JsonSchema)]
#[allow(dead_code)]
pub(crate) struct Instance {
    /// Human-readable name of the observed instance.
    pub(crate) name: Option<String>,
    /// Short label used when a full name is unnecessary.
    pub(crate) label: Option<String>,
    /// Friendly TON account address.
    pub(crate) address: Option<String>,
    /// Lowercase hexadecimal code hash observed at the address.
    pub(crate) code_hash: Option<String>,
    /// TON network on which the instance was observed.
    pub(crate) network: Option<String>,
    /// Masterchain or shardchain block sequence number used for the observation.
    pub(crate) block_seqno: Option<u64>,
    /// Numeric item index within a collection or protocol sequence.
    pub(crate) index: Option<u64>,
    /// Human-readable lifecycle or protocol state.
    pub(crate) state: Option<String>,
    /// Pool implementation or market type.
    pub(crate) pool_type: Option<String>,
    /// Pool names associated with this instance.
    pub(crate) pools: Option<Vec<String>>,
    /// Address or identifier of the owning account.
    pub(crate) owner: Option<String>,
    /// Friendly TON address of the owning account.
    pub(crate) owner_address: Option<String>,
    /// Parent contract address or identifier.
    pub(crate) parent: Option<String>,
    /// Master contract address or identifier.
    pub(crate) master: Option<String>,
    /// Factory contract address or identifier.
    pub(crate) factory: Option<String>,
    /// Collection contract address or identifier.
    pub(crate) collection: Option<String>,
    /// Proxy contract address or identifier.
    pub(crate) proxy: Option<String>,
    /// Treasury contract address or identifier.
    pub(crate) treasury: Option<String>,
    /// Vault contract address or identifier.
    pub(crate) vault: Option<String>,
    /// Virtual automated market maker address or identifier.
    pub(crate) vamm: Option<String>,
    /// Trader account address or identifier.
    pub(crate) trader: Option<String>,
    /// Minter contract address or identifier.
    pub(crate) minter: Option<String>,
    /// Jetton minter contract address or identifier.
    pub(crate) jetton_minter: Option<String>,
    /// Lowercase hexadecimal code hash of the related jetton minter.
    pub(crate) jetton_minter_hash: Option<String>,
    /// Jetton wallet contract address or identifier.
    pub(crate) jetton_wallet: Option<String>,
    /// Financial or accounting contract address or identifier.
    pub(crate) financial: Option<String>,
    /// Underlying contract or asset address or identifier.
    pub(crate) underlying: Option<String>,
    /// Range contract address or identifier.
    pub(crate) range: Option<String>,
    /// Meme-token contract address or identifier.
    pub(crate) meme: Option<String>,
}

/// Named contract variant with its own hashes, addresses, or deployment data.
#[derive(Debug, Deserialize, JsonSchema)]
#[allow(dead_code)]
pub(crate) struct Variant {
    /// Representative friendly TON address for this variant.
    pub(crate) address: Option<String>,
    /// Lowercase hexadecimal code hash for this variant.
    pub(crate) code_hash: Option<String>,
    /// Lowercase hexadecimal code hashes associated with this variant.
    #[serde(default)]
    pub(crate) hashes: Vec<String>,
    /// Known friendly TON addresses that use this variant.
    #[serde(default)]
    pub(crate) known_addresses: Vec<String>,
    /// TON network on which the variant was observed.
    pub(crate) network: Option<String>,
}

/// External reference attached to a project or contract.
#[derive(Clone, Debug, Deserialize, Eq, JsonSchema, PartialEq, Serialize)]
pub(crate) struct Link {
    /// Reference category, such as `docs`, `source`, `spec`, or `website`.
    pub(crate) kind: String,

    /// Human-readable label shown to catalog consumers.
    pub(crate) title: String,

    /// Absolute HTTP or HTTPS URL for the referenced resource.
    pub(crate) url: String,
}

/// Deterministic public catalog produced from all compilable `info.toml`
/// contract entries.
#[derive(Debug, JsonSchema, Serialize)]
#[serde(rename_all = "camelCase")]
#[schemars(title = "Public ABI catalog schema")]
pub(crate) struct Bundle {
    /// Version of the public catalog JSON format.
    pub(crate) schema_version: u32,

    /// Compiled ABI entries sorted by their stable contract IDs.
    pub(crate) contracts: Vec<BundledContract>,
}

/// One compiled contract entry in the public ABI catalog.
#[derive(Debug, JsonSchema, Serialize)]
#[serde(rename_all = "camelCase")]
pub(crate) struct BundledContract {
    /// Stable contract identifier in `<project>.<contract>` form.
    pub(crate) id: String,

    /// Human-readable contract name.
    pub(crate) display_name: String,

    /// Sorted unique lowercase hexadecimal code hashes for this ABI.
    pub(crate) hashes: Vec<String>,

    /// Sorted unique friendly TON addresses known to use this ABI.
    pub(crate) known_addresses: Vec<String>,

    /// Sorted unique project and contract references.
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub(crate) links: Vec<Link>,

    /// Compiler-generated ABI JSON emitted by `acton compile --abi`.
    pub(crate) compiler_abi: JsonValue,
}
