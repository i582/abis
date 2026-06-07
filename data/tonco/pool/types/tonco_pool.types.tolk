/// TONCO PoolV3 concentrated-liquidity pool interface.
contract ToncoPool {
    author: "Algebra / TONCO"
    version: "1.0"
    description: "Curated TONCO PoolV3 ABI for concentrated-liquidity pool storage, swap/mint/burn/admin messages, NFT collection getters, fee estimates, and child Account/Position NFT callbacks"
    storage: ToncoPoolStorage
    incomingMessages: ToncoPoolIncomingMessage
    outgoingMessages: ToncoPoolOutgoingMessage
    forceAbiExport: ToncoPayToPayload | ToncoPoolTickInfo
}

/// Runtime PoolV3 storage loaded from the root data cell.
struct ToncoPoolStorage {
    /// Router that created and controls this pool.
    routerAddress: address
    /// Base LP fee stored by the pool.
    lpFeeBase: uint16
    /// Protocol fee stored by the pool.
    protocolFee: uint16
    /// Current active LP fee.
    lpFeeCurrent: uint16
    /// Pool Jetton wallet for token0.
    jetton0Wallet: address
    /// Pool Jetton wallet for token1.
    jetton1Wallet: address
    /// Pool tick spacing.
    tickSpacing: int24
    /// Pool operation sequence number.
    seqno: uint64
    /// Referenced global fee-growth, protocol-fee, and reserve values.
    feesAndReserves: Cell<ToncoPoolFeesAndReserves>
    /// Referenced active state, price, liquidity, NFT counters, and admin/controller data.
    state: Cell<ToncoPoolState>
    /// Referenced tick dictionary container.
    ticks: Cell<ToncoPoolTicks>
    /// Referenced AccountV3, Position NFT V3, and NFT metadata code/content bundle.
    childContracts: Cell<ToncoPoolChildContracts>
}

/// Referenced PoolV3 fee-growth, protocol-fee, and reserve values.
struct ToncoPoolFeesAndReserves {
    /// Global token0 fee growth, Q128-scaled.
    feeGrowthGlobal0X128: uint256
    /// Global token1 fee growth, Q128-scaled.
    feeGrowthGlobal1X128: uint256
    /// Collected token0 protocol fee amount.
    collectedProtocolFee0: uint128
    /// Collected token1 protocol fee amount.
    collectedProtocolFee1: uint128
    /// Current token0 reserve.
    reserve0: coins
    /// Current token1 reserve.
    reserve1: coins
}

/// Referenced PoolV3 active price/liquidity/admin state.
struct ToncoPoolState {
    /// True when the pool accepts active swap/liquidity operations.
    poolActive: bool
    /// Current pool tick.
    tick: int24
    /// Current square-root price Q96 value.
    priceSqrt: uint160
    /// Current in-range liquidity.
    liquidity: uint128
    /// Number of occupied ticks in the tick dictionary.
    occupiedTicks: uint24
    /// Next Position NFT item index.
    nftv3itemCounter: uint64
    /// Number of currently active Position NFT items.
    nftv3itemsActive: uint64
    /// Pool admin address.
    adminAddress: address
    /// Pool controller address.
    controllerAddress: address
    /// Referenced token0/token1 Jetton minter pair.
    minters: Cell<ToncoPoolMinters>
}

/// Referenced Jetton minter pair for this pool.
struct ToncoPoolMinters {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
}

/// Referenced tick dictionary container.
struct ToncoPoolTicks {
    /// Optional raw tick dictionary cell keyed by signed tick index; value layout is `ToncoPoolTickInfo`.
    ticksDictionary: cell?
}

/// Tick dictionary value shape exposed for ABI consumers.
struct ToncoPoolTickInfo {
    /// Gross liquidity assigned to this tick.
    liquidityGross: uint256
    /// Signed liquidity delta applied when crossing this tick.
    liquidityNet: int128
    /// Token0 outer fee-growth checkpoint, Q128-scaled.
    outerFeeGrowth0Token: uint256
    /// Token1 outer fee-growth checkpoint, Q128-scaled.
    outerFeeGrowth1Token: uint256
}

/// Referenced child implementation code and NFT metadata content.
struct ToncoPoolChildContracts {
    /// AccountV3 implementation code.
    accountv3Code: cell
    /// Position NFT V3 implementation code.
    positionNftv3Code: cell
    /// NFT collection metadata content.
    nftv3Content: cell
    /// Position NFT item metadata content.
    nftv3itemContent: cell
}

/// Structured return value of `getPoolStateAndConfiguration`.
struct GetPoolStateAndConfigurationReply {
    /// Router paired with this pool.
    routerAddress: address
    /// Pool admin address.
    adminAddress: address
    /// Pool controller address.
    controllerAddress: address
    /// Pool Jetton wallet for token0.
    jettonWallet0: address
    /// Pool Jetton wallet for token1.
    jettonWallet1: address
    /// Jetton minter for token0.
    jettonMinter0: address
    /// Jetton minter for token1.
    jettonMinter1: address
    /// True when the pool is active.
    isActive: bool
    /// Pool tick spacing.
    tickSpacing: int
    /// Base LP fee.
    baseFee: int
    /// Protocol fee.
    protocolFee: int
    /// Current active LP fee.
    activeFee: int
    /// Current pool tick.
    currentTick: int
    /// Current square-root price Q96 value.
    currentPrice: int
    /// Current in-range liquidity.
    currentLiquidity: int
    /// Global token0 fee growth, Q128-scaled.
    feeGrowsGlobal0: int
    /// Global token1 fee growth, Q128-scaled.
    feeGrowsGlobal1: int
    /// Collected token0 protocol fee amount.
    collectedToken0ProtocolFee: int
    /// Collected token1 protocol fee amount.
    collectedToken1ProtocolFee: int
    /// Number of minted Position NFT items.
    mintedNftPositions: int
    /// Current token0 reserve.
    reserve0: int
    /// Current token1 reserve.
    reserve1: int
    /// Number of active Position NFT items.
    activeNftPositions: int
    /// Number of occupied ticks.
    occupiedTicks: int
    /// Pool operation sequence number.
    operationsSinceDeploy: int
}

/// Structured return value of Pool `getChildContracts`.
struct GetChildContractsReply {
    /// AccountV3 implementation code.
    accountCode: cell
    /// Position NFT V3 implementation code.
    positionNftCode: cell
    /// NFT collection metadata content.
    nftCollectionMetadata: cell
    /// Position NFT item metadata content.
    nftItemMetadata: cell
}

/// Structured return value of `getCollectedFees`.
struct GetCollectedFeesReply {
    /// Token0 fees currently collectible by a position.
    amount0: int
    /// Token1 fees currently collectible by a position.
    amount1: int
}

/// Structured return value of `getMintEstimate`.
struct GetMintEstimateReply {
    /// Estimated token0 amount required for the requested liquidity.
    amount0: int
    /// Estimated token1 amount required for the requested liquidity.
    amount1: int
    /// Mint validation bitmask or error value returned by the pool.
    mintErrors: int
}

/// Structured return value of swap estimate getters.
struct GetSwapEstimateReply {
    /// Estimated token0 delta; negative values represent outgoing token0.
    amount0: int
    /// Estimated token1 delta; negative values represent outgoing token1.
    amount1: int
}

/// Structured return value of `getFeeGrowthInside`.
struct GetFeeGrowthInsideReply {
    /// Token0 fee growth inside the requested tick range, Q128-scaled.
    feeGrowthInside0X128: int
    /// Token1 fee growth inside the requested tick range, Q128-scaled.
    feeGrowthInside1X128: int
}

/// Structured standard NFT collection data returned by `get_collection_data`.
struct GetCollectionDataReply {
    /// Next Position NFT item index.
    nextItemIndex: int
    /// Collection metadata content cell.
    collectionContent: cell
    /// Collection owner address; for TONCO this is the pool address.
    ownerAddress: address
}

/// Referenced Jetton minter pair in Pool initialization.
struct Poolv3InitMinterCell {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
}

/// Router/admin message that initializes or updates PoolV3 configuration.
struct (0x441c39ed) Poolv3Init {
    /// Query id propagated through pool initialization.
    queryId: uint64
    /// True when the message is admin-originated.
    fromAdmin: bool
    /// True when `adminAddr` should be applied.
    hasAdmin: bool
    /// Pool admin address.
    adminAddr: address
    /// True when `controllerAddr` should be applied.
    hasController: bool
    /// Pool controller address.
    controllerAddr: address
    /// True when `tickSpacing` should be applied.
    setSpacing: bool
    /// Pool tick spacing.
    tickSpacing: int24
    /// True when `initialPriceX96` should be applied.
    setPrice: bool
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// True when `poolActive` should be applied.
    setActive: bool
    /// Pool active flag.
    poolActive: bool
    /// Protocol fee.
    protocolFee: uint16
    /// Base LP fee.
    lpFeeBase: uint16
    /// Current active LP fee.
    lpFeeCurrent: uint16
    /// NFT collection metadata content.
    nftv3Content: cell
    /// Position NFT item metadata content.
    nftv3itemContent: cell
    /// Optional referenced Jetton minter pair.
    minterCell: Cell<Poolv3InitMinterCell>?
}

/// Admin/controller command that locks pool operations.
struct (0x05e74697) Poolv3Lock {
    /// Query id for tracing the lock command.
    queryId: uint64
}

/// Admin/controller command that unlocks pool operations.
struct (0x3205adbd) Poolv3Unlock {
    /// Query id for tracing the unlock command.
    queryId: uint64
}

/// Admin command that returns excess TON after preserving pool storage reserve.
struct (0x42a0fb43) Poolv3ResetGas {
    /// Query id for tracing the reset-gas command.
    queryId: uint64
}

/// Admin/controller command that updates pool fees.
struct (0x6bdcbeb8) Poolv3SetFee {
    /// Query id for the fee update.
    queryId: uint64
    /// Replacement protocol fee.
    protocolFee: uint16
    /// Replacement base LP fee.
    lpFeeBase: uint16
    /// Replacement current active LP fee.
    lpFeeCurrent: uint16
}

/// Admin command that collects accumulated protocol fees.
struct (0xd3f8a538) Poolv3CollectProtocol {
    /// Query id for the collect command.
    queryId: uint64
}

/// User/NFT-originated request that starts a position burn.
struct (0x530b5f2c) Poolv3StartBurn {
    /// Query id propagated through the burn flow.
    queryId: uint64
    /// Position NFT index requested for burning.
    burnedIndex: uint64
    /// Liquidity amount requested to burn.
    liquidity2Burn: uint128
    /// Lower tick boundary of the position.
    tickLower: int24
    /// Upper tick boundary of the position.
    tickUpper: int24
}

/// Referenced previous fee-growth checkpoint cell in `Poolv3Burn`.
struct Poolv3BurnOldFeeCell {
    /// Previous token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Previous token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
}

/// Referenced current fee-growth checkpoint cell in `Poolv3Burn`.
struct Poolv3BurnNewFeeCell {
    /// Current token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0CurrentX128: uint256
    /// Current token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1CurrentX128: uint256
}

/// Position NFT callback that executes a position burn in the pool.
struct (0xd73ac09d) Poolv3Burn {
    /// Query id copied from the position burn request.
    queryId: uint64
    /// Address receiving withdrawn token amounts.
    recipient: address
    /// Position NFT index being burned.
    burnedIndex: uint64
    /// Position liquidity before the burn.
    liquidity: uint128
    /// Lower tick boundary of the position.
    tickLower: int24
    /// Upper tick boundary of the position.
    tickUpper: int24
    /// Liquidity amount requested to burn.
    liquidity2Burn: uint128
    /// Referenced previous fee-growth checkpoints.
    oldFeeCell: Cell<Poolv3BurnOldFeeCell>
    /// Referenced current fee-growth checkpoints.
    newFeeCell: Cell<Poolv3BurnNewFeeCell>
}

/// Referenced swap parameters in `Poolv3Swap`.
struct Poolv3SwapParamsCell {
    /// Swap input amount, in source Jetton basic units.
    amount: coins
    /// Square-root price Q96 limit.
    sqrtPriceLimitX96: uint160
    /// Minimum output amount accepted by the user.
    minOutAmount: coins
}

/// Referenced receiver and forward payload parameters in `Poolv3Swap`.
struct Poolv3SwapPayloadsCell {
    /// Target receiver for successful swap output.
    targetAddress: address
    /// TON amount forwarded on successful swap.
    okForwardAmount: coins
    /// Optional payload forwarded on successful swap.
    okForwardPayload: cell?
    /// TON amount forwarded on returned/refunded flow.
    retForwardAmount: coins
    /// Optional payload forwarded on returned/refunded flow.
    retForwardPayload: cell?
}

/// Router-to-Pool message that starts a swap.
struct (0xa7fb58f8) Poolv3Swap {
    /// Query id propagated through swap callbacks.
    queryId: uint64
    /// User that owns the swap operation.
    ownerAddress: address
    /// Jetton wallet that supplied input tokens.
    sourceWallet: address
    /// Referenced amount/price/min-output parameters.
    paramsCell: Cell<Poolv3SwapParamsCell>
    /// Referenced receiver and forward-payload parameters.
    payloadsCell: Cell<Poolv3SwapPayloadsCell>
}

/// Router-to-Pool message that funds a user's temporary AccountV3.
@overflow1023_policy("suppress")
struct (0x4468de77) Poolv3FundAccount {
    /// Query id propagated through the fund-account flow.
    queryId: uint64
    /// Account owner receiving pending balances.
    ownerAddr: address
    /// Token0 amount to fund.
    amount0: coins
    /// Token1 amount to fund.
    amount1: coins
    /// Token0 enough threshold for minting.
    enough0: coins
    /// Token1 enough threshold for minting.
    enough1: coins
    /// Requested liquidity for the mint order.
    liquidity: uint128
    /// Lower tick boundary for the mint order.
    tickLower: int24
    /// Upper tick boundary for the mint order.
    tickUpper: int24
}

/// AccountV3-to-Pool callback that attempts to mint a position.
struct (0x81702ef8) Poolv3Mint {
    /// Query id copied from the AccountV3 flow.
    queryId: uint64
    /// Token0 amount funded for minting.
    amount0Funded: coins
    /// Token1 amount funded for minting.
    amount1Funded: coins
    /// User receiving the minted Position NFT.
    recipient: address
    /// Liquidity amount requested.
    liquidity: uint128
    /// Lower tick boundary.
    tickLower: int24
    /// Upper tick boundary.
    tickUpper: int24
}

/// Pool-to-AccountV3 message that updates pending liquidity balances.
struct (0x3ebe5431) Accountv3AddLiquidity {
    /// Query id copied from the funding flow.
    queryId: uint64
    /// Additional token0 amount.
    newAmount0: coins
    /// Additional token1 amount.
    newAmount1: coins
    /// Token0 enough threshold.
    newEnough0: coins
    /// Token1 enough threshold.
    newEnough1: coins
    /// Requested liquidity for a mint order.
    liquidity: uint128
    /// Lower tick boundary.
    tickLower: int24
    /// Upper tick boundary.
    tickUpper: int24
}

/// Referenced old-fee and mint context cell sent to Position NFT initialization.
struct PositionnftV3PositionInitOldFeeCell {
    /// Last token0 fee growth inside the position range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Last token1 fee growth inside the position range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
    /// Position NFT item index assigned by the pool.
    nftIndex: uint64
    /// Token0 amount used for minting.
    jetton0Amount: coins
    /// Token1 amount used for minting.
    jetton1Amount: coins
    /// Pool tick at mint time.
    tick: int24
}

/// Pool-to-PositionNFT message that initializes a newly minted position.
struct (0xd5ecca2a) PositionnftV3PositionInit {
    /// Query id copied from the mint flow.
    queryId: uint64
    /// User that owns the position.
    userAddress: address
    /// Minted liquidity amount.
    liquidity: uint128
    /// Lower tick boundary.
    tickLower: int24
    /// Upper tick boundary.
    tickUpper: int24
    /// Pool operation sequence number embedded before the fee context ref.
    poolSeqno: uint64
    /// Referenced old fee-growth and mint context values.
    oldFeeCell: Cell<PositionnftV3PositionInitOldFeeCell>
}

/// Pool-to-Router pay-to callback.
struct (0xa1daa96d) Routerv3PayTo {
    /// Query id propagated through the payout.
    queryId: uint64
    /// Receiver for token0-side payout.
    receiver0: address
    /// Receiver for token1-side payout.
    receiver1: address
    /// Inline nested pay-to payload variant.
    payTo: ToncoPayToPayload
}

/// Nested pay-to payload variant for exit code 0.
struct (0x00000000) PayToCode0 {
    /// Pool/Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information cell.
    coinsinfoCell: Cell<PayToCoinsinfoCell>?
}

/// Nested pay-to payload variant for swap payout code 200.
struct (0x000000c8) PayToCode200 {
    /// Pool/Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information and payload cell.
    coinsinfoCell: Cell<PayToCoinsinfoWithPayloadCell>?
    /// Optional referenced swap indexer information.
    indexerSwapInfoCell: Cell<PayToIndexerSwapInfoCell>?
}

/// Nested pay-to payload variant for burn payout code 201.
struct (0x000000c9) PayToCode201 {
    /// Pool/Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information and payload cell.
    coinsinfoCell: Cell<PayToCoinsinfoWithPayloadCell>?
    /// Optional referenced burn indexer information.
    indexerBurnInfoCell: Cell<PayToIndexerBurnInfoCell>?
}

/// Nested pay-to payload variant for swap payout code 230.
struct (0x000000e6) PayToCode230 {
    /// Pool/Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information and payload cell.
    coinsinfoCell: Cell<PayToCoinsinfoWithPayloadCell>?
    /// Optional referenced swap indexer information.
    indexerSwapInfoCell: Cell<PayToIndexerSwapInfoCell>?
}

/// Referenced payout amount and Jetton wallet pair.
struct PayToCoinsinfoCell {
    /// Token0 payout amount.
    amount0: coins
    /// Jetton wallet or Jetton address associated with token0 payout.
    jetton0Address: address
    /// Token1 payout amount.
    amount1: coins
    /// Jetton wallet or Jetton address associated with token1 payout.
    jetton1Address: address
}

/// Referenced payout amount, Jetton pair, and user payloads.
struct PayToCoinsinfoWithPayloadCell {
    /// Token0 payout amount.
    amount0: coins
    /// Jetton wallet or Jetton address associated with token0 payout.
    jetton0Address: address
    /// Token1 payout amount.
    amount1: coins
    /// Jetton wallet or Jetton address associated with token1 payout.
    jetton1Address: address
    /// Referenced per-token forward payloads and amounts.
    payloadCell: Cell<PayToPayloadCell>
}

/// Referenced per-token forward payload data inside pay-to callbacks.
struct PayToPayloadCell {
    /// TON amount forwarded with token0 payout payload.
    payloadAmount0: coins
    /// Optional payload cell forwarded with token0 payout.
    payloadCell0: cell?
    /// TON amount forwarded with token1 payout payload.
    payloadAmount1: coins
    /// Optional payload cell forwarded with token1 payout.
    payloadCell1: cell?
}

/// Swap event/indexer data embedded in selected pay-to payloads.
struct PayToIndexerSwapInfoCell {
    /// Pool liquidity after or during the swap callback.
    liquidity: uint128
    /// Pool square-root price Q96 value.
    priceSqrt: uint160
    /// Pool tick value.
    tick: int24
    /// Global token0 fee growth Q128-scaled value.
    feeGrowthGlobal0X128: int256
    /// Global token1 fee growth Q128-scaled value.
    feeGrowthGlobal1X128: int256
}

/// Burn event/indexer data embedded in selected pay-to payloads.
struct PayToIndexerBurnInfoCell {
    /// Position NFT index being burned.
    nftIndex: uint64
    /// Liquidity amount burned.
    liquidityBurned: uint128
    /// Lower tick boundary.
    tickLower: int24
    /// Upper tick boundary.
    tickUpper: int24
    /// Pool tick at burn time.
    tick: int24
}

/// Nested pay-to payload variants force-exported for ABI consumers.
type ToncoPayToPayload =
    | PayToCode0
    | PayToCode200
    | PayToCode201
    | PayToCode230

/// Internal message bodies accepted by TONCO PoolV3.
type ToncoPoolIncomingMessage =
    | Poolv3Init
    | Poolv3Lock
    | Poolv3Unlock
    | Poolv3ResetGas
    | Poolv3SetFee
    | Poolv3CollectProtocol
    | Poolv3StartBurn
    | Poolv3Burn
    | Poolv3Swap
    | Poolv3FundAccount
    | Poolv3Mint

/// Internal message bodies emitted by TONCO PoolV3.
type ToncoPoolOutgoingMessage =
    | Routerv3PayTo
    | Accountv3AddLiquidity
    | PositionnftV3PositionInit

/// Return whether this pool is active.
get fun getIsActive(): bool {
    throw 0;
}

/// Return pool configuration, reserves, fees, price, liquidity, and NFT counters.
get fun getPoolStateAndConfiguration(): GetPoolStateAndConfigurationReply {
    throw 0;
}

/// Return AccountV3/Position NFT code and NFT metadata cells.
get fun getChildContracts(): GetChildContractsReply {
    throw 0;
}

/// Return raw tick dictionary cell for all initialized ticks.
get fun getAllTickInfos(): cell {
    throw 0;
}

/// Return raw nested TVM tuple chunks of tick infos from a starting tick.
get fun getTickInfosFrom(tickNumber: int, amount: int, back: int, full: int): tuple {
    throw 0;
}

/// Return maximum liquidity allowed per initialized tick for this pool's tick spacing.
get fun getMaxLiquidityPerTick(): int {
    throw 0;
}

/// Return currently collectible token0/token1 fees for supplied position state.
get fun getCollectedFees(
    tickLower: int,
    tickUpper: int,
    posLiquidityDelta: int,
    posFeeGrowthInside0X128: int,
    posFeeGrowthInside1X128: int,
): GetCollectedFeesReply {
    throw 0;
}

/// Estimate token0/token1 amounts required to mint liquidity in a tick range.
get fun getMintEstimate(tickLower: int, tickUpper: int, liquidity: int): GetMintEstimateReply {
    throw 0;
}

/// Estimate token0/token1 deltas for a swap; `zeroForOne` is encoded as TVM integer truth value.
get fun getSwapEstimate(
    zeroForOne: int,
    amount: int,
    sqrtPriceLimitX96: int,
): GetSwapEstimateReply {
    throw 0;
}

/// Estimate token0/token1 deltas for a swap under supplied min-output and gas-limit parameters.
get fun getSwapEstimateGas(
    zeroForOne: int,
    amount: int,
    sqrtPriceLimitX96: int,
    minOutAmount: int,
    gasLimit: int,
): GetSwapEstimateReply {
    throw 0;
}

/// Return fee growth inside a supplied tick range using provided current tick/global fee state.
get fun getFeeGrowthInside(
    tickLower: int,
    tickUpper: int,
    tickCurrent: int,
    feeGrowthGlobal0X128: int,
    feeGrowthGlobal1X128: int,
): GetFeeGrowthInsideReply {
    throw 0;
}

/// Return deterministic AccountV3 address for a user.
get fun getUserAccountAddress(userAddress: address): address {
    throw 0;
}

/// Return standard NFT collection data for pool Position NFTs.
get fun get_collection_data(): GetCollectionDataReply {
    throw 0;
}

/// Return deterministic Position NFT address for an item index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return full NFT item content for a Position NFT index and base item content cell.
get fun get_nft_content(index: int, nftv3itemContent: cell): cell {
    throw 0;
}
