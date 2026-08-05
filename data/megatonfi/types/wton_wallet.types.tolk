/// Wallet contract used by the deployed Wrapped TON jetton master.
contract WtonWallet {
    author: "Ozys / Megaton Finance"
    version: "2023-02"
    description: "WTON wallet implementing the project-specific TEP-74 transfer and master-controlled burn flows."
    storage: WtonWalletStorage
    incomingMessages: WtonWalletIncomingMessage
    outgoingMessages: WtonWalletOutgoingMessage
    thrownErrors: WtonWalletErrors
}

/// Persistent WTON wallet state.
struct WtonWalletStorage {
    /// Wallet WTON balance in base units.
    balance: coins
    /// Owner represented by this deterministic wallet.
    ownerAddress: address
    /// WTON minter address.
    minterAddress: address
    /// Wallet code stored for deterministic peer-wallet derivation.
    walletCode: cell
}

/// Standard owner-initiated jetton transfer.
struct (0x0f8a7ea5) WtonWalletTransfer {
    /// Owner-selected correlation id.
    queryId: uint64
    /// WTON amount to transfer.
    amount: coins
    /// Recipient owner whose deterministic wallet receives WTON.
    destination: address
    /// Address that receives remaining message value.
    responseDestination: address?
    /// Optional transfer-specific payload.
    customPayload: cell?
    /// Nanograms forwarded to the recipient owner.
    forwardTonAmount: coins
    /// Inline or referenced payload forwarded with a transfer notification.
    forwardPayload: RemainingBitsAndRefs
}

/// Transfer received from the WTON minter or another deterministic WTON wallet.
struct (0x178d4519) WtonWalletInternalTransfer {
    /// Correlation id copied from the initiating transfer.
    queryId: uint64
    /// Credited WTON amount.
    amount: coins
    /// Previous WTON owner, or depositor for minting.
    fromAddress: address
    /// Address that receives remaining message value.
    responseDestination: address?
    /// Nanograms forwarded to this wallet's owner.
    forwardTonAmount: coins
    /// Optional inline or referenced notification payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Minter-controlled WTON burn instruction.
struct (0x595f07bc) WtonWalletBurn {
    /// Correlation id copied to the burn notification.
    queryId: uint64
    /// WTON amount to burn.
    amount: coins
    /// Minter address that receives the burn notification.
    responseDestination: address?
    /// Optional payload copied to the burn notification.
    customPayload: cell?
}

/// Ordinary internal bodies accepted by the WTON wallet.
type WtonWalletIncomingMessage =
    | WtonWalletTransfer
    | WtonWalletInternalTransfer
    | WtonWalletBurn

/// Peer-wallet transfer emitted after an owner transfer.
struct (0x178d4519) WtonWalletOutgoingInternalTransfer {
    /// Query id copied from the owner transfer.
    queryId: uint64
    /// Debited WTON amount.
    amount: coins
    /// Sending wallet owner.
    fromAddress: address
    /// Address that receives remaining message value.
    responseDestination: address?
    /// Nanograms forwarded to the destination owner.
    forwardTonAmount: coins
    /// Inline or referenced notification payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Notification emitted to an owner when forwarded GRAM is non-zero.
struct (0x7362d09c) WtonWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Credited WTON amount.
    amount: coins
    /// Previous WTON owner.
    senderAddress: address
    /// Inline or referenced application payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response emitted by a WTON wallet.
struct (0xd53276db) WtonWalletExcesses {
    /// Query id copied from the completed transfer.
    queryId: uint64
}

/// Burn notification emitted to the WTON minter.
struct (0x7bdd97de) WtonWalletBurnNotification {
    /// Query id copied from the burn instruction.
    queryId: uint64
    /// Burned WTON amount.
    amount: coins
    /// Wallet owner whose GRAM must be released.
    ownerAddress: address
    /// Response destination supplied by the minter.
    responseDestination: address?
    /// Optional payload copied from the burn instruction.
    customPayload: cell?
}

/// Every statically typed ordinary internal body emitted by the WTON wallet.
type WtonWalletOutgoingMessage =
    | WtonWalletOutgoingInternalTransfer
    | WtonWalletTransferNotification
    | WtonWalletExcesses
    | WtonWalletBurnNotification

/// Standard wallet data returned by `get_wallet_data`.
struct WtonWalletData {
    /// Current WTON balance.
    balance: int
    /// Wallet owner.
    ownerAddress: address
    /// WTON minter.
    minterAddress: address
    /// Wallet code used for deterministic address derivation.
    walletCode: cell
}

/// WTON wallet exit codes.
enum WtonWalletErrors {
    /// Transfer destination belongs to another workchain.
    InvalidWorkchain = 333
    /// Transfer/burn sender is not the required owner or minter.
    UnauthorizedSender = 705
    /// Requested transfer or burn exceeds the wallet balance.
    InsufficientJettonBalance = 706
    /// Internal transfer has an invalid sender, or burn value cannot cover costs.
    InvalidPeerOrBurnValue = 707
    /// Owner transfer omits the mandatory forward-payload selector bit.
    MissingForwardPayload = 708
    /// Transfer value is insufficient, or a bounced body has an unsupported opcode.
    InsufficientValueOrInvalidBounce = 709
    /// Incoming opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return WTON wallet balance, owner, minter, and wallet code.
get fun get_wallet_data(): WtonWalletData {
    throw 0;
}
