/// Wallet V1 R2 interface with persistent storage, signed external requests, get methods, and exit codes.
contract WalletV1r2 {
    author: "TON Core"
    version: "1.2"
    description: "Curated Wallet V1 R2 interface"
    storage: WalletV1r2Storage
    incomingExternal: WalletV1r2IncomingExternalMessage
}

/// Persistent Wallet V1 R2 state.
struct WalletV1r2Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
}

/// External-in request authenticated by Ed25519 signature over seqno and optional outgoing-message tail.
struct WalletV1r2SignedExternal {
    /// Ed25519 signature over seqno and the optional outgoing-message tail.
    signature: bits512
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw tail after seqno: empty or exactly one `mode:uint8` followed by one message ref.
    outgoing: RemainingBitsAndRefs
}

/// External-in message body accepted by Wallet V1 R2.
type WalletV1r2IncomingExternalMessage = WalletV1r2SignedExternal

/// Wallet V1 R2 exit-code catalog from docs/source.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Ed25519 signature verification failed.
    InvalidSignature = 34
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw Errors.InvalidSeqno;
    assert (true) throw Errors.InvalidSignature;
    return 0;
}
