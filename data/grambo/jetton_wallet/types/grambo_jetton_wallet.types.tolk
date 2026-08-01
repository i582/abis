/// Grambo deterministic Jetton wallet interface.
contract GramboJettonWallet {
    author: "Grambo"
    description: "Grambo deterministic Jetton wallet with activation-gated transfers and sells."
    storage: GramboJettonWalletStorage
    incomingMessages: GramboJettonWalletIncomingMessage
    outgoingMessages: GramboJettonWalletOutgoingMessage
    thrownErrors: GramboJettonWalletErrors
}

/// Standard Jetton internal transfer accepted from a master or peer wallet.
struct (0x178d4519) GramboJettonWalletInternalTransfer {
    /// Transfer request identifier.
    queryId: uint64
    /// Jetton amount to credit.
    amount: coins
    /// Original Jetton owner, optionally absent.
    from: address?
    /// Optional address for excess-value responses.
    responseAddress: address?
    /// TON forwarded with the transfer.
    forwardTonAmount: coins
    /// Inline or referenced forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton transfer requested by the wallet owner.
struct (0x0f8a7ea5) GramboJettonWalletTransfer {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Jetton amount to transfer or sell.
    amount: coins
    /// Recipient wallet owner.
    destination: address
    /// Optional address for excess-value responses.
    responseDestination: address?
    /// Optional referenced application payload.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// TON forwarded to the destination wallet.
    forwardTonAmount: coins
    /// Inline or referenced forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton burn requested by the wallet owner.
struct (0x595f07bc) GramboJettonWalletBurn {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Jetton amount to burn.
    amount: coins
    /// Optional address for excess-value responses.
    responseDestination: address?
    /// Optional referenced application payload.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Activates this wallet; only the master can send this body.
struct (0x6b75d3e2) GramboJettonWalletActivate {
    /// Master request identifier retained for wire compatibility.
    queryId: uint64
}

/// Internal bodies accepted by the Grambo wallet.
type GramboJettonWalletIncomingMessage =
    | GramboJettonWalletInternalTransfer
    | GramboJettonWalletTransfer
    | GramboJettonWalletBurn
    | GramboJettonWalletActivate

/// Standard Jetton transfer-notification emitted when forwarding TON.
struct (0x7362d09c) GramboJettonWalletTransferNotification {
    /// Transfer request identifier.
    queryId: uint64
    /// Jetton amount credited to this wallet.
    amount: coins
    /// Original Jetton owner, optionally absent.
    forwardFrom: address?
    /// Inline or referenced forwarded payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Sell request emitted to the Grambo Jetton master.
struct (0x31fc1276) GramboJettonWalletSellNotification {
    /// Transfer or burn request identifier.
    queryId: uint64
    /// Jetton amount offered for sale.
    amount: coins
    /// Owner of this wallet.
    from: address
    /// Optional address for excess-value responses.
    responseDestination: address?
    /// Optional referenced sale payload.
    sellParams: Cell<RemainingBitsAndRefs>?
}

/// Standard Jetton excess-value response.
struct (0xd53276db) GramboJettonWalletExcess {
    /// Request identifier associated with the excess value.
    queryId: uint64
}

/// Body-bearing internal messages emitted by the Grambo wallet.
type GramboJettonWalletOutgoingMessage =
    | GramboJettonWalletInternalTransfer
    | GramboJettonWalletTransferNotification
    | GramboJettonWalletSellNotification
    | GramboJettonWalletExcess

/// Persistent activation flag, balance, owner, and master addresses.
struct GramboJettonWalletStorage {
    /// Whether the master has activated this wallet.
    activated: bool
    /// Current Jetton balance.
    balance: coins
    /// Wallet owner address.
    owner: address
    /// Grambo Jetton master address.
    master: address
}

/// Return tuple of standard Jetton `get_wallet_data`.
struct GramboJettonWalletData {
    /// Current Jetton balance.
    balance: int
    /// Wallet owner address.
    ownerAddress: any_address
    /// Grambo Jetton master address.
    jettonMasterAddress: any_address
    /// Executable wallet code cell.
    jettonWalletCode: cell
}

/// Returns standard Jetton wallet data.
get fun get_wallet_data(): GramboJettonWalletData {
    throw 0;
}

/// Returns the activation flag as a TVM boolean.
get fun get_wallet_status(): bool {
    throw 0;
}

/// Exit codes thrown by the deployed Grambo wallet.
enum GramboJettonWalletErrors {
    /// A message body has an invalid wire layout.
    InvalidMessage = 63
    /// Sender is neither the master nor the deterministic peer wallet.
    UnauthorizedSender = 74
    /// Attached TON does not cover execution and forwarding.
    InsufficientValue = 48
    /// The requested Jetton amount exceeds wallet balance.
    InsufficientBalance = 47
    /// Cross-workchain transfers are rejected.
    UnsupportedWorkchain = 333
    /// The wallet has already been activated.
    AlreadyActivated = 65397
    /// The opcode is not supported by this wallet.
    UnsupportedOpcode = 65535
}
