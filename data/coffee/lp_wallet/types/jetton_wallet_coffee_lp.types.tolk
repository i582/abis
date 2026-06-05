/// Coffee DEX LP Jetton wallet with standard Jetton transfer messages and Coffee-specific burn payload forwarding.
contract JettonWalletCoffeeLp {
    author: "swap.coffee"
    version: "1.0"
    description: "Coffee DEX LP Jetton wallet ABI for standard Jetton transfers, LP burns, owner notifications, excesses, and wallet data."
    storage: JettonWalletCoffeeLpStorage
    incomingMessages: JettonWalletCoffeeLpIncomingMessage
    outgoingMessages: JettonWalletCoffeeLpOutgoingMessage
    forceAbiExport: JettonWalletCoffeeLpBouncedKnownBody
}

/// Persistent Jetton wallet state stored in the root data cell.
struct JettonWalletCoffeeLpStorage {
    /// LP Jetton balance encoded as TL-B `Coins`.
    balance: coins
    /// Owner authorized to transfer or burn LP Jettons.
    ownerAddress: address
    /// Jetton master address; for Coffee LP this is the Pool contract.
    jettonMasterAddress: address
    /// Referenced wallet code cell used to derive peer wallet addresses.
    jettonWalletCode: cell
}

/// Standard Jetton transfer request accepted from the wallet owner.
struct (0x0f8a7ea5) JettonWalletCoffeeLpTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// LP Jetton amount to debit from this wallet.
    amount: coins
    /// Destination owner whose deterministic wallet receives the transfer.
    destination: address
    /// Optional response address for an `excesses` refund.
    responseAddress: address?
    /// Optional custom payload.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton internal transfer used by peer LP wallets and Pool minting.
struct (0x178d4519) JettonWalletCoffeeLpInternalTransfer {
    /// Query id copied from the transfer or mint payload.
    queryId: uint64
    /// LP Jetton amount credited to this wallet.
    amount: coins
    /// Original owner address reported by the sender.
    fromAddress: address
    /// Optional response address for an `excesses` refund.
    responseAddress: address?
    /// Nanotons forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// LP burn request accepted from the wallet owner and forwarded to the Pool.
struct (0x595f07bc) JettonWalletCoffeeLpBurn {
    /// Caller-selected query id copied into the outgoing burn notification.
    queryId: uint64
    /// LP Jetton amount to burn.
    amount: coins
    /// Optional response/liquidity receiver address; Pool treats `addr_none` as the LP owner.
    responseAddress: address?
    /// Optional burn payload forwarded to the Pool.
    customPayload: cell?
}

/// Standard Jetton owner notification emitted when forwarded TON is attached.
struct (0x7362d09c) JettonWalletCoffeeLpTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received LP Jetton amount.
    amount: coins
    /// Original owner address reported by the internal transfer.
    fromAddress: address
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excesses response emitted when value remains after receiving tokens.
struct (0xd53276db) JettonWalletCoffeeLpExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Standard burn notification emitted to the Pool after an LP burn.
struct (0x7bdd97de) JettonWalletCoffeeLpBurnNotification {
    /// Query id copied from the burn request.
    queryId: uint64
    /// Burned LP Jetton amount.
    amount: coins
    /// LP owner address whose liquidity should be released.
    fromAddress: address
    /// Optional response/liquidity receiver address forwarded from the burn request.
    responseAddress: address?
    /// Optional raw burn custom payload forwarded without wallet-side parsing.
    customPayload: cell?
}

/// Bounced body prefix accepted before checking the original opcode.
struct (0xffffffff) JettonWalletCoffeeLpBouncedKnownBody {
    /// Original bounced opcode; accepted values are `internal_transfer` or `burn_notification`.
    originalOpcode: uint32
    /// Query id from the bounced body.
    queryId: uint64
    /// LP Jetton amount restored to balance on accepted bounces.
    amount: coins
    /// Remaining bounced body bits and refs after the amount.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the Coffee LP Jetton wallet.
type JettonWalletCoffeeLpIncomingMessage =
    | JettonWalletCoffeeLpTransfer
    | JettonWalletCoffeeLpInternalTransfer
    | JettonWalletCoffeeLpBurn

/// Internal message bodies emitted by the Coffee LP Jetton wallet.
type JettonWalletCoffeeLpOutgoingMessage =
    | JettonWalletCoffeeLpInternalTransfer
    | JettonWalletCoffeeLpTransferNotification
    | JettonWalletCoffeeLpExcesses
    | JettonWalletCoffeeLpBurnNotification

/// Structured result returned by the standard Jetton wallet `get_wallet_data` getter.
struct GetJettonWalletCoffeeLpDataReply {
    /// LP Jetton balance returned as a TVM stack integer.
    balance: int
    /// LP Jetton owner address.
    ownerAddress: address
    /// Jetton master/Pool address.
    jettonMasterAddress: address
    /// Referenced wallet code cell.
    jettonWalletCode: cell
}

/// Coffee LP Jetton wallet error codes.
enum JettonWalletCoffeeLpErrors {
    /// Incoming opcode is not supported by the wallet.
    UnknownOpcode = 6
    /// Transfer destination owner is outside the base workchain.
    WrongChain = 255
    /// Sender is not the stored owner for transfer or burn requests.
    UnauthorizedOwner = 705
    /// Transfer or burn would make the stored LP Jetton balance negative.
    InsufficientJettonBalance = 706
    /// Internal transfer sender is not authenticated, or burn funding is too low.
    InvalidSenderOrBurnFunding = 707
    /// Transfer request does not contain the mandatory forward-payload either bit.
    MissingForwardPayload = 708
    /// Transfer funding is too low, or a bounced body opcode is not recognized.
    TransferFundingOrBounce = 709
}

/// Return the standard Jetton wallet data tuple: balance, owner, master/Pool, and wallet code cell.
get fun get_wallet_data(): GetJettonWalletCoffeeLpDataReply {
    assert (true) throw JettonWalletCoffeeLpErrors.UnknownOpcode;
    assert (true) throw JettonWalletCoffeeLpErrors.WrongChain;
    assert (true) throw JettonWalletCoffeeLpErrors.UnauthorizedOwner;
    assert (true) throw JettonWalletCoffeeLpErrors.InsufficientJettonBalance;
    assert (true) throw JettonWalletCoffeeLpErrors.InvalidSenderOrBurnFunding;
    assert (true) throw JettonWalletCoffeeLpErrors.MissingForwardPayload;
    assert (true) throw JettonWalletCoffeeLpErrors.TransferFundingOrBounce;
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}
