/// Persistent state shared by TonFun bonding-curve Jetton wallet revisions.
struct TonFunBclWalletStorage {
    /// Transfer lock status: zero is locked and one permits owner transfers.
    status: uint4
    /// Jetton balance held for the wallet owner, in base units.
    balance: coins
    /// Owner authorized to transfer, burn, sell, or request unlocking.
    ownerAddress: address
    /// Jetton master that authenticates mint and unlock-confirmation messages.
    jettonMasterAddress: address
}

/// Owner-originated TEP-74 transfer request.
struct (0x0f8a7ea5) TonFunBclWalletTransfer {
    /// Caller-selected identifier copied into downstream messages.
    queryId: uint64
    /// Jetton amount debited from the wallet balance.
    amount: coins
    /// Owner address whose deterministic wallet receives the transfer.
    destination: address
    /// Optional destination for returned excess GRAM.
    responseDestination: address?
    /// Optional referenced application payload ignored by the wallet.
    customPayload: cell?
    /// Nanograms forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or master-to-wallet TEP-74 internal transfer.
struct (0x178d4519) TonFunBclWalletInternalTransfer {
    /// Query identifier copied from the originating transfer or mint operation.
    queryId: uint64
    /// Jetton amount credited to the wallet balance.
    amount: coins
    /// Source owner, or `addr_none` for a master-originated mint.
    fromAddress: address?
    /// Optional destination for returned excess GRAM.
    responseAddress: address?
    /// Nanograms forwarded to the receiving owner.
    forwardTonAmount: coins
    /// TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated TEP-74 burn request.
struct (0x595f07bc) TonFunBclWalletBurn {
    /// Caller-selected identifier copied into the burn notification.
    queryId: uint64
    /// Jetton amount removed from the wallet balance.
    amount: coins
    /// Optional destination for excess GRAM returned by the master.
    responseDestination: address?
    /// Optional referenced application payload ignored by the wallet.
    customPayload: cell?
}

/// Funding-only message accepted without changing wallet state.
struct (0xd372158c) TonFunBclWalletTopUp {
    /// Arbitrary body tail ignored after the opcode.
    remainder: RemainingBitsAndRefs
}

/// Owner request to sell Jettons through the bonding-curve master.
struct (0x742b36d8) TonFunBclWalletSell {
    /// Caller-selected identifier copied into the master notification.
    queryId: uint64
    /// Jetton amount removed from the wallet balance for sale.
    amount: coins
    /// Minimum GRAM amount accepted from the bonding curve.
    minReceiveAmount: coins
    /// Optional referenced referral data forwarded unchanged to the master.
    referral: cell?
}

/// Owner request to unlock a transfer-locked wallet through the master.
struct (0x9d65e47a) TonFunBclWalletUnlock {
    /// Caller-selected identifier copied into the unlock callback.
    queryId: uint64
}

/// Transfer notification emitted to the receiving wallet owner.
struct (0x7362d09c) TonFunBclWalletTransferNotification {
    /// Query identifier copied from the internal transfer.
    queryId: uint64
    /// Jetton amount credited to the wallet.
    amount: coins
    /// Source owner, or `addr_none` for a master-originated mint.
    senderAddress: address?
    /// TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response.
struct (0xd53276db) TonFunBclWalletExcesses {
    /// Query identifier associated with the returned GRAM.
    queryId: uint64
}

/// Burn notification emitted to the Jetton master.
struct (0x7bdd97de) TonFunBclWalletBurnNotification {
    /// Query identifier copied from the burn request.
    queryId: uint64
    /// Burned Jetton amount.
    amount: coins
    /// Wallet owner reported to the master.
    ownerAddress: address
    /// Optional destination for excess GRAM returned by the master.
    responseDestination: address?
}

/// Sell notification emitted to the bonding-curve master.
struct (0x68e870fe) TonFunBclWalletSellNotification {
    /// Query identifier copied from the sell request.
    queryId: uint64
    /// Jetton amount removed from the wallet balance.
    amount: coins
    /// Minimum GRAM amount accepted by the owner.
    minReceiveAmount: coins
    /// Wallet owner that initiated the sale.
    ownerAddress: address
    /// Optional referenced referral data copied from the request.
    referral: cell?
}

/// Unlock callback emitted to the bonding-curve master.
struct (0x4d583549) TonFunBclWalletUnlockCallback {
    /// Query identifier copied from the owner request.
    queryId: uint64
    /// Wallet owner requesting transfer unlock.
    ownerAddress: address
}

/// Bounced debit operation whose Jetton amount is restored to storage.
struct (0xffffffff) TonFunBclWalletBouncedKnownBody {
    /// Original operation: internal transfer, burn notification, or sell notification.
    originalOpcode: uint32
    /// Query identifier copied from the bounced operation.
    queryId: uint64
    /// Jetton amount restored to the wallet balance.
    amount: coins
    /// Remaining fields of the original bounced body.
    tail: RemainingBitsAndRefs
}

/// Structured stack result returned by `get_wallet_data`.
struct GetTonFunBclWalletDataReply {
    /// Current Jetton balance.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// Jetton master address.
    jettonMasterAddress: address
    /// Current wallet code cell.
    jettonWalletCode: cell
}

/// Exit codes shared by TonFun BCL wallet revisions.
enum TonFunBclWalletErrors {
    /// Transfer, burn, or sell would make the Jetton balance negative.
    InsufficientJettonBalance = 47
    /// Attached GRAM does not cover the transfer, burn, sell, or unlock fee budget.
    NotEnoughGas = 48
    /// TEP-74 forward payload has an invalid `Either` shape.
    InvalidMessage = 49
    /// Caller is not the stored owner for a standard transfer or burn.
    NotOwner = 73
    /// Destination owner belongs to an unsupported workchain.
    WrongWorkchain = 333
    /// Caller is not the stored owner for a sell or unlock request.
    UnauthorizedCustomOperation = 705
    /// Sell amount exceeds the stored Jetton balance.
    InsufficientSellBalance = 706
    /// Unlock confirmation did not originate from the stored master.
    InvalidUnlockConfirmationSender = 707
    /// Owner transfer is disabled while the wallet status is locked.
    TransfersLocked = 710
    /// Internal transfer sender is neither the master nor a deterministic peer wallet.
    InvalidWalletSender = 713
    /// Owner requested unlock after the wallet was already unlocked.
    WalletAlreadyUnlocked = 777
    /// Incoming opcode or bounced operation is unsupported.
    UnsupportedOperation = 65535
}
