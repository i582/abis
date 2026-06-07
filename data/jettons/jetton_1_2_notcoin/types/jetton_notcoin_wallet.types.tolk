/// Jetton 1.2 / Notcoin-style wallet with standard owner transfer/burn and unused status field.
contract JettonNotcoinWallet {
    author: "TON Core"
    version: "1.2"
    description: "Curated interface for ton-blockchain/jetton-contract Notcoin/basecoin wallet"
    storage: JettonNotcoinWalletStorage
    incomingMessages: JettonNotcoinWalletIncomingMessage
    outgoingMessages: JettonNotcoinWalletOutgoingMessage
    thrownErrors: JettonNotcoinWalletErrors
}

/// Persistent Notcoin-style wallet state stored in the root data cell.
struct JettonNotcoinWalletStorage {
    /// Four-bit status field stored for compatibility; source comments say it is always 0 and unused.
    status: uint4
    /// Jetton balance encoded as TL-B `Coins` in storage.
    balance: coins
    /// Owner address authorized for outgoing transfers and burns.
    ownerAddress: address
    /// Jetton minter/master address authenticated for mint-originated internal transfers.
    jettonMasterAddress: address
}

/// Owner-originated TEP-74 transfer request accepted by the wallet.
struct (0x0f8a7ea5) JettonNotcoinWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// Jetton amount to debit from this wallet, in base units.
    amount: coins
    /// Destination owner address whose deterministic wallet receives the transfer.
    destination: address
    /// Optional response address for an `Excesses` refund.
    responseDestination: address?
    /// Optional referenced custom payload; source validates the field shape and ignores content.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or minter-to-wallet TEP-74 internal transfer body.
struct (0x178d4519) JettonNotcoinWalletInternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the sending wallet or mint payload.
    from: address?
    /// Optional response address for an `Excesses` refund after processing.
    responseAddress: address?
    /// Nanotons forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated TEP-74 burn request accepted by the wallet.
struct (0x595f07bc) JettonNotcoinWalletBurn {
    /// Caller-selected query id copied into the burn notification.
    queryId: uint64
    /// Jetton amount to burn from this wallet, in base units.
    amount: coins
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
    /// Optional referenced custom payload; source validates the field shape and ignores content.
    customPayload: cell?
}

/// Funding-only message accepted by the wallet without changing state.
struct (0xd372158c) JettonNotcoinWalletTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// Burn notification emitted to the minter after a successful owner burn.
struct (0x7bdd97de) JettonNotcoinWalletBurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Wallet owner address reported to the minter.
    sender: address
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
}

/// Owner notification emitted when an incoming transfer carries forward TON.
struct (0x7362d09c) JettonNotcoinWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received jetton amount in base units.
    amount: coins
    /// Source owner address reported by the internal transfer.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excesses response emitted to a transfer response address when value remains after processing.
struct (0xd53276db) JettonNotcoinWalletExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the Jetton 1.2 / Notcoin-style wallet.
type JettonNotcoinWalletIncomingMessage =
    | JettonNotcoinWalletTransfer
    | JettonNotcoinWalletInternalTransfer
    | JettonNotcoinWalletBurn
    | JettonNotcoinWalletTopUp

/// Internal message bodies emitted by the Jetton 1.2 / Notcoin-style wallet.
type JettonNotcoinWalletOutgoingMessage =
    | JettonNotcoinWalletInternalTransfer
    | JettonNotcoinWalletBurnNotification
    | JettonNotcoinWalletTransferNotification
    | JettonNotcoinWalletExcesses

/// Structured result returned by `get_wallet_data`.
struct GetJettonNotcoinWalletDataReply {
    /// Jetton balance returned as a TVM stack integer.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// Jetton minter/master address.
    jettonMasterAddress: address
    /// Current wallet code cell; live deployments expose an exotic library reference cell.
    jettonWalletCode: cell
}

/// Jetton 1.2 / Notcoin-style wallet exit-code catalog from official FunC source.
enum JettonNotcoinWalletErrors {
    /// Transfer or burn would make the stored jetton balance negative.
    InsufficientJettonBalance = 47
    /// Transfer or burn funding is below the required gas/forward-fee budget.
    NotEnoughGas = 48
    /// Forward payload layout is invalid for a validated transfer.
    InvalidMessage = 49
    /// Sender is not the stored owner for transfer or burn requests.
    UnauthorizedOwner = 73
    /// Internal transfer sender is not the minter or deterministic peer wallet.
    InvalidSender = 74
    /// Destination owner address is outside the configured base workchain.
    WrongWorkchain = 333
    /// Incoming internal message opcode is unsupported, or bounced body opcode is not recognized.
    UnsupportedOperation = 65535
}

/// Return wallet balance, owner address, minter address, and wallet code cell.
get fun get_wallet_data(): GetJettonNotcoinWalletDataReply {
    throw 0;
}

/// Return the stored four-bit status field, currently unused and expected to remain 0.
get fun get_status(): uint4 {
    throw 0;
}
