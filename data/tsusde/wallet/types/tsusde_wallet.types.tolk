/// Ethena tsUSDe Jetton wallet with governed lock status and a second timelocked balance.
contract TsusdeWallet {
    author: "Ethena / LayerZero Labs"
    description: "tsUSDe Wallet extends the governed Jetton wallet with timelocked mint and two-step redemption flows."
    storage: TsusdeWalletStorage
    incomingMessages: TsusdeWalletIncomingMessage
    outgoingMessages: TsusdeWalletOutgoingMessage
    forceAbiExport: TsusdeWalletBouncedKnownBody
    thrownErrors: TsusdeWalletErrors
}

/// Complete persistent state stored by the live tsUSDe wallet.
struct TsusdeWalletStorage {
    /// Four-bit lock mask: bit 0 blocks outgoing transfers and bit 1 blocks incoming transfers.
    status: uint4
    /// Ordinary tsUSDe balance encoded as TL-B `Coins`.
    balance: coins
    /// Owner authorized to request ordinary or timelocked transfers.
    ownerAddress: address
    /// tsUSDe Jetton minter authorized to mint, burn, and update wallet status.
    jettonMasterAddress: address
    /// Asset-denominated balance held until the redemption timelock expires.
    timelockedBalance: coins
    /// Unix timestamp after which the timelocked balance may be returned to the minter.
    timelockLimit: uint64
}

/// Owner- or minter-originated ordinary Jetton transfer request.
struct (0x0f8a7ea5) TsusdeWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// Ordinary tsUSDe amount to debit, in base units.
    amount: coins
    /// Destination owner whose deterministic wallet receives the transfer.
    destination: address
    /// Optional address that receives excess GRAM after processing.
    responseDestination: address?
    /// Optional referenced custom payload; source validates its shape and ignores its content.
    customPayload: cell?
    /// GRAM forwarded with a transfer notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner- or minter-originated request to return matured timelocked assets to the master.
struct (0xd750cec9) TsusdeWalletTransferTimelocked {
    /// Caller-selected query id copied into the outgoing timelocked internal transfer.
    queryId: uint64
    /// Matured timelocked amount to debit, in base units.
    amount: coins
    /// Destination owner address; source requires it to equal the stored master address.
    destination: address
    /// Optional address that receives excess GRAM after processing.
    responseDestination: address?
    /// Optional referenced custom payload; source validates its shape and ignores its content.
    customPayload: cell?
    /// GRAM forwarded to the master-side redemption flow.
    forwardTonAmount: coins
    /// Raw TEP-74 payload wrapped by the wallet with the redemption-step flag.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or minter-to-wallet ordinary internal transfer.
struct (0x178d4519) TsusdeWalletInternalTransfer {
    /// Query id copied from the original transfer or mint request.
    queryId: uint64
    /// Amount credited to the ordinary wallet balance.
    amount: coins
    /// Timelock field retained for wire compatibility and ignored for ordinary transfers.
    timelockLimit: uint64
    /// Source owner address reported by the sending wallet or minter.
    from: address?
    /// Optional address that receives excess GRAM after processing.
    responseAddress: address?
    /// GRAM forwarded with the owner transfer notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Master-to-wallet transfer that credits the separate timelocked balance.
struct (0xb2583ed5) TsusdeWalletInternalTransferTimelocked {
    /// Query id copied from the master mint request.
    queryId: uint64
    /// Amount credited to the timelocked wallet balance.
    amount: coins
    /// Unix timestamp after which the balance may be sent back to the master.
    timelockLimit: uint64
    /// Source owner address reported by the master.
    from: address?
    /// Optional address that receives excess GRAM after processing.
    responseAddress: address?
    /// Raw tail ignored by the receiver; the canonical sender includes forward GRAM and payload fields.
    remainder: RemainingBitsAndRefs
}

/// Master-originated burn request for the ordinary balance.
struct (0x595f07bc) TsusdeWalletBurn {
    /// Caller-selected query id copied into the burn notification.
    queryId: uint64
    /// Ordinary tsUSDe amount to burn, in base units.
    amount: coins
    /// Optional address that receives excess GRAM after master processing.
    responseDestination: address?
    /// Optional referenced custom payload; source validates its shape and ignores its content.
    customPayload: cell?
}

/// Master-originated update of the four-bit transfer lock mask.
struct (0xeed236d3) TsusdeWalletSetStatus {
    /// Caller-selected query id consumed before the status field.
    queryId: uint64
    /// Replacement four-bit lock mask.
    status: uint4
}

/// Funding-only message accepted without changing wallet state.
struct (0xd372158c) TsusdeWalletTopUp {
    /// Arbitrary body tail ignored by the implementation after reading the opcode.
    remainder: RemainingBitsAndRefs
}

/// Burn notification emitted to the tsUSDe minter.
struct (0x7bdd97de) TsusdeWalletBurnNotification {
    /// Query id copied from the burn request.
    queryId: uint64
    /// Burned ordinary tsUSDe amount.
    amount: coins
    /// Wallet owner reported to the minter.
    sender: address
    /// Optional address that receives excess GRAM after master processing.
    responseDestination: address?
}

/// Owner notification emitted after a funded ordinary internal transfer.
struct (0x7362d09c) TsusdeWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Ordinary tsUSDe amount credited to the wallet.
    amount: coins
    /// Source owner reported by the internal transfer.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard response emitted when excess GRAM remains after transfer processing.
struct (0xd53276db) TsusdeWalletExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Bounced debit body whose amount is restored to the ordinary or timelocked balance.
struct (0xffffffff) TsusdeWalletBouncedKnownBody {
    /// Original operation: ordinary transfer, timelocked transfer, or burn notification.
    originalOpcode: uint32
    /// Query id copied from the bounced operation.
    queryId: uint64
    /// Jetton amount restored by the bounce handler.
    amount: coins
    /// Remaining truncated fields of the original bounced body.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the tsUSDe wallet.
type TsusdeWalletIncomingMessage =
    | TsusdeWalletTransfer
    | TsusdeWalletTransferTimelocked
    | TsusdeWalletInternalTransfer
    | TsusdeWalletInternalTransferTimelocked
    | TsusdeWalletBurn
    | TsusdeWalletSetStatus
    | TsusdeWalletTopUp

/// Internal message bodies emitted by the tsUSDe wallet.
type TsusdeWalletOutgoingMessage =
    | TsusdeWalletInternalTransfer
    | TsusdeWalletInternalTransferTimelocked
    | TsusdeWalletBurnNotification
    | TsusdeWalletTransferNotification
    | TsusdeWalletExcesses

/// Structured stack result returned by `get_wallet_data`.
struct GetTsusdeWalletDataReply {
    /// Ordinary tsUSDe balance.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// tsUSDe Jetton minter address.
    jettonMasterAddress: address
    /// Current wallet code cell.
    jettonWalletCode: cell
}

/// Structured stack result returned by `get_timelock_data`.
struct GetTsusdeWalletTimelockDataReply {
    /// Balance held until the stored timelock limit expires.
    timelockedBalance: int
    /// Unix timestamp after which the timelocked balance may be redeemed.
    timelockLimit: int
}

/// Exit-code catalog derived from the exact verified tsUSDe wallet source.
enum TsusdeWalletErrors {
    /// Current lock mask blocks the attempted incoming or outgoing transfer.
    ContractLocked = 45
    /// Transfer or burn would make an ordinary or timelocked token balance negative.
    InsufficientJettonBalance = 47
    /// Attached GRAM is below the transfer or burn fee budget.
    NotEnoughGas = 48
    /// TEP-74 forward payload has an invalid `Either` shape.
    InvalidMessage = 49
    /// Opcode or message kind is invalid for the current dispatch path.
    InvalidOperation = 72
    /// Caller is neither the stored owner nor the minter where required.
    NotOwner = 73
    /// Internal transfer or status sender is not an authenticated wallet or minter.
    InvalidWallet = 74
    /// Timelocked transfer destination is not the stored minter.
    NotMinter = 75
    /// Destination owner belongs to an unsupported workchain.
    WrongWorkchain = 333
    /// Timelocked redemption was requested before the stored deadline.
    TimelockNotPassed = 334
    /// Incoming opcode or bounced outgoing opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return ordinary balance, owner, master, and the current wallet code cell.
get fun get_wallet_data(): GetTsusdeWalletDataReply {
    throw 0;
}

/// Return the current four-bit incoming/outgoing transfer lock mask.
get fun get_status(): uint4 {
    throw 0;
}

/// Return the timelocked balance and its redemption deadline.
get fun get_timelock_data(): GetTsusdeWalletTimelockDataReply {
    throw 0;
}
