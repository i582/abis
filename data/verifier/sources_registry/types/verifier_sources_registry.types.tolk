/// On-chain TON source registry that deploys immutable source records authorized by a verifier registry.
contract VerifierSourcesRegistry {
    author: "TON Community"
    version: "1.0"
    description: "Stores verifier and deployment configuration, derives Source Item addresses, and deploys on-chain source records."
    storage: VerifierSourcesRegistryStorage
    incomingMessages: VerifierSourcesRegistryIncomingMessage
    outgoingMessages: VerifierSourceContent
    forceAbiExport: VerifierAuthenticatedIdentity
        | VerifierSourcesRegistryForwardedEnvelope
        | VerifierSourcesRegistryDeploymentCosts
    thrownErrors: VerifierSourcesRegistryErrors
}

/// Raw snake-string tail used for IPFS or HTTPS source locations.
type VerifierSourceUrlTail = RemainingBitsAndRefs

/// Versioned source location stored in a Source Item and sent as its deployment body.
struct VerifierSourceContent {
    /// Source-content format version; deployed records currently use version 1.
    version: uint8
    /// Inline snake-encoded source URL, including any continuation-cell references.
    url: VerifierSourceUrlTail
}

/// Complete persistent state of the Sources Registry.
struct VerifierSourcesRegistryStorage {
    /// Minimum TON value accepted for deploying a Source Item, in nanotons.
    minGram: coins
    /// Maximum TON value accepted for deploying a Source Item, in nanotons.
    maxGram: coins
    /// Administrator allowed to replace code and configuration.
    adminAddress: address
    /// Verifier Registry whose forwarded signatures authorize Source Item deployment.
    verifierRegistryAddress: address
    /// Exact code cell installed in newly deployed Source Items.
    sourceItemCode: cell
}

/// Verifier identity attached by the Verifier Registry to a forwarded message.
struct VerifierAuthenticatedIdentity {
    /// SHA-256 identifier of the verifier that authorized the payload.
    verifierId: uint256
}

/// Two-reference envelope delivered by the Verifier Registry to the Sources Registry.
struct VerifierSourcesRegistryForwardedEnvelope {
    /// Referenced authenticated verifier identifier.
    verifierIdentity: Cell<VerifierAuthenticatedIdentity>
    /// Referenced deployment payload signed by that verifier.
    forwardedMessage: Cell<VerifierSourcesRegistryDeploySourceItemPayload>
}

/// Deploy a Source Item for a verified code-cell hash.
struct (0x000003ea) VerifierSourcesRegistryDeploySourceItemPayload {
    /// Correlation identifier supplied by the verification client.
    queryId: uint64
    /// SHA-256 identifier of the verifier authorizing this record.
    verifierId: uint256
    /// Hash of the contract code cell whose sources were verified.
    verifiedCodeCellHash: uint256
    /// Referenced versioned URL of the verified source bundle.
    sourceContent: Cell<VerifierSourceContent>
}

/// Replace the Verifier Registry trusted to forward authenticated deployments.
struct (0x000007d3) VerifierSourcesRegistryChangeVerifierRegistry {
    /// Correlation identifier supplied by the administrator.
    queryId: uint64
    /// New trusted Verifier Registry address.
    newVerifierRegistry: address
}

/// Transfer Sources Registry administration.
struct (0x00000bbc) VerifierSourcesRegistryChangeAdmin {
    /// Correlation identifier supplied by the administrator.
    queryId: uint64
    /// New administrator address.
    newAdmin: address
}

/// Replace the code cell used for future Source Item deployments.
struct (0x00000fa5) VerifierSourcesRegistrySetSourceItemCode {
    /// Correlation identifier supplied by the administrator.
    queryId: uint64
    /// Referenced Source Item code installed in future StateInit cells.
    newSourceItemCode: cell
}

/// Schedule replacement of the Sources Registry's own code.
struct (0x0000138e) VerifierSourcesRegistrySetCode {
    /// Correlation identifier supplied by the administrator.
    queryId: uint64
    /// Referenced replacement code cell.
    newCode: cell
}

/// Update the accepted TON range for Source Item deployment.
struct (0x00001777) VerifierSourcesRegistrySetDeploymentCosts {
    /// Correlation identifier supplied by the administrator.
    queryId: uint64
    /// New minimum accepted deployment value, in nanotons.
    newMinGram: coins
    /// New maximum accepted deployment value, in nanotons.
    newMaxGram: coins
}

/// Opcode-bearing payloads interpreted by the Sources Registry.
type VerifierSourcesRegistryIncomingMessage =
    | VerifierSourcesRegistryDeploySourceItemPayload
    | VerifierSourcesRegistryChangeVerifierRegistry
    | VerifierSourcesRegistryChangeAdmin
    | VerifierSourcesRegistrySetSourceItemCode
    | VerifierSourcesRegistrySetCode
    | VerifierSourcesRegistrySetDeploymentCosts

/// Minimum and maximum TON accepted for a Source Item deployment.
struct VerifierSourcesRegistryDeploymentCosts {
    /// Minimum deployment value, in nanotons.
    minGram: coins
    /// Maximum deployment value, in nanotons.
    maxGram: coins
}

/// Derive the Source Item address for one verifier and verified code hash.
get fun get_source_item_address(verifierId: int, verifiedCodeCellHash: int): address {
    throw 0;
}

/// Return the Verifier Registry trusted by this Sources Registry.
get fun get_verifier_registry_address(): address {
    throw 0;
}

/// Return the administrator allowed to change Sources Registry configuration.
get fun get_admin_address(): address {
    throw 0;
}

/// Return the accepted Source Item deployment-value range.
get fun get_deployment_costs(): VerifierSourcesRegistryDeploymentCosts {
    throw 0;
}

/// Named exit codes thrown by the Sources Registry dispatcher.
enum VerifierSourcesRegistryErrors {
    /// Caller is not the configured administrator.
    AccessDenied = 401
    /// Payload verifier identifier differs from the authenticated forwarded identifier.
    VerifierIdMismatch = 402
    /// Attached TON value is below the configured or protocol minimum.
    NotEnoughValue = 900
    /// Attached TON value exceeds the configured maximum.
    TooMuchValue = 901
    /// Replacement code cell is empty.
    InvalidCellCode = 902
    /// Deployment-cost bounds are inconsistent or below the protocol minimum.
    InvalidValue = 903
    /// Message opcode is not recognized.
    UnknownOperation = 65535
}
