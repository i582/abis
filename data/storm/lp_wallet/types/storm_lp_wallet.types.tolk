/// Storm Trade LP Jetton wallet interface.
contract StormLpWallet {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade LP Jetton wallet for standard Jetton wallet messages, Storm excess requests, and get_wallet_data."
    storage: StormLpWalletStorage
    incomingMessages: StormLpWalletIncomingMessage
    outgoingMessages: StormLpWalletOutgoingMessage
    forceAbiExport: StormLpWalletBouncedKnownBody
    thrownErrors: StormLpWalletErrors
}

/// Runtime LP Jetton wallet storage parsed by get_wallet_data and every internal-message branch.
struct StormLpWalletStorage {
    /// LP Jetton balance encoded as TL-B `Coins`.
    balance: coins
    /// LP token owner authorized to transfer, burn, and request excess handling.
    ownerAddress: address
    /// LP Jetton minter/master address authenticated for mint-side internal transfers and burn notifications.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell used to derive and authenticate peer LP wallets.
    jettonWalletCode: cell
}

/// Standard Jetton transfer request accepted from the stored owner.
struct (0x0f8a7ea5) StormLpWalletTransfer {
    /// Caller-selected query id copied to the outgoing internal transfer.
    queryId: uint64
    /// LP Jetton amount debited from this wallet.
    amount: coins
    /// Destination owner whose deterministic LP wallet receives the transfer.
    destination: address
    /// Optional response destination for excess value after the recipient wallet processes the transfer.
    responseAddress: address?
    /// Optional standard Jetton custom payload; the live code reads and ignores this maybe-ref.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw standard Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton internal transfer accepted from the minter or an authenticated peer LP wallet.
struct (0x178d4519) StormLpWalletInternalTransfer {
    /// Query id copied from the source transfer or mint request.
    queryId: uint64
    /// LP Jetton amount credited to this wallet.
    amount: coins
    /// Source owner address reported by the sender.
    fromAddress: address
    /// Optional response destination for an excess-value refund.
    responseAddress: address?
    /// Nanotons forwarded to the owner as a transfer notification.
    forwardTonAmount: coins
    /// Raw standard Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton burn request accepted from the stored owner; live code parses only the required prefix and leaves any extra tail uninterpreted.
struct (0x595f07bc) StormLpWalletBurn {
    /// Caller-selected query id copied to the outgoing burn notification.
    queryId: uint64
    /// LP Jetton amount burned from this wallet.
    amount: coins
    /// Optional response destination forwarded to the LP minter.
    responseAddress: address?
    /// Unparsed tail after the response address; standard custom-payload compatibility is inferred but not consumed by the live code.
    tail: RemainingBitsAndRefs
}

/// Owner-only Storm message that reserves gas and emits a standard excesses response to the owner.
struct (0x6d8e5e3c) StormLpWalletRequestExcesses {
    /// Query id copied into the outgoing `excesses` body.
    queryId: uint64
}

/// Standard Jetton transfer notification emitted to the owner when an incoming internal transfer forwards TON.
struct (0x7362d09c) StormLpWalletTransferNotification {
    /// Query id copied from the accepted internal transfer.
    queryId: uint64
    /// LP Jetton amount credited by the accepted internal transfer.
    amount: coins
    /// Source owner address reported by the accepted internal transfer.
    fromAddress: address
    /// Raw forwarded payload copied from the accepted internal transfer.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excess-value response emitted after internal transfer processing and the Storm excess request.
struct (0xd53276db) StormLpWalletExcesses {
    /// Query id copied from the request that produced the excess response.
    queryId: uint64
}

/// Standard Jetton burn notification emitted to the LP minter/master.
struct (0x7bdd97de) StormLpWalletBurnNotification {
    /// Query id copied from the burn request.
    queryId: uint64
    /// LP Jetton amount burned from the owner wallet.
    amount: coins
    /// Stored owner address whose LP Jettons were burned.
    senderAddress: address
    /// Optional response destination copied from the burn request.
    responseAddress: address?
}

/// Bounced body prefix accepted before balance restoration for internal transfer and burn-notification bounces.
struct (0xffffffff) StormLpWalletBouncedKnownBody {
    /// Original bounced opcode; live code accepts internal_transfer or burn_notification.
    originalOpcode: uint32
    /// Query id from the bounced body.
    queryId: uint64
    /// LP Jetton amount restored to the wallet balance.
    amount: coins
    /// Remaining bounced body bits/refs are ignored after the amount.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the Storm LP Jetton wallet.
type StormLpWalletIncomingMessage =
    | StormLpWalletTransfer
    | StormLpWalletInternalTransfer
    | StormLpWalletBurn
    | StormLpWalletRequestExcesses

/// Internal message bodies emitted by the Storm LP Jetton wallet.
type StormLpWalletOutgoingMessage =
    | StormLpWalletInternalTransfer
    | StormLpWalletTransferNotification
    | StormLpWalletExcesses
    | StormLpWalletBurnNotification

/// Structured result returned by the standard Jetton wallet `get_wallet_data` getter.
struct GetStormLpWalletDataReply {
    /// LP Jetton balance returned as a TVM stack integer.
    balance: int
    /// Stored LP token owner address.
    ownerAddress: address
    /// Stored LP Jetton minter/master address.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell.
    jettonWalletCode: cell
}

/// Storm LP wallet exit-code catalog.
enum StormLpWalletErrors {
    /// Sender is not the stored owner for owner-only transfer, burn, or excess request.
    UnauthorizedOwner = 705
    /// Transfer or burn would make the stored LP Jetton balance negative.
    InsufficientJettonBalance = 706
    /// Internal transfer sender is neither the minter nor the authenticated peer wallet.
    InvalidInternalTransferSender = 707
    /// Transfer body is missing the forward-payload selector bit.
    MissingForwardPayload = 708
    /// Transfer attached value is below the live code funding threshold.
    TransferFundingTooLow = 709
    /// Destination owner address is not in workchain 0.
    WrongWorkchain = 710
    /// Burn request attached less than the live code minimum value.
    BurnFundingTooLow = 711
    /// Bounced body original opcode is not accepted for balance restoration.
    UnsupportedBouncedOperation = 65520
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return the standard Jetton wallet tuple: balance, owner, minter/master, and wallet code cell.
get fun get_wallet_data(): GetStormLpWalletDataReply {
    throw 0;
}
