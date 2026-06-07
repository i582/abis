/// Wallet V2 R1 interface with persistent storage, signed external requests, get methods, and exit codes.
contract WalletV2r1 {
    author: "TON Core"
    version: "2.1"
    description: "Curated Wallet V2 R1 interface"
    storage: WalletV2r1Storage
    incomingExternal: WalletV2r1IncomingExternalMessage
    thrownErrors: Errors
}

/// Persistent Wallet V2 R1 state.
struct WalletV2r1Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
}

/// External-in request authenticated by Ed25519 signature over the unsigned trailing payload.
struct WalletV2r1SignedExternal {
    /// Ed25519 signature over seqno, validUntil, and message stream.
    signature: bits512
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Raw trailing stream of `mode:uint8` plus `^MessageRelaxed` pairs.
    messages: RemainingBitsAndRefs
}

/// External-in message body accepted by Wallet V2 R1.
type WalletV2r1IncomingExternalMessage = WalletV2r1SignedExternal

/// Wallet V2 R1 exit-code catalog from docs/source.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Ed25519 signature verification failed.
    InvalidSignature = 34
    /// Request validUntil is not greater than the current block time.
    ExpiredMessage = 35
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}
