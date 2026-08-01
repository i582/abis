/// Historical Moon.cx order revision identified by code hash `ee07140b…e226`.
contract MoonOrderOld {
    author: "Moon.cx"
    version: "ee07140b"
    description: "Earlier deployed Moon.cx limit-order revision with direct and Jetton settlement paths."
    storage: MoonOrderOldStorage
    storageAtDeployment: MoonOrderOldDeploymentStorage
    incomingMessages: MoonOrderOldIncomingMessage
    outgoingMessages: MoonOrderOldOutgoingMessage
    thrownErrors: MoonOrderOldErrors
    forceAbiExport: MoonOrderOldOrderParams
        | MoonOrderOldVestingState
        | MoonOrderOldAssets
        | MoonOrderOldWallets
        | MoonOrderOldFunding
        | MoonOrderOldJettonFillPayload
}

/// Header installed by the factory before the order accepts its deployment message.
struct MoonOrderOldDeploymentStorage {
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
struct MoonOrderOldStorage {
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
    assets: Cell<MoonOrderOldAssets>
    /// Referenced order wallets for the two assets.
    wallets: Cell<MoonOrderOldWallets>
    /// Optional Jetton wallet and amount retained from the factory deployment.
    funding: Cell<MoonOrderOldFunding>?
}

/// Fixed order terms stored in `stateData` while the order remains fillable.
struct MoonOrderOldOrderParams {
    /// Fixed-point conversion rate used by `get_fill_out`.
    rate: uint256
    /// Two-bit execution lock mode.
    lockMode: uint2
    /// Vesting duration in seconds; zero requests immediate payout.
    vestingDuration: uint64
}

/// Vesting data stored in `stateData` after a vested fill.
struct MoonOrderOldVestingState {
    /// Unix timestamp at which vesting started.
    startTime: uint64
    /// Vesting duration in seconds.
    duration: uint64
    /// Address that receives the vested payout.
    recipient: address
}

/// Asset master identifiers retained by the order.
struct MoonOrderOldAssets {
    /// Offered Jetton master, or `addr_none` for native TON.
    asset1: address?
    /// Requested Jetton master, or `addr_none` for native TON.
    asset2: address?
}

/// Asset wallet addresses retained by the order.
struct MoonOrderOldWallets {
    /// Order wallet for asset 1, or `addr_none` when asset 1 is native TON.
    asset1Wallet: address?
    /// Order wallet for asset 2, or `addr_none` when asset 2 is native TON.
    asset2Wallet: address?
}

/// Optional Jetton funding record supplied by the factory.
struct MoonOrderOldFunding {
    /// Jetton wallet that delivered the initial asset amount.
    sourceWallet: address
    /// Jetton amount received in elementary units.
    amount: coins
}

/// Creator request to cancel the remaining order amount.
struct (0x1e8d79c4) MoonOrderOldCancel {
    /// Query identifier copied into cancellation and excess responses.
    queryId: uint64
}

/// Direct native-TON request to fill the order.
struct (0x99b49842) MoonOrderOldFill {
    /// Query identifier propagated to payouts and refunds.
    queryId: uint64
    /// Address receiving the bought asset.
    recipient: address
    /// Optional body delivered with a Jetton payout.
    recipientPayload: Cell<RemainingBitsAndRefs>?
    /// Address receiving a rejected payment or excess TON.
    rejectAddress: address
}

/// Moon.cx fill payload carried inside a referenced Jetton notification payload.
struct (0x99b49842) MoonOrderOldJettonFillPayload {
    /// Address receiving the bought asset.
    recipient: address
    /// Optional body delivered with a Jetton payout.
    recipientPayload: Cell<RemainingBitsAndRefs>?
    /// Address receiving a rejected payment or excess TON.
    rejectAddress: address
}

/// Standard TEP-74 notification accepted for a Jetton-backed fill.
struct (0x7362d09c) MoonOrderOldJettonTransferNotification {
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
struct (0x98a42a2f) MoonOrderOldPipeWalletResolved {
    /// Query identifier propagated through wallet resolution.
    queryId: uint64
    /// Derived wallet address returned by the asset pipe.
    wallet: address
}

/// Factory initialization body received immediately after deployment.
struct (0x983432e2) MoonOrderOldDeploy {
    /// Query identifier copied from the create request.
    queryId: uint64
    /// Protocol fee in basis points.
    orderFeeBps: uint8
    /// Referenced rate, lock mode, and vesting duration.
    orderParams: Cell<MoonOrderOldOrderParams>
    /// Referenced asset master identifiers.
    assets: Cell<MoonOrderOldAssets>
    /// Referenced native or derived asset-wallet addresses.
    wallets: Cell<MoonOrderOldWallets>
    /// Initial Jetton source and amount, absent for a native-TON order.
    funding: Cell<MoonOrderOldFunding>?
}

/// Internal messages with exact published or code-proven layouts.
type MoonOrderOldIncomingMessage =
    | MoonOrderOldCancel
    | MoonOrderOldFill
    | MoonOrderOldJettonTransferNotification
    | MoonOrderOldPipeWalletResolved
    | MoonOrderOldDeploy

/// Fee-bearing notification sent to the factory for native-asset settlement.
struct (0x367ad406) MoonOrderOldFeeNotification {
    /// Query identifier propagated from the triggering request.
    queryId: uint64
}

/// Order registration sent to the factory after the first wallet is resolved.
struct (0x5b9f8449) MoonOrderOldFactoryRegistration {
    /// Query identifier propagated through wallet resolution.
    queryId: uint64
    /// Creator retained in the deployment header.
    creator: address
    /// Protocol-assigned order identifier.
    orderId: uint64
    /// Referenced pair of asset master identifiers.
    assets: Cell<MoonOrderOldAssets>
    /// Jetton wallet that supplied the initial funding.
    sourceWallet: address
    /// Initial Jetton amount in elementary units.
    amount: coins
}

/// Request sent to an asset pipe to derive this order's wallet.
struct (0xa5ee7822) MoonOrderOldPipeWalletRequest {
    /// Query identifier copied from factory deployment.
    queryId: uint64
    /// Address of this order contract.
    order: address
}

/// Two-word rejection body whose opcode is the protocol response code 510.
struct (0x000001fe) MoonOrderOldResponse510 {
    /// Query identifier copied from the rejected fill.
    queryId: uint64
}

/// Two-word rejection body whose opcode is the protocol response code 702.
struct (0x000002be) MoonOrderOldResponse702 {
    /// Query identifier copied from the rejected fill.
    queryId: uint64
}

/// Confirms that cancellation processing completed.
struct (0x49f48ee9) MoonOrderOldCancelled {
    /// Query identifier copied from the cancellation request.
    queryId: uint64
}

/// Confirms an immediate order payout.
struct (0x96612e37) MoonOrderOldPayout {
    /// Query identifier copied from the fill request.
    queryId: uint64
}

/// Confirms release of a completed vesting payout.
struct (0xb4fc3916) MoonOrderOldVestingPayout {
    /// Query identifier; permissionless external release uses the deployed constant 777.
    queryId: uint64
}

/// Standard TEP-74 transfer emitted for payouts and Jetton refunds.
struct (0x0f8a7ea5) MoonOrderOldJettonTransfer {
    /// Query identifier propagated from the triggering request.
    queryId: uint64
    /// Jetton amount transferred in elementary units.
    amount: coins
    /// Destination owner of the transferred Jettons.
    destination: address
    /// Address that receives unused TON from the destination wallet.
    responseDestination: address
    /// Optional Jetton-wallet custom payload; this revision emits none.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// TON amount forwarded with the transfer notification.
    forwardTonAmount: coins
    /// Inline or referenced forward payload retained as raw bits and references.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response.
struct (0xd53276db) MoonOrderOldExcess {
    /// Query identifier copied from the request.
    queryId: uint64
}

/// Outgoing messages with exact published or code-proven layouts.
type MoonOrderOldOutgoingMessage =
    | MoonOrderOldFeeNotification
    | MoonOrderOldFactoryRegistration
    | MoonOrderOldPipeWalletRequest
    | MoonOrderOldResponse510
    | MoonOrderOldResponse702
    | MoonOrderOldCancelled
    | MoonOrderOldPayout
    | MoonOrderOldVestingPayout
    | MoonOrderOldJettonTransfer
    | MoonOrderOldExcess

/// Structured result returned by `get_vesting_data` after a vested fill.
struct MoonOrderOldVestingDataReply {
    /// Unix timestamp at which vesting started.
    vestingStartTime: uint64
    /// Vesting duration in seconds.
    vestingDuration: uint64
    /// Address that receives the vested payout.
    recipient: address
}

/// Exit codes thrown by the exact earlier order revision.
enum MoonOrderOldErrors {
    /// Sender or Jetton wallet is not authorized for the requested transition.
    UnauthorizedSender = 300
    /// Vesting release is unavailable or has not matured.
    VestingUnavailable = 410
    /// Attached TON does not cover the operation's processing budget.
    InsufficientAttachedValue = 500
    /// Attached TON does not cover the requested settlement path.
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
get fun get_vesting_data(): MoonOrderOldVestingDataReply {
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
