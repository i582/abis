/// Highload Wallet V1 R2 interface with seqno replay protection, batched external sends, getters, and exit codes.
contract WalletHighloadV1r2 {
    author: "TON Core"
    version: "1.2"
    description: "Curated Highload Wallet V1 R2 interface"
    storage: WalletHighloadV1r2Storage
    incomingExternal: WalletHighloadV1r2IncomingExternalMessage
    forceAbiExport: HighloadV1r2SendMessageAction
    thrownErrors: Errors
}

/// Persistent Highload Wallet V1 R2 state stored in the root data cell.
struct WalletHighloadV1r2Storage {
    /// Replay-protection sequence number expected to match external msgSeqno.
    seqno: uint32
    /// Wallet id expected to match every signed external request.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify external request signatures.
    publicKey: uint256
}

/// Single raw dictionary value under a signed 16-bit message index in the external payload cell.
struct HighloadV1r2SendMessageAction {
    /// Raw send mode passed to `send_raw_message`.
    mode: uint8
    /// Raw referenced outbound message cell.
    message: cell
}

/// External-in request authenticated by Ed25519 signature over the body after the signature.
struct HighloadWalletSignedV1r2 {
    /// Ed25519 signature over `slice_hash` of subwalletId, validUntil, msgSeqno, and payload ref.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    msgSeqno: uint32
    /// Raw mandatory `^(Hashmap 16 ModeWithMessage)` payload cell; not a `HashmapE`.
    payload: cell
}

/// External-in message body accepted by Highload Wallet V1 R2.
type WalletHighloadV1r2IncomingExternalMessage = HighloadWalletSignedV1r2

/// Highload Wallet V1 R2 exit-code catalog from the official FunC source.
enum Errors {
    /// Request msgSeqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Request is expired or Ed25519 signature verification failed.
    ExpiredOrInvalidSignature = 35
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    throw 0;
}
