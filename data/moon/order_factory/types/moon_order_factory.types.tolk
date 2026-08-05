/// Historical Moon.cx order factory identified by code hash `d04737d6…4704`.
contract MoonOrderFactory {
    author: "Moon.cx"
    version: "d04737d6"
    description: "Moon.cx factory that derives asset pipes and deploys limit-order contracts."
    storage: MoonOrderFactoryStorage
    incomingMessages: MoonOrderFactoryIncomingMessage
    outgoingMessages: MoonOrderFactoryOutgoingMessage
    thrownErrors: MoonOrderFactoryErrors
    forceAbiExport: MoonOrderFactoryOrderParams
        | MoonOrderFactoryAssets
        | MoonOrderFactoryWallets
        | MoonOrderFactoryFunding
        | MoonOrderFactoryJettonCreatePayload
        | MoonOrderFactoryUpgradeStorage
}

/// Persistent factory state recovered from the exact deployed code and live data cell.
struct MoonOrderFactoryStorage {
    /// Administrative address accepted by the code and configuration update handlers.
    adminAddress: address
    /// Address authorized to request deployment of the per-asset pipe contracts.
    pipeDeploymentAuthority: address
    /// Last protocol-assigned order identifier; the next deployment increments this value.
    lastOrderId: uint64
    /// Fee copied into every newly deployed order, in basis points.
    orderFeeBps: uint8
    /// Code used to derive and deploy the per-asset pipe contracts.
    pipeCode: cell
    /// Code used to derive and deploy Moon.cx order contracts.
    orderCode: cell
}

/// Immutable price, lock mode, and vesting duration supplied when an order is created.
struct MoonOrderFactoryOrderParams {
    /// Fixed-point order rate used by the deployed order's amount conversion formula.
    rate: uint256
    /// Two-bit execution lock mode retained by the order.
    lockMode: uint2
    /// Vesting duration in seconds; zero requests an immediate payout.
    vestingDuration: uint64
}

/// Asset master identifiers stored in the deployed order.
struct MoonOrderFactoryAssets {
    /// First asset Jetton master, or `addr_none` for native GRAM.
    asset1: address?
    /// Second asset Jetton master, or `addr_none` for native GRAM.
    asset2: address?
}

/// Asset wallet addresses stored in the deployed order.
struct MoonOrderFactoryWallets {
    /// Order wallet for asset 1, or `addr_none` when asset 1 is native GRAM.
    asset1Wallet: address?
    /// Order wallet for asset 2, or `addr_none` when asset 2 is native GRAM.
    asset2Wallet: address?
}

/// Optional Jetton funding record attached to a Jetton-backed order deployment.
struct MoonOrderFactoryFunding {
    /// Jetton wallet that delivered the initial asset amount.
    sourceWallet: address
    /// Jetton amount received in elementary units.
    amount: coins
}

/// Replacement factory configuration installed together with upgraded code.
struct MoonOrderFactoryUpgradeStorage {
    /// Administrative address installed by the upgrade.
    adminAddress: address
    /// Address authorized to request pipe deployment after the upgrade.
    pipeDeploymentAuthority: address
    /// Fee copied into subsequently deployed orders, in basis points.
    orderFeeBps: uint8
    /// Pipe code installed by the upgrade.
    pipeCode: Cell<RemainingBitsAndRefs>
    /// Order code installed by the upgrade.
    orderCode: Cell<RemainingBitsAndRefs>
}

/// Fee-bearing order notification accepted and intentionally ignored by this factory revision.
struct (0x367ad406) MoonOrderFactoryFeeNotification {
    /// Query identifier propagated by the order.
    queryId: uint64
}

/// Authorized request to derive and deploy an asset pipe.
struct (0x5f096532) MoonOrderFactoryDeployPipeRequest {
    /// Query identifier copied into the pipe initialization body.
    queryId: uint64
    /// Asset master for which the pipe is derived.
    asset: address
    /// First opaque pipe configuration reference.
    config0: Cell<RemainingBitsAndRefs>
    /// Second opaque pipe configuration reference.
    config1: Cell<RemainingBitsAndRefs>
}

/// Order registration emitted after its first asset wallet is resolved.
struct (0x5b9f8449) MoonOrderFactoryRegisterOrder {
    /// Query identifier propagated by the order.
    queryId: uint64
    /// Creator retained in the order deployment header.
    creator: address
    /// Protocol-assigned order identifier.
    orderId: uint64
    /// Referenced pair of asset master identifiers.
    assets: Cell<MoonOrderFactoryAssets>
    /// Jetton wallet that supplied the initial funding.
    sourceWallet: address
    /// Initial Jetton amount in elementary units.
    amount: coins
}

/// Administrative request that forwards two opaque references to another contract.
struct (0x70acb3f0) MoonOrderFactoryForwardRequest {
    /// Query identifier retained in the forwarded body.
    queryId: uint64
    /// Destination of the forwarded internal message.
    destination: address
    /// First forwarded opaque reference.
    payload0: Cell<RemainingBitsAndRefs>
    /// Second forwarded opaque reference.
    payload1: Cell<RemainingBitsAndRefs>
}

/// Administrative code and configuration replacement request.
struct (0x1c4586b2) MoonOrderFactoryUpgrade {
    /// Query identifier reserved by the common factory message header.
    queryId: uint64
    /// Replacement contract code.
    newCode: Cell<RemainingBitsAndRefs>
    /// Replacement configuration; the current last order id is preserved.
    newStorage: Cell<MoonOrderFactoryUpgradeStorage>
}

/// Direct native-GRAM request to create a Moon.cx order.
struct (0xda067c19) MoonOrderFactoryCreateOrder {
    /// Query identifier propagated to deployment and excess messages.
    queryId: uint64
    /// Second asset Jetton master; native GRAM is rejected in this direct path.
    asset2: address
    /// Referenced rate, lock mode, and vesting duration; the deployed code requires exactly 322 bits.
    orderParams: Cell<MoonOrderFactoryOrderParams>
}

/// Moon.cx payload carried inside a referenced Jetton transfer-notification payload.
struct (0xda067c19) MoonOrderFactoryJettonCreatePayload {
    /// First asset Jetton master corresponding to the notifying wallet.
    asset1: address
    /// Second asset Jetton master, or `addr_none` for native GRAM.
    asset2: address?
    /// Referenced rate, lock mode, and vesting duration; the deployed code requires exactly 322 bits.
    orderParams: Cell<MoonOrderFactoryOrderParams>
}

/// Standard TEP-74 transfer notification accepted for Jetton-backed order creation.
struct (0x7362d09c) MoonOrderFactoryJettonTransferNotification {
    /// Query identifier propagated to deployment, refunds, and excess messages.
    queryId: uint64
    /// Jetton amount received in elementary units.
    amount: coins
    /// Previous owner of the transferred Jettons.
    sender: address
    /// Either selector and referenced Moon.cx create payload retained as raw bits and references.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal messages handled by the historical order factory.
type MoonOrderFactoryIncomingMessage =
    | MoonOrderFactoryFeeNotification
    | MoonOrderFactoryDeployPipeRequest
    | MoonOrderFactoryCreateOrder
    | MoonOrderFactoryRegisterOrder
    | MoonOrderFactoryJettonTransferNotification
    | MoonOrderFactoryForwardRequest
    | MoonOrderFactoryUpgrade

/// Initialization body sent to a newly derived asset pipe.
struct (0xdfdff21b) MoonOrderFactoryDeployPipe {
    /// Query identifier copied from the deployment request.
    queryId: uint64
    /// First opaque pipe configuration reference.
    config0: Cell<RemainingBitsAndRefs>
    /// Second opaque pipe configuration reference.
    config1: Cell<RemainingBitsAndRefs>
}

/// Body forwarded by an authorized administrative request.
struct (0x70acb3f0) MoonOrderFactoryForwardedMessage {
    /// Query identifier copied from the forwarding request.
    queryId: uint64
    /// First forwarded opaque reference.
    payload0: Cell<RemainingBitsAndRefs>
    /// Second forwarded opaque reference.
    payload1: Cell<RemainingBitsAndRefs>
}

/// Initialization body sent by the factory to a newly deployed order contract.
struct (0x983432e2) MoonOrderFactoryDeployOrder {
    /// Query identifier copied from the create request.
    queryId: uint64
    /// Protocol fee in basis points copied from factory storage.
    orderFeeBps: uint8
    /// Referenced rate, lock mode, and vesting duration.
    orderParams: Cell<MoonOrderFactoryOrderParams>
    /// Referenced asset master identifiers.
    assets: Cell<MoonOrderFactoryAssets>
    /// Referenced native or derived asset-wallet addresses.
    wallets: Cell<MoonOrderFactoryWallets>
    /// Initial Jetton source and amount, absent for a native-GRAM order.
    funding: Cell<MoonOrderFactoryFunding>?
}

/// Standard TEP-74 transfer emitted for refunds and protocol funding flows.
struct (0x0f8a7ea5) MoonOrderFactoryJettonTransfer {
    /// Query identifier propagated from the triggering request.
    queryId: uint64
    /// Jetton amount transferred in elementary units.
    amount: coins
    /// Destination owner of the transferred Jettons.
    destination: address
    /// Address that receives unused GRAM from the destination wallet.
    responseDestination: address
    /// Optional Jetton-wallet custom payload; the historical factory emits none.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// GRAM amount forwarded with the transfer notification.
    forwardTonAmount: coins
    /// Inline or referenced forward payload retained as raw bits and references.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response emitted after a successful direct create request.
struct (0xd53276db) MoonOrderFactoryExcess {
    /// Query identifier copied from the request.
    queryId: uint64
}

/// Outgoing messages with names and layouts proven by deployed code or published Moon.cx TL-B.
type MoonOrderFactoryOutgoingMessage =
    | MoonOrderFactoryDeployPipe
    | MoonOrderFactoryDeployOrder
    | MoonOrderFactoryJettonTransfer
    | MoonOrderFactoryExcess
    | MoonOrderFactoryForwardedMessage

/// Exit codes thrown by the exact historical factory implementation.
enum MoonOrderFactoryErrors {
    /// Sender is not authorized for the requested administrative operation.
    UnauthorizedSender = 300
    /// Attached GRAM does not cover the operation's minimum processing budget.
    InsufficientAttachedValue = 500
    /// Attached GRAM does not cover order or pipe deployment.
    InsufficientDeploymentValue = 510
    /// Order parameters have an invalid bit length or invalid asset combination.
    InvalidOrderData = 700
    /// Message opcode is not implemented by the factory.
    UnknownOpcode = 900
}

/// Return the last protocol-assigned order identifier.
get fun get_id(): uint64 {
    throw 0;
}

/// Derive the per-asset pipe address for an asset master identifier.
get fun get_pipe(asset: address): address {
    throw 0;
}
