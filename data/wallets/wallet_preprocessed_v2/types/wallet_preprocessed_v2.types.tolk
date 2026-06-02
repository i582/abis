/// Preprocessed Wallet V2 interface with compact seqno storage and signed external action-list execution.
contract WalletPreprocessedV2 {
    author: "pyAndr3w"
    version: "2.0"
    description: "Curated Preprocessed Wallet V2 interface"
    storage: WalletPreprocessedV2Storage
    incomingExternal: WalletPreprocessedV2IncomingExternalMessage
    forceAbiExport: Errors
}

/// Persistent Preprocessed Wallet V2 state stored in the root data cell.
struct WalletPreprocessedV2Storage {
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
    /// Compact replay-protection sequence number modulo 2^16.
    seqNo: uint16
}

/// Referenced external request payload whose cell hash is signed by the wallet owner.
struct PreprocessedWalletV2MsgInner {
    /// Unix timestamp until which the external request remains valid.
    validUntil: uint64
    /// Request sequence number expected to match storage.seqNo.
    seqNo: uint16
    /// Raw referenced TVM `OutList n` action list executed through register c5.
    actions: cell
}

/// External-in request authenticated by Ed25519 signature over `cell_hash(msg)`.
struct PreprocessedWalletSignedV2 {
    /// Ed25519 signature over the referenced `PreprocessedWalletV2MsgInner` cell.
    sign: bits512
    /// Referenced request payload containing validUntil, seqNo, and raw OutList actions.
    inner: Cell<PreprocessedWalletV2MsgInner>
}

/// External-in message body accepted by Preprocessed Wallet V2.
type WalletPreprocessedV2IncomingExternalMessage = PreprocessedWalletSignedV2

/// Preprocessed Wallet V2 exit-code catalog from docs and disassembly.
enum Errors {
    /// Request seqNo does not match storage.seqNo.
    InvalidSeqno = 33
    /// Request validUntil is earlier than the current Unix timestamp.
    Expired = 34
    /// Ed25519 signature verification failed.
    InvalidSignature = 35
}
