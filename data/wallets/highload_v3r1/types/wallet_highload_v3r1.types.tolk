/// Highload Wallet V3 R1 interface with replay dictionaries, signed external requests, self internal transfer, get methods, and exit codes.
contract WalletHighloadV3r1 {
    author: "TON Core"
    version: "3.1"
    description: "Curated Highload Wallet V3 R1 interface"
    storage: WalletHighloadV3r1Storage
    incomingMessages: WalletHighloadV3r1IncomingMessage
    incomingExternal: WalletHighloadV3r1IncomingExternalMessage
    thrownErrors: Errors
}

/// Persistent Highload Wallet V3 R1 state stored in the root data cell.
struct WalletHighloadV3r1Storage {
    /// Stored Ed25519 public key used to verify external request signatures.
    publicKey: uint256
    /// Wallet id expected to match every external request.
    subwalletId: uint32
    /// Raw `HashmapE 13 ^Cell` with query bitmaps from the previous replay-protection window.
    oldQueries: cell?
    /// Raw `HashmapE 13 ^Cell` with query bitmaps from the current replay-protection window.
    queries: cell?
    /// Unix timestamp of the last dictionary cleanup/rotation.
    lastCleanTime: uint64
    /// External-message validity window stored as uint22 seconds.
    timeout: uint22
}

/// Split highload query id used as dictionary key plus bitmap index.
struct HighloadV3QueryId {
    /// Dictionary key: high 13 bits of the query id.
    shift: uint13
    /// Bitmap index: low 10 bits of the query id; source accepts the range used by a 1023-bit cell bitmap.
    bitNumber: uint10
}

/// External request payload cell whose hash is signed by the wallet owner.
struct HighloadV3MsgInner {
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Raw referenced outbound internal message cell; StateInit is rejected by the contract after commit.
    messageToSend: cell
    /// Raw send mode OR-ed by the contract with IGNORE_ERRORS before sending.
    sendMode: uint8
    /// Replay-protection query id split into dictionary key and bitmap bit number.
    queryId: HighloadV3QueryId
    /// Unix timestamp at which the request was created.
    createdAt: uint64
    /// Timeout expected to match storage.timeout.
    timeout: uint22
}

/// External-in body with a 512-bit Ed25519 signature and one referenced inner payload cell.
struct HighloadWalletSignedV3 {
    /// Ed25519 signature over `cell_hash(msgInner)`.
    signature: bits512
    /// Referenced signed payload cell.
    msgInner: Cell<HighloadV3MsgInner>
}

/// Self-message that executes a raw C5 action list for batch transfers.
struct (0xae42e5a4) HighloadV3InternalTransfer {
    /// Caller-selected query id carried in the self-message body.
    queryId: uint64
    /// Raw referenced `OutList n` cell executed through TVM c5 actions.
    actions: cell
}

/// Internal message bodies accepted by Highload Wallet V3 R1.
type WalletHighloadV3r1IncomingMessage = HighloadV3InternalTransfer

/// External-in message body accepted by Highload Wallet V3 R1.
type WalletHighloadV3r1IncomingExternalMessage = HighloadWalletSignedV3

/// Highload Wallet V3 R1 exit-code catalog from the official FunC source.
enum Errors {
    /// Ed25519 signature verification failed.
    InvalidSignature = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Request createdAt is expired or from the future.
    InvalidCreatedAt = 35
    /// Request query id was already processed in current or previous replay dictionary.
    AlreadyExecuted = 36
    /// Referenced outbound message is not an accepted internal relaxed message shape.
    InvalidMessageToSend = 37
    /// Request timeout does not match storage.timeout.
    InvalidTimeout = 38
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    throw 0;
}

/// Return the wallet id, also called subwallet id.
get fun get_subwallet_id(): uint32 {
    throw 0;
}

/// Return the Unix timestamp of the last replay-dictionary cleanup.
get fun get_last_clean_time(): uint64 {
    throw 0;
}

/// Return the external-message validity window in seconds.
get fun get_timeout(): uint32 {
    throw 0;
}

/// Return whether `queryId` is already marked in replay dictionaries; optionally apply cleanup rules before checking.
get fun `processed?`(queryId: int, needClean: int): bool {
    throw 0;
}
