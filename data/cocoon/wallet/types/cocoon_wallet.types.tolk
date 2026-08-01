/// COCOON production wallet used by a protocol operator to relay messages.
contract CocoonWallet {
    author: "Telegram"
    description: "COCOON operator wallet with signed batches, owner relay, and emergency controls."
    storage: CocoonWalletStorage
    incomingMessages: CocoonWalletIncomingMessage
    incomingExternal: CocoonWalletIncomingExternalMessage
    outgoingMessages: CocoonWalletOutgoingMessage
    thrownErrors: CocoonWalletErrors
}

/// Complete persistent state of a COCOON Wallet.
struct CocoonWalletStorage {
    /// Replay-protection sequence number for signed external requests.
    seqno: uint32
    /// Wallet identifier included in every signed external request.
    subwalletId: uint32
    /// Ed25519 public key authorized to sign external requests.
    publicKey: uint256
    /// Status bit field; bit zero blocks external request execution.
    status: uint32
    /// Account authorized to relay internal messages and control wallet status.
    ownerAddress: address
}

/// Signed external batch accepted by the wallet.
struct CocoonWalletSignedExternal {
    /// Ed25519 signature over every field and referenced message after it.
    signature: bits512
    /// Wallet identifier expected to match storage.
    subwalletId: uint32
    /// Unix timestamp after which the request is rejected.
    validUntil: uint32
    /// Request sequence number expected to match storage.
    seqno: uint32
    /// Raw stream of repeated `mode:uint8` plus referenced message cells.
    messages: RemainingBitsAndRefs
}

/// External-in body accepted by the COCOON Wallet.
type CocoonWalletIncomingExternalMessage = CocoonWalletSignedExternal

/// Ask the wallet to relay an already serialized internal message.
struct (0x9c69f376) CocoonWalletSendMessage {
    /// Owner-supplied correlation identifier; it is not interpreted by the wallet.
    queryId: uint64
    /// TVM `SENDRAWMSG` mode used for the referenced message.
    mode: uint8
    /// Complete serialized outbound message cell.
    message: cell
}

/// Owner text command for withdraw, block, or unblock.
struct (0x00000000) CocoonWalletTextCommand {
    /// ASCII `w` withdraws, `b` blocks, and `u` unblocks the wallet.
    action: uint8
}

/// Excess acknowledgement accepted and ignored by the wallet.
struct (0x2565934c) CocoonWalletReturnExcesses {
    /// Correlation identifier supplied by the responding contract.
    queryId: uint64
}

/// Payout notification accepted and ignored by the wallet.
struct (0xc59a7cd3) CocoonWalletPayout {
    /// Correlation identifier supplied by the paying contract.
    queryId: uint64
}

/// No-op envelope deliberately ignored before owner validation.
struct (0x9a1247c0) CocoonWalletDoNotProcess {
    /// Arbitrary application payload ignored by the wallet.
    payload: RemainingBitsAndRefs
}

/// Internal messages accepted or deliberately ignored by the wallet.
type CocoonWalletIncomingMessage =
    | CocoonWalletSendMessage
    | CocoonWalletTextCommand
    | CocoonWalletReturnExcesses
    | CocoonWalletPayout
    | CocoonWalletDoNotProcess

/// The only statically constructed body emitted by wallet code.
///
/// Signed batches and `CocoonWalletSendMessage` can additionally relay arbitrary
/// complete message cells, which cannot be represented by a finite body union.
type CocoonWalletOutgoingMessage = CocoonWalletTextCommand

/// Return the current external-message sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the Ed25519 public key authorized for external batches.
get fun get_public_key(): uint256 {
    throw 0;
}

/// Return the account authorized to send internal owner commands.
get fun get_owner_address(): address {
    throw 0;
}

/// Wallet exit codes raised for invalid external or internal commands.
enum CocoonWalletErrors {
    /// Signed external request has expired.
    ExternalMessageExpired = 1030
    /// Wallet status blocks external request execution.
    WalletBlocked = 1031
    /// External request sequence number does not match storage.
    InvalidSeqno = 1032
    /// External request subwallet identifier does not match storage.
    InvalidSubwalletId = 1033
    /// External request has an invalid Ed25519 signature.
    InvalidSignature = 1034
    /// Wallet balance is below the two-TON execution threshold.
    LowWalletBalance = 1035
    /// Internal command sender is not the configured owner.
    ExpectedOwner = 1040
    /// Internal opcode or text action is not supported.
    UnknownOwnerCommand = 1041
}
