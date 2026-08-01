/// COCOON production root that governs protocol code hashes, pricing, proxies, and signing keys.
contract CocoonRoot {
    author: "Telegram"
    description: "COCOON root registry and protocol-parameter controller."
    storage: CocoonRootStorage
    incomingMessages: CocoonRootIncomingMessage
    outgoingMessages: CocoonRootOutgoingMessage
    forceAbiExport: CocoonRootParams
        | CocoonRootData
        | CocoonRootPublicKeysManagerData
        | CocoonRootPublicKeyInfo
        | CocoonRootSignedAddPublicKeyPayload
    thrownErrors: CocoonRootErrors
}

/// Expiring public-key authorization stored by the production Root.
struct CocoonRootPublicKeyInfo {
    /// Application-defined public-key class.
    keyType: uint8
    /// Unix timestamp after which the key is invalid.
    expiresAt: uint32
}

/// Protocol parameters and embedded child-contract code cells.
struct CocoonRootParams {
    /// Persistent parameter layout revision; current production value is four.
    structVersion: uint8
    /// Monotonic revision of the protocol parameters.
    paramsVersion: uint32
    /// Network-specific protocol identifier.
    uniqueId: uint32
    /// Whether the configuration belongs to a test deployment.
    isTest: bool
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Prompt-token multiplier in protocol fixed-point units.
    promptTokensPriceMultiplier: uint32
    /// Cached-token multiplier in protocol fixed-point units.
    cachedTokensPriceMultiplier: uint32
    /// Completion-token multiplier in protocol fixed-point units.
    completionTokensPriceMultiplier: uint32
    /// Reasoning-token multiplier in protocol fixed-point units.
    reasoningTokensPriceMultiplier: uint32
    /// Seconds a Proxy must wait before completing close.
    proxyDelayBeforeClose: uint32
    /// Seconds a Client must wait before completing refund.
    clientDelayBeforeClose: uint32
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
    /// Optional current Proxy code cell.
    proxyCode: cell?
    /// Optional current Worker code cell.
    workerCode: cell?
    /// Optional current Client code cell.
    clientCode: cell?
}

/// Mutable registries stored in the Root's first referenced data cell.
struct CocoonRootData {
    /// Accepted Proxy code hashes; dictionary values are empty slices.
    proxyHashes: map<uint256, slice>
    /// Raw HashmapE 32 registry whose values are protocol length-prefixed endpoint slices.
    registeredProxies: dict
    /// Latest allocated Proxy sequence number.
    lastProxySeqno: uint32
    /// Accepted Worker image hashes; dictionary values are empty slices.
    workerHashes: map<uint256, slice>
    /// Accepted model image hashes; dictionary values are empty slices.
    modelHashes: map<uint256, slice>
}

/// Public-key registry and current key-manager attestation identity.
struct CocoonRootPublicKeysManagerData {
    /// Authorized public keys keyed by Ed25519 public key.
    publicKeys: map<uint256, CocoonRootPublicKeyInfo>
    /// Ed25519 key authorized to submit signed key additions.
    managerPublicKey: uint256
    /// Expected key-manager TEE image hash.
    managerImageHash: uint256
    /// Length-prefixed key-manager endpoint occupying the remaining bits.
    managerNetworkAddress: RemainingBitsAndRefs
}

/// Complete production persistent state, including the post-v4 key-manager reference.
struct CocoonRootStorage {
    /// Administrator authorized to mutate Root configuration.
    ownerAddress: address
    /// Monotonic Root state revision.
    version: uint32
    /// Hash and Proxy endpoint registries.
    data: Cell<CocoonRootData>
    /// Current economic parameters and child code cells.
    params: Cell<CocoonRootParams>
    /// Public-key registry and key-manager identity.
    publicKeysManager: Cell<CocoonRootPublicKeysManagerData>
}

/// Add an accepted Worker image hash.
struct (0xe34b1c60) CocoonRootAddWorkerType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Worker image hash admitted by the protocol.
    workerHash: uint256
}

/// Remove an accepted Worker image hash.
struct (0x8d94a79a) CocoonRootDeleteWorkerType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Worker image hash removed from the registry.
    workerHash: uint256
}

/// Add an accepted model image hash.
struct (0xc146134d) CocoonRootAddModelType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Model image hash admitted by the protocol.
    modelHash: uint256
}

/// Remove an accepted model image hash.
struct (0x92b11c18) CocoonRootDeleteModelType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Model image hash removed from the registry.
    modelHash: uint256
}

/// Add an accepted Proxy binary hash.
struct (0x71860e80) CocoonRootAddProxyType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Proxy binary hash admitted by the protocol.
    proxyHash: uint256
}

/// Remove an accepted Proxy binary hash.
struct (0x3c41d0b2) CocoonRootDeleteProxyType {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Proxy binary hash removed from the registry.
    proxyHash: uint256
}

/// Register a new Proxy endpoint and allocate its sequence number.
struct (0x927c7cb5) CocoonRootRegisterProxy {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Length-prefixed network endpoint occupying the remainder of the body.
    proxyInfo: RemainingBitsAndRefs
}

/// Remove a registered Proxy endpoint.
struct (0x6d49eaf2) CocoonRootUnregisterProxy {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Proxy sequence number to remove.
    seqno: uint32
}

/// Replace the network endpoint of a registered Proxy.
struct (0x9c7924ba) CocoonRootUpdateProxy {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Existing Proxy sequence number.
    seqno: uint32
    /// Replacement length-prefixed network endpoint.
    proxyAddress: RemainingBitsAndRefs
}

/// Signed payload referenced by a key-manager-authorized key addition.
struct CocoonRootSignedAddPublicKeyPayload {
    /// Opcode copied from the outer signed message.
    op: uint32
    /// Query identifier copied from the outer signed message.
    queryId: uint64
    /// Ed25519 public key to authorize.
    publicKey: uint256
    /// Application-defined public-key class.
    keyType: uint8
    /// Unix timestamp after which the key is invalid.
    expiresAt: uint32
}

/// Add a public key using the key manager's detached Ed25519 signature.
struct (0x9e0e1821) CocoonRootAddPublicKeySigned {
    /// Correlation identifier included in the signed payload.
    queryId: uint64
    /// Account that receives the excess acknowledgement.
    sendExcessesTo: address
    /// Key-manager signature over the referenced payload cell.
    signature: bits512
    /// Signed key authorization payload.
    payload: Cell<CocoonRootSignedAddPublicKeyPayload>
}

/// Add a public key directly as the Root owner.
struct (0x6e5a646a) CocoonRootAddPublicKey {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Ed25519 public key to authorize.
    publicKey: uint256
    /// Application-defined public-key class.
    keyType: uint8
    /// Unix timestamp after which the key is invalid.
    expiresAt: uint32
}

/// Change the client and worker token prices.
struct (0xc52ed8d4) CocoonRootChangeFees {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
}

/// Change economic stakes and close delays together with token prices.
struct (0x022fa189) CocoonRootChangeParams {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Seconds a Proxy waits before close completion.
    proxyDelayBeforeClose: uint32
    /// Seconds a Client waits before refund completion.
    clientDelayBeforeClose: uint32
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
}

/// Replace the embedded child-contract code cells.
struct (0xa2370f61) CocoonRootUpgradeContracts {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// New Proxy code cell.
    proxyCode: cell
    /// New Worker code cell.
    workerCode: cell
    /// New Client code cell.
    clientCode: cell
}

/// Replace only the Root code cell.
struct (0x11aefd51) CocoonRootUpgradeCode {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// New Root code cell.
    newCode: cell
}

/// Clear code-hash and registered-Proxy dictionaries.
struct (0x563c1d96) CocoonRootReset {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
}

/// Replace Root data and code atomically.
struct (0x4f7c5789) CocoonRootUpgradeFull {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// Complete replacement data cell.
    newData: cell
    /// Complete replacement code cell.
    newCode: cell
}

/// Transfer Root administration to another account.
struct (0xc4a1ae54) CocoonRootChangeOwner {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// New Root administrator.
    newOwnerAddress: address
}

/// Replace the key-manager key, TEE image hash, and endpoint.
struct (0xb01c0fe9) CocoonRootChangeKeyManager {
    /// Correlation identifier copied to the excess acknowledgement.
    queryId: uint64
    /// New key-manager Ed25519 public key.
    managerPublicKey: uint256
    /// New expected key-manager TEE image hash.
    managerImageHash: uint256
    /// New length-prefixed key-manager network endpoint.
    managerNetworkAddress: RemainingBitsAndRefs
}

/// Internal messages accepted by the production Root.
type CocoonRootIncomingMessage =
    | CocoonRootAddWorkerType
    | CocoonRootDeleteWorkerType
    | CocoonRootAddModelType
    | CocoonRootDeleteModelType
    | CocoonRootAddProxyType
    | CocoonRootDeleteProxyType
    | CocoonRootRegisterProxy
    | CocoonRootUnregisterProxy
    | CocoonRootUpdateProxy
    | CocoonRootAddPublicKeySigned
    | CocoonRootAddPublicKey
    | CocoonRootChangeFees
    | CocoonRootChangeParams
    | CocoonRootUpgradeContracts
    | CocoonRootUpgradeCode
    | CocoonRootReset
    | CocoonRootUpgradeFull
    | CocoonRootChangeOwner
    | CocoonRootChangeKeyManager

/// Excess-value acknowledgement emitted after a successful Root command.
struct (0x2565934c) CocoonRootReturnExcesses {
    /// Correlation identifier copied from the command.
    queryId: uint64
}

/// Internal messages emitted by the production Root.
type CocoonRootOutgoingMessage = CocoonRootReturnExcesses

/// Compact public Root state returned by `get_cocoon_data`.
struct CocoonRootDataResult {
    /// Monotonic Root state revision.
    version: uint32
    /// Latest allocated Proxy sequence number.
    lastProxySeqno: uint32
    /// Monotonic parameter revision.
    paramsVersion: uint32
    /// Network-specific protocol identifier.
    uniqueId: uint32
    /// Whether this is a test deployment.
    isTest: bool
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
    /// Root administrator address returned as a TVM slice.
    ownerAddress: address
}

/// Current protocol parameters and child code hashes returned by `get_cur_params`.
struct CocoonRootCurrentParamsResult {
    /// Monotonic parameter revision.
    paramsVersion: uint32
    /// Network-specific protocol identifier.
    uniqueId: uint32
    /// Whether this is a test deployment.
    isTest: bool
    /// Client price per token in nanotons.
    pricePerToken: coins
    /// Worker share per token in nanotons.
    workerFeePerToken: coins
    /// Cached-token multiplier in protocol fixed-point units.
    cachedTokensPriceMultiplier: uint32
    /// Reasoning-token multiplier in protocol fixed-point units.
    reasoningTokensPriceMultiplier: uint32
    /// Seconds a Proxy waits before close completion.
    proxyDelayBeforeClose: uint32
    /// Seconds a Client waits before refund completion.
    clientDelayBeforeClose: uint32
    /// Minimum Proxy stake in nanotons.
    minProxyStake: coins
    /// Minimum Client stake in nanotons.
    minClientStake: coins
    /// Hash of the embedded Proxy code, or zero when absent.
    proxyCodeHash: uint256
    /// Hash of the embedded Worker code, or zero when absent.
    workerCodeHash: uint256
    /// Hash of the embedded Client code, or zero when absent.
    clientCodeHash: uint256
}

/// Return the latest allocated Proxy sequence number.
get fun last_proxy_seqno(): int {
    throw 0;
}

/// Return compact Root state and economic parameters.
get fun get_cocoon_data(): CocoonRootDataResult {
    throw 0;
}

/// Return current economic parameters and embedded child code hashes.
get fun get_cur_params(): CocoonRootCurrentParamsResult {
    throw 0;
}

/// Return minus one when a Proxy binary hash is registered, otherwise zero.
get fun proxy_hash_is_valid(hash: int): int {
    throw 0;
}

/// Return minus one when a Worker image hash is registered, otherwise zero.
get fun worker_hash_is_valid(hash: int): int {
    throw 0;
}

/// Return minus one when a model image hash is registered, otherwise zero.
get fun model_hash_is_valid(hash: int): int {
    throw 0;
}

/// Return minus one when a public key is currently registered, otherwise zero.
get fun public_key_is_valid(hash: int): int {
    throw 0;
}

/// Root exit codes raised for malformed, unauthorized, stale, or unknown commands.
enum CocoonRootErrors {
    /// Signed key authorization has already expired.
    OldMessage = 1000
    /// Variable-length network endpoint has an invalid encoding.
    MessageFormatMismatch = 1004
    /// Signed payload header does not match the outer message.
    SignedMessageFormatMismatch = 1005
    /// Key-manager Ed25519 signature is invalid.
    BadSignature = 1007
    /// Persistent parameter data uses an unsupported layout revision.
    StoredDataDamaged = 1008
    /// Command sender is not the configured Root owner.
    ExpectedMessageFromOwner = 1010
    /// Incoming opcode is not supported.
    UnknownOperation = 1012
    /// Proxy sequence number is absent from the registry.
    UnknownProxyType = 2000
}
