/// DeDust x1000 Wallet V1 storage interface.
contract DedustX1000WalletV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust x1000 Wallet V1 replay-window, signing-key, and revoked-key storage."
    storage: DedustX1000WalletV1Storage
}

/// Persistent replay protection and signer-revocation state.
struct DedustX1000WalletV1Storage {
    /// Base sequence number for the active 256-message replay window.
    seqnoOffset: uint32
    /// Used-sequence bitmap relative to `seqnoOffset`.
    seqnoBitmap: bits256
    /// Primary Ed25519 public key authorized to sign wallet requests.
    publicKey: uint256
    /// Revoked public keys mapped to their uint64 expiry timestamps.
    revoked: map<uint256, uint64>
}
