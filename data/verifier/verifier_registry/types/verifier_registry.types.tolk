/// On-chain registry of source verifiers and their signature-validation settings.
contract VerifierRegistry {
    author: "TON Community"
    version: "1.0"
    description: "Registers verifier administrators and public keys, validates signed forwarding requests, and relays authenticated payloads."
    storage: VerifierRegistryStorage
    incomingMessages: VerifierRegistryIncomingMessage
    outgoingMessages: VerifierRegistryForwardedEnvelope
    forceAbiExport: VerifierRegistrySignatureItem
        | VerifierRegistryMessageDescription
        | VerifierRegistryAuthenticatedIdentity
        | VerifierRegistryTextComment
        | VerifierRegistryVerifiersMap
        | VerifierRegistryInfo
    thrownErrors: VerifierRegistryErrors
}

/// One Ed25519 signature in the custom linked list attached to a forwarding request.
struct VerifierRegistrySignatureItem {
    /// Ed25519 signature over the hash of the referenced message description.
    signature: bits512
    /// Public key that produced the signature.
    pubKey: uint256
    /// Continuation trailer: nonterminal nodes contain one next-node ref; terminal nodes are empty.
    next: RemainingBitsAndRefs
}

/// Authenticated message that a verifier asks the registry to relay.
@overflow1023_policy("suppress")
struct VerifierRegistryMessageDescription {
    /// SHA-256 identifier of the verifier whose keys authorize the request.
    verifierId: uint256
    /// Unix timestamp after which the signatures are rejected.
    validUntil: uint32
    /// Internal sender address required to submit the forwarding request.
    sourceAddr: any_address
    /// Destination that receives the authenticated two-reference envelope.
    targetAddr: any_address
    /// Referenced protocol-specific payload forwarded unchanged.
    msg: cell
}

/// Signature policy and public metadata for one verifier.
struct VerifierRegistrySettings {
    /// Number of distinct valid signatures required to relay a message.
    multiSigThreshold: uint8
    /// Public keys mapped to verifier-specific endpoint identifiers.
    pubKeyEndpoints: map<uint256, uint32>
    /// Referenced verifier name string.
    name: string
    /// Referenced verifier marketing URL string.
    marketingUrl: string
}

/// Stored administrator and settings of one registered verifier.
struct VerifierRegistryVerifier {
    /// Address authorized to update or remove this verifier.
    admin: address
    /// Signature policy and public metadata.
    settings: VerifierRegistrySettings
}

/// Complete persistent state of the Verifier Registry.
struct VerifierRegistryStorage {
    /// Verifier identifiers mapped to administrators and settings.
    verifiers: map<uint256, VerifierRegistryVerifier>
    /// Cached number of entries in `verifiers`.
    verifiersNum: uint8
}

/// Dictionary-only slice returned by `get_verifiers`.
struct VerifierRegistryVerifiersMap {
    /// Verifier identifiers mapped to administrators and settings.
    verifiers: map<uint256, VerifierRegistryVerifier>
}

/// Submit an authenticated message and linked-list signatures for forwarding.
struct (0x75217758) VerifierRegistryForwardMessage {
    /// Correlation identifier supplied by the verification client.
    queryId: uint64
    /// Referenced verifier identity, expiry, source, target, and payload.
    msg: Cell<VerifierRegistryMessageDescription>
    /// Referenced first node of the signature linked list.
    signatures: Cell<VerifierRegistrySignatureItem>
}

/// Register a verifier or replace its signature settings.
struct (0x6002d61a) VerifierRegistryUpdateVerifier {
    /// Correlation identifier supplied by the verifier administrator.
    queryId: uint64
    /// SHA-256 identifier of the verifier name.
    verifierId: uint256
    /// New verifier signature policy and metadata.
    settings: VerifierRegistrySettings
}

/// Remove a verifier and return its stake minus the exit fee.
struct (0x19fa5637) VerifierRegistryRemoveVerifier {
    /// Correlation identifier supplied by the verifier administrator.
    queryId: uint64
    /// Identifier of the verifier to remove.
    id: uint256
}

/// Opcode-bearing requests accepted by the Verifier Registry.
type VerifierRegistryIncomingMessage =
    | VerifierRegistryForwardMessage
    | VerifierRegistryUpdateVerifier
    | VerifierRegistryRemoveVerifier

/// Verifier identity attached to every successfully forwarded payload.
struct VerifierRegistryAuthenticatedIdentity {
    /// SHA-256 identifier of the verifier whose signatures were accepted.
    verifierId: uint256
}

/// Prefix-free two-reference body sent to the requested target contract.
struct VerifierRegistryForwardedEnvelope {
    /// Referenced authenticated verifier identity.
    verifierIdentity: Cell<VerifierRegistryAuthenticatedIdentity>
    /// Referenced protocol-specific payload forwarded unchanged.
    payload: cell
}

/// Opcode-zero status comment returned on registration, update, or removal.
struct (0x00000000) VerifierRegistryTextComment {
    /// Inline UTF-8 status text.
    text: RemainingBitsAndRefs
}

/// Stack result returned by `get_verifier`.
struct VerifierRegistryInfo {
    /// Verifier administrator; absent ids return an empty stack slice, so inspect `found` first.
    admin: any_address
    /// Referenced settings cell, empty when the id is absent.
    settings: Cell<VerifierRegistrySettings>
    /// True when the verifier identifier exists in storage.
    found: bool
}

/// Return one verifier's administrator and settings, plus an existence flag.
get fun get_verifier(id: int): VerifierRegistryInfo {
    throw 0;
}

/// Return the cached number of registered verifiers.
get fun get_verifiers_num(): int {
    throw 0;
}

/// Return a slice containing the verifier dictionary.
///
/// The on-chain getter returns a TVM slice, not a cell. Callers can decode it
/// with `VerifierRegistryVerifiersMap.fromSlice` when they need typed entries.
get fun get_verifiers(): slice {
    throw 0;
}

/// Named exit codes thrown by the Verifier Registry dispatcher and validation helpers.
enum VerifierRegistryErrors {
    /// Caller is not the stored verifier administrator.
    AccessDenied = 401
    /// Serialized verifier settings exceed the allowed cell depth.
    SettingsTooDeep = 402
    /// Verifier identifier does not exist.
    VerifierNotFound = 404
    /// Registration value does not cover the required stake.
    InsufficientStake = 410
    /// Signed forwarding request has expired.
    RequestExpired = 411
    /// Valid signatures do not reach the verifier threshold.
    InsufficientValidSignatures = 413
    /// Actual sender differs from the signed source address.
    InvalidSourceAddress = 414
    /// Registry already contains the maximum number of verifiers.
    VerifierLimitReached = 419
    /// SHA-256 of the verifier name differs from the supplied verifier id.
    VerifierIdMismatch = 420
    /// Signature threshold must be greater than zero.
    InvalidThreshold = 421
    /// Message opcode is not recognized.
    UnknownOperation = 65535
}
