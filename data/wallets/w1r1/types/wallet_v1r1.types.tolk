/// Wallet V1 R1 interface with persistent storage, signed external requests, and exit codes.
contract WalletV1r1 {
    author: "TON Core"
    version: "1.1"
    description: "Curated Wallet V1 R1 interface"
    storage: WalletV1r1Storage
    incomingExternal: WalletV1r1IncomingExternalMessage
}

/// Persistent Wallet V1 R1 state.
struct WalletV1r1Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
}

/// External-in request authenticated by Ed25519 signature over seqno and optional outgoing-message tail.
struct WalletV1r1SignedExternal {
    /// Ed25519 signature over seqno and the optional outgoing-message tail.
    signature: bits512
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw tail after seqno: empty or exactly one `mode:uint8` followed by one message ref.
    outgoing: RemainingBitsAndRefs
}

/// External-in message body accepted by Wallet V1 R1.
type WalletV1r1IncomingExternalMessage = WalletV1r1SignedExternal

/// Wallet V1 R1 exit-code catalog from docs/source.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Ed25519 signature verification failed.
    InvalidSignature = 34
}
