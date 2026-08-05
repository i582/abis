/// Historical Moon.cx order revision identified by code hash `88c38d29…f6a6`.
contract MoonOrderNew {
    author: "Moon.cx"
    version: "88c38d29"
    description: "Newer Moon.cx limit-order revision that rejects Jetton-fill recipients matching either order wallet."
    storage: MoonOrderNewStorage
    storageAtDeployment: MoonOrderNewDeploymentStorage
    incomingMessages: MoonOrderNewIncomingMessage
    outgoingMessages: MoonOrderNewOutgoingMessage
    thrownErrors: MoonOrderNewErrors
    forceAbiExport: MoonOrderNewOrderParams
        | MoonOrderNewVestingState
        | MoonOrderNewAssets
        | MoonOrderNewWallets
        | MoonOrderNewFunding
        | MoonOrderNewJettonFillPayload
}

/// Header installed by the factory before the order accepts its deployment message.
struct MoonOrderNewDeploymentStorage {
    /// Factory allowed to initialize the order.
    factoryAddress: address
    /// User who created the order and may cancel it.
    creatorAddress: address
    /// Protocol-assigned order identifier.
    orderId: uint64
    /// Lifecycle status; the factory installs value 5 before initialization.
    status: uint8
}

/// Runtime state used after the factory's deployment message is accepted.
struct MoonOrderNewStorage {
    /// Factory that deployed the order and receives collected protocol fees.
    factoryAddress: address
    /// User who created the order and may cancel it.
    creatorAddress: address
    /// Protocol-assigned order identifier.
    orderId: uint64
    /// Lifecycle and asset-mode state maintained by the order.
    status: uint8
    /// Remaining amount of the offered asset.
    remainingAmount: coins
    /// Protocol fee deducted from fills, in basis points.
    orderFeeBps: uint8
    /// Protocol fee accumulated by completed or partial fills.
    accumulatedFee: coins
    /// Order parameters while active, or vesting state after a vested fill.
    stateData: cell
    /// Referenced identifiers of the offered and requested assets.
    assets: Cell<MoonOrderNewAssets>
    /// Referenced order wallets for the two assets.
    wallets: Cell<MoonOrderNewWallets>
    /// Optional Jetton wallet and amount retained from the factory deployment.
    funding: Cell<MoonOrderNewFunding>?
}

/// Fixed order terms stored in `stateData` while the order remains fillable.
struct MoonOrderNewOrderParams {
    /// Fixed-point conversion rate used by `get_fill_out`.
    rate: uint256
    /// Two-bit execution lock mode.
    lockMode: uint2
    /// Vesting duration in seconds; zero requests immediate payout.
    vestingDuration: uint64
}

/// Vesting data stored in `stateData` after a vested fill.
struct MoonOrderNewVestingState {
    /// Unix timestamp at which vesting started.
    startTime: uint64
    /// Vesting duration in seconds.
    duration: uint64
    /// Address that receives the vested payout.
    recipient: address
}

/// Asset master identifiers retained by the order.
struct MoonOrderNewAssets {
    /// Offered Jetton master, or `addr_none` for native GRAM.
    asset1: address?
    /// Requested Jetton master, or `addr_none` for native GRAM.
    asset2: address?
}

/// Asset wallet addresses retained by the order.
struct MoonOrderNewWallets {
    /// Order wallet for asset 1, or `addr_none` when asset 1 is native GRAM.
    asset1Wallet: address?
    /// Order wallet for asset 2, or `addr_none` when asset 2 is native GRAM.
    asset2Wallet: address?
}

/// Optional Jetton funding record supplied by the factory.
struct MoonOrderNewFunding {
    /// Jetton wallet that delivered the initial asset amount.
    sourceWallet: address
    /// Jetton amount received in elementary units.
    amount: coins
}

/// Creator request to cancel the remaining order amount.
struct (0x1e8d79c4) MoonOrderNewCancel {
    /// Query identifier copied into cancellation and excess responses.
    queryId: uint64
}

/// Direct native-GRAM request to fill the order.
struct (0x99b49842) MoonOrderNewFill {
    /// Query identifier propagated to payouts and refunds.
    queryId: uint64
    /// Address receiving the bought asset.
    recipient: address
    /// Optional body delivered with a Jetton payout.
    recipientPayload: Cell<RemainingBitsAndRefs>?
    /// Address receiving a rejected payment or excess GRAM.
    rejectAddress: address
}

/// Moon.cx fill payload carried inside a referenced Jetton notification payload.
struct (0x99b49842) MoonOrderNewJettonFillPayload {
    /// Address receiving the bought asset.
    recipient: address
    /// Optional body delivered with a Jetton payout.
    recipientPayload: Cell<RemainingBitsAndRefs>?
    /// Address receiving a rejected payment or excess GRAM.
    rejectAddress: address
}

/// Standard TEP-74 notification accepted for a Jetton-backed fill.
struct (0x7362d09c) MoonOrderNewJettonTransferNotification {
    /// Query identifier propagated to payouts and refunds.
    queryId: uint64
    /// Jetton amount received in elementary units.
    amount: coins
    /// Previous owner of the transferred Jettons.
    sender: address
    /// Either selector and referenced Moon.cx fill payload retained as raw bits and references.
    forwardPayload: RemainingBitsAndRefs
}

/// Asset-pipe callback that supplies one derived order-wallet address.
struct (0x98a42a2f) MoonOrderNewPipeWalletResolved {
    /// Query identifier propagated through wallet resolution.
    queryId: uint64
    /// Derived wallet address returned by the asset pipe.
    wallet: address
}

/// Factory initialization body received immediately after deployment.
struct (0x983432e2) MoonOrderNewDeploy {
    /// Query identifier copied from the create request.
    queryId: uint64
    /// Protocol fee in basis points.
    orderFeeBps: uint8
    /// Referenced rate, lock mode, and vesting duration.
    orderParams: Cell<MoonOrderNewOrderParams>
    /// Referenced asset master identifiers.
    assets: Cell<MoonOrderNewAssets>
    /// Referenced native or derived asset-wallet addresses.
    wallets: Cell<MoonOrderNewWallets>
    /// Initial Jetton source and amount, absent for a native-GRAM order.
    funding: Cell<MoonOrderNewFunding>?
}

/// Internal messages with exact published or code-proven layouts.
type MoonOrderNewIncomingMessage =
    | MoonOrderNewCancel
    | MoonOrderNewFill
    | MoonOrderNewJettonTransferNotification
    | MoonOrderNewPipeWalletResolved
    | MoonOrderNewDeploy

/// Fee-bearing notification sent to the factory for native-asset settlement.
struct (0x367ad406) MoonOrderNewFeeNotification {
    /// Query identifier propagated from the triggering request.
    queryId: uint64
}

/// Order registration sent to the factory after the first wallet is resolved.
struct (0x5b9f8449) MoonOrderNewFactoryRegistration {
    /// Query identifier propagated through wallet resolution.
    queryId: uint64
    /// Creator retained in the deployment header.
    creator: address
    /// Protocol-assigned order identifier.
    orderId: uint64
    /// Referenced pair of asset master identifiers.
    assets: Cell<MoonOrderNewAssets>
    /// Jetton wallet that supplied the initial funding.
    sourceWallet: address
    /// Initial Jetton amount in elementary units.
    amount: coins
}

/// Request sent to an asset pipe to derive this order's wallet.
struct (0xa5ee7822) MoonOrderNewPipeWalletRequest {
    /// Query identifier copied from factory deployment.
    queryId: uint64
    /// Address of this order contract.
    order: address
}

/// Two-word rejection body whose opcode is the protocol response code 510.
struct (0x000001fe) MoonOrderNewResponse510 {
    /// Query identifier copied from the rejected fill.
    queryId: uint64
}

/// Two-word rejection body whose opcode is the protocol response code 702.
struct (0x000002be) MoonOrderNewResponse702 {
    /// Query identifier copied from the rejected fill.
    queryId: uint64
}

/// Confirms that cancellation processing completed.
struct (0x49f48ee9) MoonOrderNewCancelled {
    /// Query identifier copied from the cancellation request.
    queryId: uint64
}

/// Confirms an immediate order payout.
struct (0x96612e37) MoonOrderNewPayout {
    /// Query identifier copied from the fill request.
    queryId: uint64
}

/// Confirms release of a completed vesting payout.
struct (0xb4fc3916) MoonOrderNewVestingPayout {
    /// Query identifier; permissionless external release uses the deployed constant 777.
    queryId: uint64
}

/// Standard TEP-74 transfer emitted for payouts and Jetton refunds.
struct (0x0f8a7ea5) MoonOrderNewJettonTransfer {
    /// Query identifier propagated from the triggering request.
    queryId: uint64
    /// Jetton amount transferred in elementary units.
    amount: coins
    /// Destination owner of the transferred Jettons.
    destination: address
    /// Address that receives unused GRAM from the destination wallet.
    responseDestination: address
    /// Optional Jetton-wallet custom payload; the newer revision emits none.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// GRAM amount forwarded with the transfer notification.
    forwardTonAmount: coins
    /// Inline or referenced forward payload retained as raw bits and references.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response.
struct (0xd53276db) MoonOrderNewExcess {
    /// Query identifier copied from the request.
    queryId: uint64
}

/// Outgoing messages with exact published or code-proven layouts.
type MoonOrderNewOutgoingMessage =
    | MoonOrderNewFeeNotification
    | MoonOrderNewFactoryRegistration
    | MoonOrderNewPipeWalletRequest
    | MoonOrderNewResponse510
    | MoonOrderNewResponse702
    | MoonOrderNewCancelled
    | MoonOrderNewPayout
    | MoonOrderNewVestingPayout
    | MoonOrderNewJettonTransfer
    | MoonOrderNewExcess

/// Structured result returned by `get_vesting_data` after a vested fill.
struct MoonOrderNewVestingDataReply {
    /// Unix timestamp at which vesting started.
    vestingStartTime: uint64
    /// Vesting duration in seconds.
    vestingDuration: uint64
    /// Address that receives the vested payout.
    recipient: address
}

/// Exit codes thrown by the exact newer order revision.
enum MoonOrderNewErrors {
    /// Sender or Jetton wallet is not authorized for the requested transition.
    UnauthorizedSender = 300
    /// Vesting release is unavailable or has not matured.
    VestingUnavailable = 410
    /// Attached GRAM does not cover the operation's processing budget.
    InsufficientAttachedValue = 500
    /// Attached GRAM does not cover the requested settlement path.
    InsufficientSettlementValue = 510
}

/// Return the current lifecycle and asset-mode status.
get fun get_status(): uint8 {
    throw 0;
}

/// Return the remaining offered-asset amount.
get fun get_order_amount(): int {
    throw 0;
}

/// Return the complete raw persistent data cell.
get fun get_order(): cell {
    throw 0;
}

/// Return the referenced asset-wallet pair cell.
get fun get_wallets(): cell {
    throw 0;
}

/// Return vesting start, duration, and recipient after a vested fill.
get fun get_vesting_data(): MoonOrderNewVestingDataReply {
    throw 0;
}

/// Quote the net offered-asset output for a requested input amount.
get fun get_fill_out(amountIn: int): int {
    throw 0;
}

/// Return the referenced asset-master pair cell.
get fun get_assets(): cell {
    throw 0;
}
