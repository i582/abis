/// STON.fi DEX core v1 LP Jetton wallet for holding liquidity tokens.
contract StonfiLpWalletV1 {
    author: "STON.fi"
    version: "1.0"
    description: "Curated interface for the STON.fi DEX core v1 LP Jetton wallet: standard Jetton wallet messages plus the LP burn callback"
    storage: StonfiLpWalletV1Storage
    incomingMessages: StonfiLpWalletV1IncomingMessage
    outgoingMessages: StonfiLpWalletV1OutgoingMessage
    forceAbiExport: StonfiLpWalletV1BouncedKnownBody
    thrownErrors: StonfiLpWalletV1Errors
}

/// Persistent LP Jetton wallet state stored in the root data cell.
struct StonfiLpWalletV1Storage {
    /// LP Jetton balance encoded as TL-B `Coins` in storage.
    balance: coins
    /// LP token owner authorized to initiate outgoing transfers and burns.
    ownerAddress: address
    /// LP Jetton master address; in STON.fi v1 this is the Pool contract.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell used to derive and authenticate peer wallets.
    jettonWalletCode: cell
}

/// Standard Jetton transfer request accepted by this LP wallet.
struct (0x0f8a7ea5) StonfiLpWalletV1Transfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// LP Jetton amount to debit from this wallet, in base units.
    amount: coins
    /// Destination owner whose deterministic LP wallet receives the transfer.
    destination: address
    /// Optional response address for an `excesses` refund.
    responseAddress: address?
    /// Optional referenced custom payload parsed for Jetton layout compatibility.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton internal transfer used between LP wallets and by the Pool when minting LP tokens.
struct (0x178d4519) StonfiLpWalletV1InternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// LP Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the sending wallet or Pool mint payload.
    fromAddress: address
    /// Optional response address for an `excesses` refund after processing.
    responseAddress: address?
    /// Nanotons forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// STON.fi LP burn request that burns liquidity tokens and triggers a Pool callback.
struct (0x595f07bc) StonfiLpWalletV1Burn {
    /// Caller-selected query id copied into the outgoing STON.fi burn notification.
    queryId: uint64
    /// Liquidity-token amount to burn, in base units.
    amount: coins
    /// Optional response address forwarded to the Pool burn callback.
    responseAddress: address?
}

/// Standard Jetton owner notification emitted when an incoming LP transfer carries forwarded TON.
struct (0x7362d09c) StonfiLpWalletV1TransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received LP Jetton amount in base units.
    amount: coins
    /// Source owner address reported by the internal transfer.
    fromAddress: address
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excesses response emitted when value remains after processing a transfer.
struct (0xd53276db) StonfiLpWalletV1Excesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// STON.fi burn callback emitted by the LP wallet to the Pool after an LP token burn.
struct (0x7bdd97de) StonfiLpWalletV1BurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned LP Jetton amount in base units.
    amount: coins
    /// LP owner address whose liquidity should be released.
    ownerAddress: address
    /// Optional response address forwarded from the burn request.
    responseAddress: address?
}

/// Bounced body prefix accepted by the LP wallet before checking the original opcode.
struct (0xffffffff) StonfiLpWalletV1BouncedKnownBody {
    /// Original bounced opcode; accepted values are `internal_transfer` or `burn_notification`.
    originalOpcode: uint32
    /// Query id from the bounced body.
    queryId: uint64
    /// LP Jetton amount restored to balance on accepted bounces.
    amount: coins
    /// Remaining bounced body bits/refs are ignored after the amount.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the STON.fi LP wallet.
type StonfiLpWalletV1IncomingMessage =
    | StonfiLpWalletV1Transfer
    | StonfiLpWalletV1InternalTransfer
    | StonfiLpWalletV1Burn

/// Internal message bodies emitted by the STON.fi LP wallet.
type StonfiLpWalletV1OutgoingMessage =
    | StonfiLpWalletV1InternalTransfer
    | StonfiLpWalletV1TransferNotification
    | StonfiLpWalletV1Excesses
    | StonfiLpWalletV1BurnNotification

/// Structured result returned by the standard Jetton wallet `get_wallet_data` getter.
struct GetStonfiLpWalletV1DataReply {
    /// LP Jetton balance returned as a TVM stack integer.
    balance: int
    /// LP token owner address.
    ownerAddress: address
    /// LP Jetton master address; in STON.fi v1 this is the Pool.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell.
    jettonWalletCode: cell
}

/// Source-level exit-code catalog for the STON.fi LP wallet.
enum StonfiLpWalletV1Errors {
    /// Sender is not the stored owner for transfer or burn requests.
    UnauthorizedOwner = 705
    /// Transfer or burn would make the stored LP Jetton balance negative.
    InsufficientJettonBalance = 706
    /// Internal transfer sender is not authenticated, or burn funding is too low.
    InvalidSenderOrBurnFunding = 707
    /// Transfer request is missing the required forward-payload discriminator bit.
    MissingForwardPayload = 708
    /// Transfer funding is too low, or a bounced body opcode is not recognized.
    TransferFundingOrBounce = 709
}

/// Return the standard Jetton wallet data tuple: balance, owner, master/Pool, and wallet code cell.
get fun get_wallet_data(): GetStonfiLpWalletV1DataReply {
    throw 0;
}
