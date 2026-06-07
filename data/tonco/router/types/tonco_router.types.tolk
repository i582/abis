/// TONCO Router interface for pool deployment, routing payloads, and child code getters.
contract ToncoRouter {
    author: "Algebra / TONCO"
    version: "1.0"
    description: "Curated TONCO Router ABI for pool creation, Jetton notification routing, pay-to callbacks, admin changes, deterministic pool derivation, and child code discovery"
    storage: ToncoRouterStorage
    incomingMessages: ToncoRouterIncomingMessage
    outgoingMessages: ToncoRouterOutgoingMessage
    forceAbiExport: ToncoPayToPayload | ToncoRouterJettonForwardPayload
}

/// Runtime Router storage loaded from the root data cell.
struct ToncoRouterStorage {
    /// Router admin authorized for Router-level changes.
    adminAddress: address
    /// Admin address assigned to newly created pools.
    poolAdminAddress: address
    /// PoolFactory address currently paired with this Router.
    poolFactoryAddress: address
    /// Active Router flags returned by `getRouterState`.
    flags: uint64
    /// Router pool sequence number returned by `getRouterState`.
    poolSeqno: uint64
    /// Referenced child contract code bundle.
    childContracts: Cell<ToncoRouterChildContracts>
    /// Referenced timelock state encoded as delay plus three optional staged update cells.
    timelocks: Cell<ToncoRouterTimelocks>
    /// Referenced packed Router numeric parameters loaded only when the trailing ref exists.
    packedParams: Cell<ToncoRouterPackedParams>
}

/// Referenced Router child code bundle.
struct ToncoRouterChildContracts {
    /// PoolV3 implementation code installed by the Router.
    poolv3Code: cell
    /// AccountV3 implementation code installed by pools.
    accountv3Code: cell
    /// Position NFT V3 implementation code installed by pools.
    positionNftv3Code: cell
}

/// Referenced Router timelock state.
struct ToncoRouterTimelocks {
    /// Delay value used by delayed admin updates.
    delay: uint64
    /// Optional staged code update cell encoded as `Maybe ^Cell`.
    codeUpdate: cell?
    /// Optional staged address update cell encoded as `Maybe ^Cell`.
    addressUpdate: cell?
    /// Optional staged flags update cell encoded as `Maybe ^Cell`.
    flagsUpdate: cell?
}

/// Referenced Router packed numeric parameters from the trailing storage ref.
struct ToncoRouterPackedParams {
    /// Packed 16-bit parameter; decompiled default is `1500` when the ref is absent.
    param16: uint16
    /// Packed 60-bit parameter; exact semantic name is not published in saved source evidence.
    param60: uint60
    /// First packed 256-bit mask or accumulator; semantic name remains inferred.
    param256A: uint256
    /// Second packed 256-bit mask or accumulator; semantic name remains inferred.
    param256B: uint256
}

/// Structured return value of `getRouterState`.
struct GetRouterStateReply {
    /// Router admin address.
    routerAdminAddress: address
    /// Pool admin address assigned to newly created pools.
    poolAdminAddress: address
    /// Current PoolFactory address.
    poolFactoryAddress: address
    /// Active Router flags.
    activeFlags: int
    /// Router pool sequence number.
    poolSeqno: int
}

/// Structured return value of Router `getChildContracts`.
struct GetChildContractsReply {
    /// PoolV3 implementation code cell.
    poolCode: cell
    /// AccountV3 implementation code cell.
    accountCode: cell
    /// Position NFT V3 implementation code cell.
    positionNftCode: cell
}

/// Referenced Jetton minter/controller cell in Router create-pool messages.
struct Routerv3CreatePoolMinterCell {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
    /// Controller assigned to the new pool.
    controllerAddress: address
}

/// PoolFactory-to-Router message that creates or initializes a TONCO pool.
struct (0x2e3034ef) Routerv3CreatePool {
    /// Query id propagated through the pool creation flow.
    queryId: uint64
    /// Pool Jetton wallet for token0.
    jettonWallet0: address
    /// Pool Jetton wallet for token1.
    jettonWallet1: address
    /// Pool tick spacing.
    tickSpacing: int24
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// Whether the Router should activate the pool immediately.
    activatePool: bool
    /// Protocol fee stored by the pool.
    protocolFee: uint16
    /// Base LP fee stored by the pool.
    lpFeeBase: uint16
    /// Current active LP fee stored by the pool.
    lpFeeCurrent: uint16
    /// Pool NFT collection metadata content.
    nftv3Content: cell
    /// Position NFT item metadata content.
    nftv3itemContent: cell
    /// Referenced minter/controller data.
    minterCell: Cell<Routerv3CreatePoolMinterCell>
}

/// Standard Jetton transfer notification consumed by the Router for swap/fund payloads.
struct (0x7362d09c) JettonTransferNotification {
    /// Query id copied from the Jetton transfer.
    queryId: uint64
    /// Transferred Jetton amount.
    jettonAmount: coins
    /// User address from the Jetton notification body.
    fromUser: address
    /// Raw forward payload decoded separately as `ToncoRouterJettonForwardPayload`.
    forwardPayload: RemainingBitsAndRefs
}

/// Router pay-to callback used to distribute swap, mint, burn, or refund outputs.
struct (0xa1daa96d) Routerv3PayTo {
    /// Query id propagated through the pay-to flow.
    queryId: uint64
    /// Receiver for token0-side funds.
    receiver0: address
    /// Receiver for token1-side funds.
    receiver1: address
    /// Inline nested pay-to payload variant.
    payTo: ToncoPayToPayload
}

/// Admin command that returns Router excess TON after preserving storage reserve.
struct (0x42a0fb43) Routerv3ResetGas {
    /// Query id for tracing the reset-gas command.
    queryId: uint64
}

/// Admin command that stages Router admin, flag, or code changes.
struct (0xd4deb03b) Routerv3ChangeAdminStart {
    /// Query id for the staged change.
    queryId: uint64
    /// True when `newAdmin` is present and should be staged.
    hasNewAdmin: bool
    /// Replacement admin address when `hasNewAdmin` is true.
    newAdmin: address
    /// True when `newFlags` is present and should be staged.
    hasNewFlags: bool
    /// Replacement Router flags when `hasNewFlags` is true.
    newFlags: uint64
    /// Optional replacement code cell.
    newCode: cell?
}

/// Admin command that commits a previously staged Router change.
struct (0x98bac405) Routerv3ChangeAdminCommit {
    /// Query id for the commit command.
    queryId: uint64
}

/// Admin command that changes PoolFactory or pool-admin Router parameters.
struct (0x87ffe363) Routerv3ChangeParams {
    /// Query id for the parameter change.
    queryId: uint64
    /// True when `newPoolFactory` is present and should be applied.
    hasNewPoolFactory: bool
    /// Replacement PoolFactory address.
    newPoolFactory: address
    /// True when `newPoolAdmin` is present and should be applied.
    hasNewPoolAdmin: bool
    /// Replacement pool admin address.
    newPoolAdmin: address
}

/// Referenced swap parameters forwarded by Router to PoolV3.
struct Poolv3SwapParamsCell {
    /// Swap input amount, in source Jetton basic units.
    amount: coins
    /// Square-root price Q96 limit.
    sqrtPriceLimitX96: uint160
    /// Minimum output amount accepted by the user.
    minOutAmount: coins
}

/// Referenced swap callback payload destinations and optional payload cells.
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
    /// Query id propagated to pool callbacks.
    queryId: uint64
    /// User that owns the swap operation.
    ownerAddress: address
    /// Jetton wallet that supplied the input tokens.
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
    /// Requested liquidity for a mint order.
    liquidity: uint128
    /// Lower tick boundary for the mint order.
    tickLower: int24
    /// Upper tick boundary for the mint order.
    tickUpper: int24
}

/// Referenced Jetton minter pair cell in PoolV3 init.
struct Poolv3InitMinterCell {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
}

/// Router-to-Pool initialization message.
struct (0x441c39ed) Poolv3Init {
    /// Query id propagated through pool initialization.
    queryId: uint64
    /// True when the message is admin-originated.
    fromAdmin: bool
    /// True when `adminAddr` should replace the pool admin.
    hasAdmin: bool
    /// Pool admin address.
    adminAddr: address
    /// True when `controllerAddr` should replace the controller.
    hasController: bool
    /// Pool controller address.
    controllerAddr: address
    /// True when `tickSpacing` should be applied.
    setSpacing: bool
    /// Pool tick spacing.
    tickSpacing: int24
    /// True when `initialPriceX96` should initialize price.
    setPrice: bool
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// True when `poolActive` should be applied.
    setActive: bool
    /// Pool active flag.
    poolActive: bool
    /// Protocol fee stored by the pool.
    protocolFee: uint16
    /// Base LP fee stored by the pool.
    lpFeeBase: uint16
    /// Current active LP fee stored by the pool.
    lpFeeCurrent: uint16
    /// Pool NFT collection metadata content.
    nftv3Content: cell
    /// Position NFT item metadata content.
    nftv3itemContent: cell
    /// Optional referenced Jetton minter pair.
    minterCell: Cell<Poolv3InitMinterCell>?
}

/// Nested pay-to payload variant for exit code 0.
struct (0x00000000) PayToCode0 {
    /// Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information cell.
    coinsinfoCell: Cell<PayToCoinsinfoCell>?
}

/// Nested pay-to payload variant for swap payout code 200.
struct (0x000000c8) PayToCode200 {
    /// Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information and payload cell.
    coinsinfoCell: Cell<PayToCoinsinfoWithPayloadCell>?
    /// Optional referenced swap indexer information.
    indexerSwapInfoCell: Cell<PayToIndexerSwapInfoCell>?
}

/// Nested pay-to payload variant for burn payout code 201.
struct (0x000000c9) PayToCode201 {
    /// Router sequence number attached to the payout.
    seqno: uint64
    /// Optional referenced coin information and payload cell.
    coinsinfoCell: Cell<PayToCoinsinfoWithPayloadCell>?
    /// Optional referenced burn indexer information.
    indexerBurnInfoCell: Cell<PayToIndexerBurnInfoCell>?
}

/// Nested pay-to payload variant for swap payout code 230.
struct (0x000000e6) PayToCode230 {
    /// Router sequence number attached to the payout.
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

/// Optional multihop parameters in Router Jetton forward swap payloads.
struct ToncoPoolSwapForwardPayloadMultihopCell {
    /// Next-hop target address.
    targetAddress: address
    /// TON amount forwarded on successful hop.
    okForwardAmount: coins
    /// Optional payload forwarded on successful hop.
    okForwardPayload: cell?
    /// TON amount forwarded on returned/refunded hop.
    retForwardAmount: coins
    /// Optional payload forwarded on returned/refunded hop.
    retForwardPayload: cell?
    /// Address receiving excess TON from multihop processing.
    excessAddress: address
}

/// Router Jetton forward payload for swaps.
struct (0xa7fb58f8) ToncoPoolSwapForwardPayload {
    /// Target pool Jetton wallet to receive input tokens.
    targetJettonWallet: address
    /// Square-root price Q96 limit.
    sqrtPriceLimitX96: uint160
    /// Minimum output amount accepted by the user.
    minOutAmount: coins
    /// User that owns the swap operation.
    ownerAddress: address
    /// Optional referenced multihop data.
    multihopCell: Cell<ToncoPoolSwapForwardPayloadMultihopCell>?
}

/// Router Jetton forward payload for funding the sender's AccountV3.
struct (0x4468de77) ToncoPoolFundAccountPayload {
    /// Target pool Jetton wallet.
    jettonTargetWallet: address
    /// First enough threshold from the Jetton forward payload before Router token-order normalization.
    enough0: coins
    /// Second enough threshold from the Jetton forward payload before Router token-order normalization.
    enough1: coins
    /// Requested liquidity for a mint order.
    liquidity: uint128
    /// Lower tick boundary for the mint order.
    tickLower: int24
    /// Upper tick boundary for the mint order.
    tickUpper: int24
}

/// Router Jetton forward payload for funding another user's AccountV3.
struct (0x134b6d30) ToncoPoolFundSomeonesAccountPayload {
    /// Target pool Jetton wallet.
    jettonTargetWallet: address
    /// User whose AccountV3 should receive the funds.
    toUser: address
}

/// Jetton notification forward payload variants accepted by the Router.
type ToncoRouterJettonForwardPayload =
    | ToncoPoolSwapForwardPayload
    | ToncoPoolFundAccountPayload
    | ToncoPoolFundSomeonesAccountPayload

/// Internal message bodies accepted by TONCO Router.
type ToncoRouterIncomingMessage =
    | Routerv3CreatePool
    | JettonTransferNotification
    | Routerv3PayTo
    | Routerv3ResetGas
    | Routerv3ChangeAdminStart
    | Routerv3ChangeAdminCommit
    | Routerv3ChangeParams

/// Internal message bodies emitted by TONCO Router.
type ToncoRouterOutgoingMessage =
    | Poolv3Init
    | Poolv3Swap
    | Poolv3FundAccount

/// Return Router admin state, PoolFactory address, active flags, and pool sequence number.
get fun getRouterState(): GetRouterStateReply {
    throw 0;
}

/// Return deterministic pool address for a pair of pool Jetton wallets.
get fun getPoolAddress(jettonWallet0: address, jettonWallet1: address): address {
    throw 0;
}

/// Return Router child implementation code cells.
get fun getChildContracts(): GetChildContractsReply {
    throw 0;
}

/// Return deterministic initial Pool data cell for a pair of pool Jetton wallets.
get fun getPoolInitialData(jettonWallet0: address, jettonWallet1: address): cell {
    throw 0;
}

/// Return deterministic Pool StateInit cell for a pair of pool Jetton wallets.
get fun getPoolStateInit(jettonWallet0: address, jettonWallet1: address): cell {
    throw 0;
}
