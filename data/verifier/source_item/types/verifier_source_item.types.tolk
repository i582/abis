/// Immutable on-chain record connecting one verified code-cell hash to a versioned source URL.
contract VerifierSourceItem {
    author: "TON Community"
    version: "1.0"
    description: "Stores one verifier identity, verified code-cell hash, parent Sources Registry, and source-bundle location."
    storage: VerifierSourceItemStorage
    storageAtDeployment: VerifierSourceItemDeploymentStorage
    incomingMessages: VerifierSourceItemIncomingBody
    forceAbiExport: VerifierSourceItemContent | VerifierSourceItemData
    thrownErrors: VerifierSourceItemErrors
}

/// Raw snake-string tail used for an IPFS or HTTPS source location.
type VerifierSourceItemUrlTail = RemainingBitsAndRefs

/// Any non-empty internal body accepted from the parent Sources Registry.
type VerifierSourceItemIncomingBody = RemainingBitsAndRefs

/// Versioned source location accepted from the parent Sources Registry.
struct VerifierSourceItemContent {
    /// Source-content format version; deployed records currently use version 1.
    version: uint8
    /// Inline snake-encoded source URL, including any continuation-cell references.
    url: VerifierSourceItemUrlTail
}

/// StateInit data before the Sources Registry delivers the source-content body.
struct VerifierSourceItemDeploymentStorage {
    /// SHA-256 identifier of the verifier that authorized this record.
    verifierId: uint256
    /// Hash of the contract code cell whose sources were verified.
    verifiedCodeCellHash: uint256
    /// Parent Sources Registry uniquely allowed to set the content.
    sourceItemRegistry: address
}

/// Complete initialized persistent state after the deployment body is processed.
struct VerifierSourceItemStorage {
    /// SHA-256 identifier of the verifier that authorized this record.
    verifierId: uint256
    /// Hash of the contract code cell whose sources were verified.
    verifiedCodeCellHash: uint256
    /// Parent Sources Registry uniquely allowed to update the content.
    sourceItemRegistry: address
    /// Referenced versioned source-bundle location.
    content: Cell<VerifierSourceItemContent>
}

/// Stack result returned by `get_source_item_data`.
struct VerifierSourceItemData {
    /// SHA-256 identifier of the verifier that authorized this record.
    verifierId: uint256
    /// Hash of the contract code cell whose sources were verified.
    verifiedCodeCellHash: uint256
    /// Parent Sources Registry address.
    sourceItemRegistry: address
    /// Referenced versioned source-bundle location.
    content: Cell<VerifierSourceItemContent>
}

/// Return the verifier, verified code hash, parent registry, and source location.
get fun get_source_item_data(): VerifierSourceItemData {
    throw 0;
}

/// Named exit codes thrown while accepting a content body.
enum VerifierSourceItemErrors {
    /// Sender is not the parent Sources Registry stored at deployment.
    AccessDenied = 401
}
