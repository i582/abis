/// STON.fi DEX core v2 LP Jetton wallet for holding liquidity tokens, with the STON.fi burn extension.
contract StonfiLpWalletV2 {
    author: "STON.fi"
    version: "2.0"
    description: "Curated interface for the STON.fi DEX core v2 LP Jetton wallet: standard Jetton wallet messages plus the LP burn extension"
    storage: StonfiLpWalletV2Storage
    incomingMessages: StonfiLpWalletV2IncomingMessage
    outgoingMessages: StonfiLpWalletV2OutgoingMessage
    forceAbiExport: StonfiLpWalletV2BouncedKnownBody
    thrownErrors: StonfiLpWalletV2Errors
}

/// Persistent LP Jetton wallet state stored in the root data cell.
struct StonfiLpWalletV2Storage {
    /// LP Jetton balance encoded as TL-B `Coins` in storage.
    balance: coins
    /// LP token owner authorized to initiate outgoing transfers and burns.
    ownerAddress: address
    /// LP Jetton master address; for STON.fi this is the Pool contract.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell used to derive and authenticate peer wallets.
    jettonWalletCode: cell
}

/// Standard Jetton transfer request accepted by this LP wallet; STON.fi docs describe only LP-specific additions.
struct (0x0f8a7ea5) StonfiLpWalletV2Transfer {
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
struct (0x178d4519) StonfiLpWalletV2InternalTransfer {
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
struct (0x595f07bc) StonfiLpWalletV2Burn {
    /// Caller-selected query id copied into the outgoing STON.fi burn notification.
    queryId: uint64
    /// Liquidity-token amount to burn, in basic token units.
    amount: coins
    /// Docs call this `response_destination`; source forwards it, while Pool-side burn handling requires `addr_none`.
    responseAddress: address?
    /// Docs call this `custom_payloads`: a maybe-ref cell with `payload_0` and `payload_1` maybe refs for token0/token1.
    customPayload: cell?
}

/// Standard Jetton owner notification emitted when an incoming LP transfer carries forwarded TON.
struct (0x7362d09c) StonfiLpWalletV2TransferNotification {
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
struct (0xd53276db) StonfiLpWalletV2Excesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// STON.fi internal transaction emitted by the LP wallet to the Pool after an LP token burn.
struct (0x297437cf) StonfiLpWalletV2BurnNotificationExt {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned LP Jetton amount in base units.
    amount: coins
    /// LP owner address whose liquidity should be released.
    fromAddress: address
    /// Response address forwarded from the burn request; Pool source accepts only `addr_none`.
    responseAddress: address?
    /// Optional docs `custom_payloads` ref; Pool treats two maybe refs as token0 `payload_0` and token1 `payload_1`.
    customPayload: cell?
}

/// Bounced body prefix accepted by the LP wallet before checking the original opcode.
struct (0xffffffff) StonfiLpWalletV2BouncedKnownBody {
    /// Original bounced opcode; source accepts `internal_transfer` or `burn_notification_ext`.
    originalOpcode: uint32
    /// Query id from the bounced body.
    queryId: uint64
    /// LP Jetton amount restored to balance on accepted bounces.
    amount: coins
    /// Remaining bounced body bits/refs are ignored by source after the amount.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the STON.fi LP wallet.
type StonfiLpWalletV2IncomingMessage =
    | StonfiLpWalletV2Transfer
    | StonfiLpWalletV2InternalTransfer
    | StonfiLpWalletV2Burn

/// Internal message bodies emitted by the STON.fi LP wallet.
type StonfiLpWalletV2OutgoingMessage =
    | StonfiLpWalletV2InternalTransfer
    | StonfiLpWalletV2TransferNotification
    | StonfiLpWalletV2Excesses
    | StonfiLpWalletV2BurnNotificationExt

/// Structured result returned by the standard Jetton wallet `get_wallet_data` getter.
struct GetStonfiLpWalletV2DataReply {
    /// LP Jetton balance returned as a TVM stack integer.
    balance: int
    /// LP token owner address.
    ownerAddress: address
    /// LP Jetton master address; in STON.fi v2 this is the Pool.
    jettonMasterAddress: address
    /// Referenced LP wallet code cell.
    jettonWalletCode: cell
}

/// Source-level exit-code catalog for the STON.fi LP wallet.
enum StonfiLpWalletV2Errors {
    /// Transfer destination owner is outside the configured base workchain.
    WrongWorkchain = 85
    /// Sender is not the stored owner for transfer or burn requests.
    UnauthorizedOwner = 705
    /// Transfer or burn would make the stored LP Jetton balance negative.
    InsufficientJettonBalance = 706
    /// Internal transfer sender is not authenticated, or burn funding is too low.
    InvalidSenderOrBurnFunding = 707
    /// Transfer funding is too low, or a bounced body opcode is not recognized.
    TransferFundingOrBounce = 709
    /// Incoming internal message opcode is not supported by the wallet.
    UnsupportedOperation = 65535
}

/// Return the standard Jetton wallet data tuple: balance, owner, master/Pool, and wallet code cell.
get fun get_wallet_data(): GetStonfiLpWalletV2DataReply {
    throw 0;
}
