/// Wallet V3 R1 interface with persistent storage, signed external requests, get methods, and exit codes.
contract WalletV3r1 {
    author: "TON Core"
    version: "3.1"
    description: "Curated Wallet V3 R1 interface"
    storage: WalletV3r1Storage
    incomingExternal: WalletV3r1IncomingExternalMessage
}

/// Persistent Wallet V3 R1 state.
struct WalletV3r1Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Wallet id, also called subwallet id in SDKs.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
}

/// External-in request authenticated by Ed25519 signature over the unsigned trailing payload.
struct WalletV3r1SignedExternal {
    /// Ed25519 signature over subwalletId, validUntil, seqno, and message stream.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw trailing stream of `mode:uint8` plus `^MessageRelaxed` pairs.
    messages: RemainingBitsAndRefs
}

/// External-in message body accepted by Wallet V3 R1.
type WalletV3r1IncomingExternalMessage = WalletV3r1SignedExternal

/// Wallet V3 R1 exit-code catalog from source.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Request is expired or Ed25519 signature verification failed.
    InvalidSignatureOrExpiredMessage = 35
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw Errors.InvalidSeqno;
    assert (true) throw Errors.InvalidSubwalletId;
    assert (true) throw Errors.InvalidSignatureOrExpiredMessage;
    return 0;
}
