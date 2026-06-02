/// Wallet V1 R3 interface with persistent storage, signed external requests, get methods, and exit codes.
contract WalletV1r3 {
    author: "TON Core"
    version: "1.3"
    description: "Curated Wallet V1 R3 interface"
    storage: WalletV1r3Storage
    incomingExternal: WalletV1r3IncomingExternalMessage
}

/// Persistent Wallet V1 R3 state.
struct WalletV1r3Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
}

/// External-in request authenticated by Ed25519 signature over seqno and optional outgoing-message tail.
struct WalletV1r3SignedExternal {
    /// Ed25519 signature over seqno and the optional outgoing-message tail.
    signature: bits512
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw tail after seqno: empty or exactly one `mode:uint8` followed by one message ref.
    outgoing: RemainingBitsAndRefs
}

/// External-in message body accepted by Wallet V1 R3.
type WalletV1r3IncomingExternalMessage = WalletV1r3SignedExternal

/// Wallet V1 R3 exit-code catalog from docs/source.
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

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    return 0;
}
