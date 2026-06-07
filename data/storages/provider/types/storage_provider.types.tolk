/// TON Storage provider/factory interface with wallet-style external control and storage-offer deployment.
contract StorageProvider {
    author: "TON Core"
    version: "1.0"
    description: "Official TON Storage provider contract interface"
    storage: StorageProviderStorage
    incomingMessages: StorageProviderIncomingMessage
    incomingExternal: StorageProviderIncomingExternalMessage
    outgoingMessages: StorageProviderOutgoingMessage
    forceAbiExport: TorrentInfo | StorageProviderExternalSendAction
    thrownErrors: StorageProviderErrors
}

/// Persistent provider state stored in the root data cell.
struct StorageProviderStorage {
    /// Replay-protection sequence number for signed external requests.
    seqno: uint32
    /// Provider wallet id checked by signed external requests.
    subwallet: uint32
    /// Ed25519 public key used to verify signed external requests.
    publicKey: uint256
    /// Whether the provider accepts new storage contract offers.
    acceptNewContracts: bool
    /// Storage price in nanotons per MiB per day.
    ratePerMbDay: coins
    /// Maximum allowed span between proofs, in seconds.
    maxSpan: uint32
    /// Minimum accepted file size in bytes.
    minimalFileSize: uint64
    /// Maximum accepted file size in bytes.
    maximalFileSize: uint64
}

/// Prefix of the `TorrentInfo` ref used by offer messages.
struct TorrentInfo {
    /// Piece size from the TON Storage bag metadata.
    pieceSize: uint32
    /// File size in bytes, used by the provider for size-limit checks.
    fileSize: uint64
    /// Root hash from the torrent metadata.
    rootHash: uint256
    /// Header size in bytes.
    headerSize: uint64
    /// Header hash from the torrent metadata.
    headerHash: uint256
    /// Remaining `microchunk_hash:(Maybe uint256) description:Text` tail.
    tail: RemainingBitsAndRefs
}

/// One raw external send action consumed after signed external header fields.
struct StorageProviderExternalSendAction {
    /// Raw mode passed to `send_raw_message`.
    mode: uint8
    /// Referenced outbound internal message cell.
    message: cell
}

/// No-op text/comment transfer accepted when the leading opcode is zero.
struct (0x00000000) StorageProviderTextComment {
    /// Raw comment or transfer tail ignored by the provider.
    text: RemainingBitsAndRefs
}

/// Client offer asking the provider to deploy a per-file storage contract.
struct (0x107c49ef) StorageProviderOfferStorageContract {
    /// Caller-selected query id copied into the deploy message.
    queryId: uint64
    /// Referenced TON Storage torrent metadata.
    info: Cell<TorrentInfo>
    /// Merkle root hash expected by the resulting storage contract.
    merkleHash: uint256
    /// Price expected by the client, in nanotons per MiB per day.
    expectedRate: coins
    /// Maximum proof span expected by the client, in seconds.
    expectedMaxSpan: uint32
}

/// Notification from a storage contract after it is closed.
struct (0xb6236d63) StorageProviderStorageContractTerminated {
    /// Logical time copied from the terminating storage contract.
    curLt: uint64
    /// Torrent hash identifying the closed storage agreement.
    torrentHash: uint256
}

/// Self-sent administrative request to replace the provider public key.
struct (0x53f34cd6) StorageProviderUpdatePubkey {
    /// Caller-selected query id.
    queryId: uint64
    /// New Ed25519 public key stored in provider state.
    newPubkey: uint256
}

/// Self-sent administrative request to update provider storage terms.
struct (0x54cbf19b) StorageProviderUpdateStorageParams {
    /// Caller-selected query id.
    queryId: uint64
    /// Whether future offers are accepted.
    acceptNewContracts: bool
    /// New storage price in nanotons per MiB per day.
    ratePerMbDay: coins
    /// New maximum proof span, in seconds.
    maxSpan: uint32
    /// New minimum accepted file size in bytes.
    minimalFileSize: uint64
    /// New maximum accepted file size in bytes.
    maximalFileSize: uint64
}

/// Deploy body emitted to a deterministic storage contract address with StateInit.
struct (0xe4748df1) StorageProviderDeployStorageContract {
    /// Query id copied from the accepted storage offer.
    queryId: uint64
}

/// Signed external request authenticated by the provider public key.
struct StorageProviderSignedExternal {
    /// Ed25519 signature over the body after the signature.
    signature: bits512
    /// Provider wallet id expected to match storage.subwallet.
    subwallet: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    msgSeqno: uint32
    /// Raw repeated `(mode:uint8, message:^Cell)` action tail.
    messages: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the provider.
type StorageProviderIncomingMessage =
    | StorageProviderTextComment
    | StorageProviderOfferStorageContract
    | StorageProviderStorageContractTerminated
    | StorageProviderUpdatePubkey
    | StorageProviderUpdateStorageParams

/// External-in body accepted by the provider.
type StorageProviderIncomingExternalMessage = StorageProviderSignedExternal

/// Internal message bodies emitted by the provider.
type StorageProviderOutgoingMessage = StorageProviderDeployStorageContract

/// Structured result returned by `get_wallet_params`.
struct StorageProviderWalletParamsReply {
    /// Current replay-protection sequence number.
    seqno: uint32
    /// Provider wallet id used by signed external requests.
    subwallet: uint32
    /// Stored Ed25519 public key.
    publicKey: uint256
}

/// Structured result returned by `get_storage_params`.
struct StorageProviderStorageParamsReply {
    /// Whether the provider currently accepts new offers.
    acceptNewContracts: bool
    /// Current storage price in nanotons per MiB per day.
    ratePerMbDay: coins
    /// Current maximum proof span, in seconds.
    maxSpan: uint32
    /// Current minimum accepted file size in bytes.
    minimalFileSize: uint64
    /// Current maximum accepted file size in bytes.
    maximalFileSize: uint64
}

/// Storage provider exit-code catalog.
enum StorageProviderErrors {
    /// Request msgSeqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request subwallet does not match storage.subwallet.
    InvalidSubwallet = 34
    /// External request is expired or its Ed25519 signature is invalid.
    ExpiredOrInvalidSignature = 35
    /// Offer value is too small to deploy a storage contract.
    NotEnoughMoney = 1001
    /// Offered file size is below provider minimum.
    FileTooSmall = 1004
    /// Offered file size is above provider maximum.
    FileTooBig = 1005
    /// Provider is not accepting new storage contracts.
    NoNewContracts = 1006
    /// Offer expected rate or max span does not match provider settings.
    ProviderParamsChanged = 1009
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the stored provider public key.
get fun get_public_key(): uint256 {
    throw 0;
}

/// Return wallet-style replay and authorization parameters.
get fun get_wallet_params(): StorageProviderWalletParamsReply {
    throw 0;
}

/// Return current provider storage terms.
get fun get_storage_params(): StorageProviderStorageParamsReply {
    throw 0;
}

/// Return the deterministic storage contract address for the provided offer data.
get fun get_storage_contract_address(
    merkleHash: uint256,
    fileSize: uint64,
    client: address,
    torrentHash: uint256,
): address {
    throw 0;
}
