/// Megaton Finance DEX router used to deploy and coordinate liquidity pools.
contract MegatonRouter {
    author: "Megaton Finance"
    version: "1.0"
    description: "Megaton Router manages the pool registry, protocol roles, mining parameters, and routed Jetton operations."
    storage: MegatonRouterStorage
    incomingMessages: MegatonRouterIncomingMessage
    outgoingMessages: MegatonRouterOutgoingMessage
    thrownErrors: MegatonRouterErrors
}

/// Persistent Router state split across four referenced subcells.
struct MegatonRouterStorage {
    /// Administrator authorized to mutate Router-wide configuration.
    adminAddress: address
    /// Controller authorized to create pools and update their metadata.
    poolFactoryAddress: address
    /// Jetton master address used when deriving the Router-owned reward wallet.
    rewardJettonMaster: address
    /// Whether transfer notifications use the direct-return path instead of pool lookup.
    directTransferEnabled: bool
    /// Configured TON amount forwarded when a routed transfer reaches a registered pool.
    routedTransferTonAmount: coins
    /// Referenced operational role addresses.
    roles: Cell<MegatonRouterRoles>
    /// Referenced mining counters, timing values, and pool count.
    mining: Cell<MegatonRouterMiningState>
    /// Referenced bidirectional pool registry.
    pools: Cell<MegatonRouterPoolMappings>
    /// Referenced contract code and reward-wallet configuration cells.
    code: Cell<MegatonRouterCodeState>
}

/// Operational accounts stored by the Router.
struct MegatonRouterRoles {
    /// Account authorized to broadcast mining configuration to every pool.
    miningController: address
    /// Account authorized to forward pool-scoped maintenance messages.
    poolController: address
    /// Nominated replacement administrator, or `addr_none` when no transfer is pending.
    pendingAdminAddress: address?
}

/// Global mining state and pool counter.
struct MegatonRouterMiningState {
    /// Global mined-amount accumulator exposed by `get_mining_data`.
    totalMiningAmount: uint256
    /// Mining amount added per second.
    miningAmountPerSecond: uint256
    /// Unix timestamp from which scheduled mining emissions accrue.
    miningStartTime: uint64
    /// Emission-rate half-life interval in seconds; zero selects a linear schedule.
    miningHalfLife: uint64
    /// Number of registered pools.
    poolCount: uint16
    /// Distributed reward accumulator used to reject claims above the current schedule.
    distributedRewardAmount: uint256
}

/// Pair of Jetton masters stored for a registered pool address.
struct MegatonRouterPoolPair {
    /// First Jetton master in the pair.
    token0: address
    /// Second Jetton master in the pair.
    token1: address
}

/// Bidirectional registry between token pairs and pool contracts.
struct MegatonRouterPoolMappings {
    /// Map from the ordered-pair hash to the deployed pool address.
    pairHashToPool: map<uint256, address>
    /// Map from the pool address hash to its two Jetton masters.
    poolHashToPair: map<uint256, MegatonRouterPoolPair>
}

/// Code and configuration refs used by deterministic pool and reward-wallet derivation.
struct MegatonRouterCodeState {
    /// Liquidity-pool contract code.
    poolCode: cell
    /// Pool metadata/content template forwarded by pool updates.
    poolContent: cell
    /// LP Jetton wallet code used by pool state initialization.
    lpWalletCode: cell
    /// Reward Jetton wallet code used to derive the Router-owned wallet.
    rewardWalletCode: cell
}

/// Pair of protocol addresses carried in a new-pool request.
struct MegatonRouterCreatePoolAddresses {
    /// First protocol address included in the pool initialization body.
    address0: address
    /// Second protocol address included in the pool initialization body.
    address1: address
}

/// Mining schedule values embedded in a pool deployment body.
struct MegatonRouterPoolMiningParams {
    /// Global mined-amount accumulator at deployment time.
    totalMiningAmount: uint256
    /// Mining amount added per second.
    miningAmountPerSecond: uint256
    /// Unix timestamp from which scheduled mining emissions accrue.
    miningStartTime: uint64
    /// Emission-rate half-life interval in seconds; zero selects a linear schedule.
    miningHalfLife: uint64
}

/// Factory request to deploy and register a pool for two Jetton masters.
struct (0x53370e2e) MegatonRouterCreatePool {
    /// Factory correlation id copied to the deployed pool body.
    queryId: uint64
    /// First Jetton master; ordering is normalized by account hash.
    token0: address
    /// Second Jetton master; must differ from `token0`.
    token1: address
    /// Pool fee value accepted in the inclusive protocol range 5..100.
    fee: coins
    /// Pool-specific 32-bit initialization parameter.
    parameter: uint32
    /// Referenced protocol addresses installed into the pool.
    addresses: Cell<MegatonRouterCreatePoolAddresses>
}

/// Pool callback that completes registration after deterministic deployment.
struct (0xf2c8682b) MegatonRouterPoolCreated {
    /// Correlation id copied from pool deployment.
    queryId: uint64
    /// First Jetton master in the pool.
    token0: address
    /// Second Jetton master in the pool.
    token1: address
    /// Pool TON configuration returned by the deployed contract.
    poolTonAmount: coins
}

/// Registered-pool request to pay a mining reward through the reward Jetton wallet.
struct (0x6b14cfe1) MegatonRouterClaimMiningReward {
    /// Correlation id forwarded to the Jetton transfer.
    queryId: uint64
    /// Reward recipient.
    recipient: address
    /// Reward Jetton amount in base units.
    amount: coins
}

/// Referenced routing payload carried by a Jetton transfer notification.
struct MegatonRouterTransferRoute {
    /// First Jetton master of the target pool.
    token0: address
    /// Second Jetton master of the target pool.
    token1: address
    /// Route-specific amount forwarded unchanged to the target pool.
    routeAmount: coins
}

/// Jetton-wallet notification routed either back to the sender or to a registered pool.
struct (0x7362d09c) MegatonRouterJettonTransferNotification {
    /// Correlation id copied to the emitted Jetton transfer.
    queryId: uint64
    /// Received Jetton amount in base units.
    amount: coins
    /// Logical sender reported by the notifying wallet.
    sender: address
    /// TEP-74 `Either Cell ^Cell` forward-payload tail used for pool routing.
    route: RemainingBitsAndRefs
}

/// Administrator request to nominate a replacement administrator.
struct (0x62dd86f1) MegatonRouterChangeNextAdmin {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Account allowed to accept Router administration.
    nextAdminAddress: address
}

/// Nominated administrator request to complete the Router handover.
struct (0x66447dad) MegatonRouterAcceptAdmin {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
}

/// Pool-controller request to forward an administrator change to a registered pool.
struct (0x0eed8fd3) MegatonRouterSetPoolAdmin {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the request.
    poolAddress: address
    /// Replacement pool administrator.
    newAdminAddress: address
}

/// Router-admin request to forward a second address update to a registered pool.
struct (0x3373fa00) MegatonRouterSetPoolAddress {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the request.
    poolAddress: address
    /// Replacement address forwarded to the pool.
    newAddress: address
}

/// Administrator request to replace the pool-factory account.
struct (0x1d65ab3f) MegatonRouterSetPoolFactory {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement pool-factory account.
    poolFactoryAddress: address
}

/// Administrator request to replace the mining controller.
struct (0x360e7ae3) MegatonRouterSetMiningController {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement mining-controller account.
    miningController: address
}

/// Administrator request to replace the pool controller.
struct (0x3bb99164) MegatonRouterSetPoolController {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement pool-controller account.
    poolController: address
}

/// Administrator request to replace the pool metadata/content template.
struct (0x7532380d) MegatonRouterSetPoolContent {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement pool content cell.
    content: cell
}

/// Map of pool-address hashes to one-millionth mining allocation shares.
type MegatonRouterMiningShares = map<uint256, uint32>

/// Mining-controller request to broadcast mining shares and a schedule value.
struct (0x70ae1f34) MegatonRouterDistributeMiningShares {
    /// Correlation id copied to every pool message.
    queryId: uint64
    /// Schedule timestamp/value copied to every pool message.
    scheduleValue: uint64
    /// Pool shares whose sum must equal 1,000,000.
    shares: MegatonRouterMiningShares
}

/// Mining-controller request to broadcast the global mined-amount accumulator.
struct (0x20b88d2e) MegatonRouterBroadcastMiningAmount {
    /// Correlation id copied to every pool message.
    queryId: uint64
    /// Replacement 256-bit mined-amount accumulator.
    totalMiningAmount: uint256
}

/// Pool-controller request to forward a coin amount to a registered pool.
struct (0x5cbfb251) MegatonRouterSetPoolAmount {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the request.
    poolAddress: address
    /// Pool-specific amount in base token units.
    amount: coins
}

/// Administrator request to toggle the direct transfer-notification path.
struct (0x72ee6e80) MegatonRouterSetDirectTransfer {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// New direct-transfer flag.
    enabled: bool
}

/// Factory request to forward new content to a registered pool.
struct (0x743f8e58) MegatonRouterChangePoolContent {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the replacement content.
    poolAddress: address
    /// Replacement pool content cell.
    content: cell
}

/// Administrator request to change the TON amount forwarded during pool routing.
struct (0x4c47f45e) MegatonRouterSetRoutedTransferTonAmount {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// New TON amount forwarded to a registered pool.
    amount: coins
}

/// Administrator request to send mining share data to one registered pool.
struct (0x0c92a5dc) MegatonRouterSetPoolMiningShare {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the mining share.
    poolAddress: address
    /// Pool share in millionths; must not exceed 1,000,000.
    share: uint32
    /// Schedule timestamp/value copied to the pool.
    scheduleValue: uint64
}

/// Administrator request to send a 256-bit mining value to one registered pool.
struct (0x0e993a0a) MegatonRouterSetPoolMiningAmount {
    /// Correlation id copied to the pool message.
    queryId: uint64
    /// Registered pool that receives the value.
    poolAddress: address
    /// Mining accumulator copied to the pool.
    totalMiningAmount: uint256
}

/// Administrator request to replace the Router's global mined-amount accumulator.
struct (0x93675382) MegatonRouterSetMiningAmount {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement global mined-amount accumulator.
    totalMiningAmount: uint256
}

/// Administrator request to replace the complete pool registry and count.
struct (0x422692c9) MegatonRouterReplacePoolRegistry {
    /// Correlation id accepted but not otherwise used.
    queryId: uint64
    /// Replacement number of registered pools.
    poolCount: uint16
    /// Replacement ordered-pair-hash to pool-address map.
    pairHashToPool: map<uint256, address>
    /// Replacement pool-address-hash to token-pair map.
    poolHashToPair: map<uint256, MegatonRouterPoolPair>
}

/// Every non-empty internal body accepted by the exact Router revision.
type MegatonRouterIncomingMessage =
    | MegatonRouterCreatePool
    | MegatonRouterPoolCreated
    | MegatonRouterClaimMiningReward
    | MegatonRouterJettonTransferNotification
    | MegatonRouterChangeNextAdmin
    | MegatonRouterAcceptAdmin
    | MegatonRouterSetPoolAdmin
    | MegatonRouterSetPoolAddress
    | MegatonRouterSetPoolFactory
    | MegatonRouterSetMiningController
    | MegatonRouterSetPoolController
    | MegatonRouterSetPoolContent
    | MegatonRouterDistributeMiningShares
    | MegatonRouterBroadcastMiningAmount
    | MegatonRouterSetPoolAmount
    | MegatonRouterSetDirectTransfer
    | MegatonRouterChangePoolContent
    | MegatonRouterSetRoutedTransferTonAmount
    | MegatonRouterSetPoolMiningShare
    | MegatonRouterSetPoolMiningAmount
    | MegatonRouterSetMiningAmount
    | MegatonRouterReplacePoolRegistry

/// Pool deployment body emitted to a deterministic, not-yet-deployed pool address.
struct (0x53370e2e) MegatonRouterPoolDeploy {
    /// Correlation id copied from the factory request.
    queryId: uint64
    /// Pool fee value.
    fee: coins
    /// Pool-specific 32-bit initialization parameter.
    parameter: uint32
    /// First protocol address installed into the pool.
    address0: address
    /// Second protocol address installed into the pool.
    address1: address
    /// Referenced global mining parameters.
    mining: Cell<MegatonRouterPoolMiningParams>
}

/// External registration event emitted when a pool is added to both maps.
struct (0xf2c8682b) MegatonRouterPoolRegisteredEvent {
    /// Newly registered pool address.
    poolAddress: address
    /// First Jetton master in the pool.
    token0: address
    /// Second Jetton master in the pool.
    token1: address
    /// Pool TON configuration returned at registration.
    poolTonAmount: coins
    /// Updated number of registered pools.
    poolCount: uint16
}

/// Pool-routing payload forwarded with a Jetton transfer notification.
struct MegatonRouterPoolDepositPayload {
    /// First Jetton master of the target pool.
    token0: address
    /// Second Jetton master of the target pool.
    token1: address
    /// Original logical sender reported by the notifying Jetton wallet.
    sender: address
    /// Route-specific amount copied from the original notification payload.
    routeAmount: coins
}

/// Standard Jetton transfer emitted for rewards, returns, and routed pool deposits.
struct (0x0f8a7ea5) MegatonRouterJettonTransfer {
    /// Correlation id copied from the initiating Router message.
    queryId: uint64
    /// Jetton amount in base units.
    amount: coins
    /// Jetton recipient.
    destination: address
    /// Address that receives excess TON.
    responseDestination: address?
    /// Optional Jetton custom payload.
    customPayload: cell?
    /// TON amount forwarded with the Jetton transfer notification.
    forwardTonAmount: coins
    /// Optional referenced pool-routing payload.
    forwardPayload: Cell<MegatonRouterPoolDepositPayload>?
}

/// Router-to-pool administrator handover request.
struct (0x66447dad) MegatonRouterPoolAcceptAdmin {
    /// Correlation id copied from the Router request.
    queryId: uint64
    /// Replacement pool administrator.
    newAdminAddress: address
}

/// Router-to-pool address update with an otherwise protocol-private role.
struct (0x1403d27a) MegatonRouterPoolSetAddress {
    /// Correlation id copied from the Router request.
    queryId: uint64
    /// Replacement pool address field.
    newAddress: address
}

/// Router-to-pool content replacement.
struct (0x743f8e58) MegatonRouterPoolChangeContent {
    /// Correlation id copied from the factory request.
    queryId: uint64
    /// Replacement pool content cell.
    content: cell
}

/// Router-to-pool mining share update.
struct (0x70ae1f34) MegatonRouterPoolMiningShare {
    /// Correlation id copied from the Router request.
    queryId: uint64
    /// Pool mining allocation in millionths.
    share: uint32
    /// Schedule timestamp/value copied from the Router request.
    scheduleValue: uint64
}

/// Router-to-pool global mined-amount update.
struct (0x20b88d2e) MegatonRouterPoolMiningAmount {
    /// Correlation id copied from the Router request.
    queryId: uint64
    /// Global 256-bit mined-amount accumulator.
    totalMiningAmount: uint256
}

/// Router-to-pool amount update.
struct (0x5cbfb251) MegatonRouterPoolAmount {
    /// Correlation id copied from the Router request.
    queryId: uint64
    /// Pool-specific amount in base token units.
    amount: coins
}

/// Every statically typed body emitted by the exact Router revision.
type MegatonRouterOutgoingMessage =
    | MegatonRouterPoolDeploy
    | MegatonRouterPoolRegisteredEvent
    | MegatonRouterJettonTransfer
    | MegatonRouterPoolAcceptAdmin
    | MegatonRouterPoolSetAddress
    | MegatonRouterPoolChangeContent
    | MegatonRouterPoolMiningShare
    | MegatonRouterPoolMiningAmount
    | MegatonRouterPoolAmount

/// Mining data returned by `get_mining_data` with exact deployed widths.
struct MegatonRouterMiningData {
    /// Global mined-amount accumulator.
    totalMiningAmount: uint256
    /// Fixed precision divider; the deployed getter always returns 1,000,000.
    totalMiningRate: int
    /// Mining amount added per second.
    miningAmountPerSecond: uint256
    /// Unix timestamp from which scheduled mining emissions accrue.
    miningStartTime: uint64
    /// Emission-rate half-life interval in seconds; zero selects a linear schedule.
    miningHalfLife: uint64
    /// Distributed reward accumulator.
    distributedRewardAmount: uint256
}

/// Pool registry data returned by `get_lp_data`.
struct MegatonRouterLpData {
    /// Number of registered pools.
    poolCount: uint16
    /// Serialized ordered-pair-hash to pool-address dictionary.
    pairHashToPool: cell
    /// Serialized pool-address-hash to token-pair dictionary.
    poolHashToPair: cell
}

/// Return the Router's global mining counters and timing parameters.
get fun get_mining_data(): MegatonRouterMiningData {
    throw 0;
}

/// Return the pool count and both serialized pool-registry dictionaries.
get fun get_lp_data(): MegatonRouterLpData {
    throw 0;
}

/// Exit codes explicitly thrown by the exact Router revision.
enum MegatonRouterErrors {
    /// An address is outside base workchain zero.
    UnsupportedWorkchain = 333
    /// A pool already exists for the requested token pair.
    PoolAlreadyExists = 55
    /// Attached value does not cover pool deployment.
    InsufficientPoolDeploymentValue = 72
    /// Sender is not authorized for the requested operation.
    UnauthorizedSender = 73
    /// Token pair or attached value is invalid.
    InvalidPairOrValue = 75
    /// Pool fee is outside the accepted protocol range.
    InvalidPoolFee = 999
    /// Address encoding is not the expected base-workchain form.
    InvalidAddressEncoding = 44
    /// Token pair is not in canonical hash order.
    NonCanonicalTokenOrder = 66
    /// Sender is not a registered pool.
    UnknownPoolSender = 1001
    /// Requested mining reward exceeds the available schedule amount.
    MiningRewardExceeded = 99
    /// Transfer route resolves to no usable registered pool.
    InvalidTransferRoute = 2001
    /// Target pool is not registered.
    UnknownPool = 110
    /// Attached value does not cover the requested broadcast or forward.
    InsufficientForwardValue = 80
    /// Mining-share map contains an unregistered pool.
    MiningShareUnknownPool = 50
    /// Mining-share map contains a duplicate pool key.
    MiningShareDuplicatePool = 51
    /// Mining shares are invalid or exceed the protocol divider.
    InvalidMiningShare = 52
    /// Incoming opcode is not recognized.
    UnsupportedOperation = 65535
}
