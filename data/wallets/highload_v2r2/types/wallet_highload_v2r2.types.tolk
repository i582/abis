/// Highload Wallet V2 R2 interface with timestamped query replay protection, batched external sends, get methods, and exit codes.
contract WalletHighloadV2r2 {
    author: "TON Core"
    version: "2.2"
    description: "Curated Highload Wallet V2 R2 interface"
    storage: WalletHighloadV2r2Storage
    incomingExternal: WalletHighloadV2r2IncomingExternalMessage
}

/// Persistent Highload Wallet V2 R2 state stored in the root data cell.
struct WalletHighloadV2r2Storage {
    /// Wallet id expected to match every external request.
    subwalletId: uint32
    /// Greatest forgotten query id after replay dictionary cleanup.
    lastCleaned: uint64
    /// Stored Ed25519 public key used to verify external request signatures.
    publicKey: uint256
    /// Raw `HashmapE 64 Cell` of recently processed query ids.
    queries: cell?
}

/// Single dictionary value in the external batch payload.
struct HighloadV2r2SendMessageAction {
    /// Raw send mode passed to `send_raw_message`.
    mode: uint8
    /// Raw referenced outbound message cell.
    message: cell
}

/// External-in request authenticated by Ed25519 signature over the body after the signature.
struct HighloadWalletSignedV2r2 {
    /// Ed25519 signature over `slice_hash` of subwalletId, queryId, and payload.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Timestamped replay-protection query id.
    queryId: uint64
    /// Batch payload dictionary keyed by signed 16-bit message index.
    payload: map<uint16, HighloadV2r2SendMessageAction>
}

/// External-in message body accepted by Highload Wallet V2 R2.
type WalletHighloadV2r2IncomingExternalMessage = HighloadWalletSignedV2r2

/// Highload Wallet V2 R2 exit-code catalog from decompiled source-equivalent code.
enum Errors {
    /// Query id is already present in the replay dictionary.
    QueryAlreadyExecuted = 32
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Query id is too old or Ed25519 signature verification failed.
    InvalidQueryIdOrSignature = 35
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw Errors.QueryAlreadyExecuted;
    assert (true) throw Errors.InvalidSubwalletId;
    assert (true) throw Errors.InvalidQueryIdOrSignature;
    return 0;
}

/// Return replay status: -1 processed, 0 not processed, 1 forgotten/unknown.
get fun `processed?`(queryId: int): int {
    return 0;
}
