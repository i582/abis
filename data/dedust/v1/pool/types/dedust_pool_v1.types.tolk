/// Curated ABI for the DeDust Pool v1 implementation.
contract DedustPoolV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust Pool v1 ABI for swaps, liquidity deposit callbacks, LP Jetton getters, protocol-fee withdrawal, public pool getters, and exit codes."
    storage: DedustPoolV1Storage
    incomingMessages: DedustPoolV1IncomingMessage
    outgoingMessages: DedustPoolV1OutgoingMessage
    thrownErrors: DedustPoolV1Errors
}

/// Runtime Pool storage loaded from the v1 root data cell.
struct DedustPoolV1Storage {
    /// Pool proof containing Factory address, contract type, and pair identity.
    proof: Cell<DedustPoolV1PoolProof>
    /// Code cell used with the proof to authenticate deterministic DeDust child addresses.
    proofCode: cell
    /// LP Jetton wallet code returned by `get_jetton_data` and used by `get_wallet_address`.
    lpWalletCode: cell
    /// Referenced Pool configuration with decimals, Vault addresses, and fee collector.
    config: Cell<DedustPoolV1Config>
    /// Pool implementation version returned by `get_version`.
    version: uint16
    /// Trade fee numerator returned by `get_trade_fee`; denominator is fixed at 10000.
    tradeFeeNumerator: uint16
    /// Total LP Jetton supply returned by `get_jetton_data`.
    totalSupply: coins
    /// Current asset0 reserve.
    reserve0: coins
    /// Current asset1 reserve.
    reserve1: coins
    /// Accumulated protocol fee in asset0 units.
    asset0ProtocolFee: coins
    /// Accumulated protocol fee in asset1 units.
    asset1ProtocolFee: coins
}

/// Referenced Pool configuration cell.
struct DedustPoolV1Config {
    /// Asset0 decimals used for stable-pool normalization.
    asset0Decimals: uint8
    /// Asset1 decimals used for stable-pool normalization.
    asset1Decimals: uint8
    /// Vault address for asset0.
    asset0VaultAddr: address
    /// Vault address for asset1.
    asset1VaultAddr: address
    /// Fee collector allowed to withdraw accumulated protocol fees.
    feeCollectorAddr: address?
}

/// Native TON asset tag.
struct (0b0000) DedustPoolV1NativeAsset {}

/// Jetton asset tag with minter workchain and account hash.
struct (0b0001) DedustPoolV1JettonAsset {
    /// Jetton minter workchain id.
    workchainId: int8
    /// Jetton minter account hash.
    address: bits256
}

/// Asset variants accepted by Pool v1 messages and proofs.
type DedustPoolV1Asset =
    | DedustPoolV1NativeAsset
    | DedustPoolV1JettonAsset

/// Volatile curve tag used in pool parameters.
struct (0b0) DedustPoolV1VolatilePool {}

/// Stable curve tag used in pool parameters.
struct (0b1) DedustPoolV1StablePool {}

/// One-bit pool type represented by getters as `is_stable`.
type DedustPoolV1PoolType =
    | DedustPoolV1VolatilePool
    | DedustPoolV1StablePool

/// Pool identity tuple embedded in Pool and Liquidity Deposit proofs.
struct DedustPoolV1PoolParams {
    /// Pool curve type for the asset pair.
    poolType: DedustPoolV1PoolType
    /// First sorted pool asset.
    asset0: DedustPoolV1Asset
    /// Second sorted pool asset.
    asset1: DedustPoolV1Asset
}

/// Contract-type tag proving a sender is a DeDust Vault.
struct (0b00000001) DedustPoolV1VaultContractType {}

/// Contract-type tag proving a sender is a DeDust Pool.
struct (0b00000010) DedustPoolV1PoolContractType {}

/// Contract-type tag proving a sender is a DeDust Liquidity Deposit.
struct (0b00000011) DedustPoolV1LiquidityDepositContractType {}

/// Vault proof body referenced by swap-external messages.
struct DedustPoolV1VaultProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Vault tag for this proof shape.
    contractType: DedustPoolV1VaultContractType
    /// Vault asset committed into the proof.
    params: DedustPoolV1Asset
}

/// Pool proof body referenced by peer swaps, pool payouts, and callbacks.
struct DedustPoolV1PoolProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Pool tag for this proof shape.
    contractType: DedustPoolV1PoolContractType
    /// Pool identity committed into the proof.
    params: DedustPoolV1PoolParams
}

/// Referenced proof parameters for a Liquidity Deposit contract.
struct DedustPoolV1LiquidityDepositProofParams {
    /// Liquidity provider address that owns the deposit contract.
    ownerAddr: address
    /// Pool identity for which the deposit contract was derived.
    poolParams: DedustPoolV1PoolParams
}

/// Liquidity Deposit proof body referenced by deposit-liquidity-all messages.
struct DedustPoolV1LiquidityDepositProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Liquidity Deposit tag for this proof shape.
    contractType: DedustPoolV1LiquidityDepositContractType
    /// Referenced owner and pool-params tuple.
    params: Cell<DedustPoolV1LiquidityDepositProofParams>
}

/// Exact-input swap kind.
struct (0b0) DedustPoolV1GivenIn {}

/// Exact-output swap kind.
struct (0b1) DedustPoolV1GivenOut {}

/// One-bit swap kind embedded in each swap step.
type DedustPoolV1SwapKind =
    | DedustPoolV1GivenIn
    | DedustPoolV1GivenOut

/// Parameters for the current step of a routed swap.
struct DedustPoolV1SwapStepParams {
    /// Step kind.
    kind: DedustPoolV1SwapKind
    /// Minimum output for `given_in`, or the limit value for the step.
    limit: coins
    /// Optional next swap step for multi-hop routes.
    next: Cell<DedustPoolV1SwapStep>?
}

/// Full next-hop swap step referenced from step parameters.
struct DedustPoolV1SwapStep {
    /// Pool address responsible for the next hop.
    poolAddr: address
    /// Step kind, limit, and optional continuation.
    params: DedustPoolV1SwapStepParams
}

/// Whole-swap options stored in the required referenced swap-params cell.
struct DedustPoolV1SwapParams {
    /// Unix timestamp deadline, or zero when disabled.
    deadline: uint32
    /// Final recipient, or `addr_none` to use the default sender path.
    recipientAddr: address?
    /// Referral address, or `addr_none` when referral routing is disabled.
    referralAddr: address?
    /// Optional payload attached to successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload attached to rejection.
    rejectPayload: cell?
}

/// Referenced amounts cell inside `deposit_liquidity_all`.
struct DedustPoolV1DepositLiquidityAllAmounts {
    /// Asset0 identity from the Liquidity Deposit contract.
    asset0: DedustPoolV1Asset
    /// Amount of asset0 supplied by the deposit contract.
    asset0Amount: coins
    /// Asset1 identity from the Liquidity Deposit contract.
    asset1: DedustPoolV1Asset
    /// Amount of asset1 supplied by the deposit contract.
    asset1Amount: coins
}

/// Factory-to-Pool command that replaces Pool code with a newer version.
struct (0x000001bc) DedustPoolV1UpgradeCode {
    /// Query id copied from the Factory upgrade request.
    queryId: uint64
    /// New Pool code version.
    codeVersion: uint16
    /// Replacement Pool code cell.
    code: cell
}

/// Vault-to-Pool swap message for the first step of a user swap.
struct (0x61ee542d) DedustPoolV1SwapExternal {
    /// Query id copied from the initiating Vault message.
    queryId: uint64
    /// Referenced Vault proof authenticating the sending Vault and input asset.
    proof: Cell<DedustPoolV1VaultProof>
    /// Input amount routed from the Vault.
    amount: coins
    /// Original user or contract that initiated the swap.
    senderAddr: address
    /// Parameters for this Pool step.
    current: DedustPoolV1SwapStepParams
    /// Referenced whole-swap parameter cell.
    swapParams: Cell<DedustPoolV1SwapParams>
}

/// Pool-to-Pool peer swap message for later hops in a multi-hop route.
struct (0x72aca8aa) DedustPoolV1SwapPeer {
    /// Query id copied from the previous swap step.
    queryId: uint64
    /// Referenced Pool proof authenticating the sending Pool.
    proof: Cell<DedustPoolV1PoolProof>
    /// Asset being delivered into this Pool step.
    asset: DedustPoolV1Asset
    /// Input amount delivered into this Pool step.
    amount: coins
    /// Original user or contract that initiated the routed swap.
    senderAddr: address
    /// Parameters for this Pool step.
    current: DedustPoolV1SwapStepParams
    /// Referenced whole-swap parameter cell.
    swapParams: Cell<DedustPoolV1SwapParams>
}

/// Liquidity Deposit-to-Pool callback that supplies both assets and requests LP minting.
struct (0xb56b9598) DedustPoolV1DepositLiquidityAll {
    /// Query id copied from the Liquidity Deposit flow.
    queryId: uint64
    /// Referenced Liquidity Deposit proof authenticating the sender.
    proof: Cell<DedustPoolV1LiquidityDepositProof>
    /// Liquidity provider owner address.
    ownerAddr: address
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Referenced asset and amount tuple for both pool sides.
    depositAmounts: Cell<DedustPoolV1DepositLiquidityAllAmounts>
    /// Optional payload forwarded after successful deposit fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded after deposit rejection.
    rejectPayload: cell?
}

/// LP Jetton burn notification accepted by Pool-as-LP-minter to withdraw reserves.
struct (0x7bdd97de) DedustPoolV1JettonBurnNotification {
    /// Query id copied from the LP wallet burn request.
    queryId: uint64
    /// Amount of LP tokens burned.
    amount: coins
    /// LP token owner whose reserves should be released.
    sender: address
    /// Optional response destination from the burn request.
    responseDestination: address?
}

/// Fee-collector request to withdraw accumulated protocol fees.
struct (0x6230225b) DedustPoolV1WithdrawProtocolFees {
    /// Caller-selected query id.
    queryId: uint64
    /// Recipient of protocol-fee payouts.
    recipientAddr: address
    /// Optional payload forwarded through Vault payout messages.
    payload: cell?
}

/// Pool-to-Vault payout request used by swap, withdrawal, and protocol-fee flows.
struct (0xad4eb6f5) DedustPoolV1PayOutFromPool {
    /// Query id copied from the Pool operation.
    queryId: uint64
    /// Referenced Pool proof authenticating this Pool to the target Vault.
    proof: Cell<DedustPoolV1PoolProof>
    /// Asset amount to pay out through the Vault.
    amount: coins
    /// Final recipient address, or `addr_none` if the downstream Vault applies a default.
    recipientAddr: address?
    /// Optional recipient payload forwarded by the Vault payout.
    payload: cell?
}

/// Pool-to-Liquidity-Deposit success callback after LP accounting succeeds.
struct (0xaae79256) DedustPoolV1FulfillDeposit {
    /// Query id copied from the deposit-liquidity-all request.
    queryId: uint64
    /// Referenced Pool proof authenticating the Pool to the Liquidity Deposit contract.
    proof: Cell<DedustPoolV1PoolProof>
    /// Accepted asset0 amount.
    asset0Deposit: coins
    /// Accepted asset1 amount.
    asset1Deposit: coins
}

/// Pool-to-Liquidity-Deposit rejection callback when LP minting constraints fail.
struct (0xe1a36cd4) DedustPoolV1RejectDeposit {
    /// Query id copied from the deposit-liquidity-all request.
    queryId: uint64
    /// Referenced Pool proof authenticating the Pool to the Liquidity Deposit contract.
    proof: Cell<DedustPoolV1PoolProof>
    /// Optional payload selected by the original depositor.
    payload: cell?
}

/// LP wallet mint transfer emitted by Pool-as-LP-minter after successful liquidity deposit.
struct (0x178d4519) DedustPoolV1JettonInternalTransfer {
    /// Query id copied from the deposit-liquidity-all request.
    queryId: uint64
    /// Minted LP token amount.
    amount: coins
    /// Pool address used as the Jetton internal-transfer sender.
    fromAddress: address
    /// Response address for LP wallet excesses.
    responseAddress: address?
    /// Nanotons forwarded to the LP wallet owner.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Referenced tail for swap external event details.
struct DedustPoolV1SwapEventTail {
    /// User or contract that initiated the swap.
    senderAddr: address
    /// Referral address, or `addr_none` when no referral was used.
    referralAddr: address?
    /// Asset0 reserve after the swap.
    reserve0: coins
    /// Asset1 reserve after the swap.
    reserve1: coins
}

/// External event emitted after a successful swap.
struct (0x9c610de3) DedustPoolV1SwapEvent {
    /// Asset supplied to the Pool.
    assetIn: DedustPoolV1Asset
    /// Asset received from the Pool.
    assetOut: DedustPoolV1Asset
    /// Amount supplied by the user.
    amountIn: coins
    /// Amount received by the user.
    amountOut: coins
    /// Referenced sender, referral, and post-swap reserves.
    details: Cell<DedustPoolV1SwapEventTail>
}

/// External event emitted after successful liquidity deposit.
struct (0xb544f4a4) DedustPoolV1DepositEvent {
    /// Liquidity provider owner address.
    senderAddr: address
    /// Amount of asset0 accepted.
    amount0: coins
    /// Amount of asset1 accepted.
    amount1: coins
    /// Asset0 reserve after the deposit.
    reserve0: coins
    /// Asset1 reserve after the deposit.
    reserve1: coins
    /// LP tokens minted for the deposit.
    liquidity: coins
}

/// External event emitted after LP burn withdrawal.
struct (0x3aa870a6) DedustPoolV1WithdrawalEvent {
    /// LP token owner whose burn released reserves.
    senderAddr: address
    /// LP token amount burned.
    liquidity: coins
    /// Asset0 amount released.
    amount0: coins
    /// Asset1 amount released.
    amount1: coins
    /// Asset0 reserve after withdrawal.
    reserve0: coins
    /// Asset1 reserve after withdrawal.
    reserve1: coins
}

/// Internal message bodies accepted by the Pool v1 dispatcher.
type DedustPoolV1IncomingMessage =
    | DedustPoolV1UpgradeCode
    | DedustPoolV1SwapExternal
    | DedustPoolV1SwapPeer
    | DedustPoolV1DepositLiquidityAll
    | DedustPoolV1JettonBurnNotification
    | DedustPoolV1WithdrawProtocolFees

/// Internal payout/callback bodies and external event bodies emitted by Pool v1.
type DedustPoolV1OutgoingMessage =
    | DedustPoolV1PayOutFromPool
    | DedustPoolV1SwapPeer
    | DedustPoolV1FulfillDeposit
    | DedustPoolV1RejectDeposit
    | DedustPoolV1JettonInternalTransfer
    | DedustPoolV1SwapEvent
    | DedustPoolV1DepositEvent
    | DedustPoolV1WithdrawalEvent

/// Stack reply returned by `get_reserves`.
struct DedustPoolV1GetReservesReply {
    /// Current asset0 reserve.
    reserve0: int
    /// Current asset1 reserve.
    reserve1: int
}

/// Stack reply returned by `get_assets`; each slice encodes a `DedustPoolV1Asset`.
struct DedustPoolV1GetAssetsReply {
    /// Serialized asset0 slice.
    asset0: slice
    /// Serialized asset1 slice.
    asset1: slice
}

/// Stack reply returned by `get_trade_fee`.
struct DedustPoolV1GetTradeFeeReply {
    /// Trade-fee numerator.
    tradeFeeNumerator: uint16
    /// Trade-fee denominator.
    tradeFeeDenominator: uint16
}

/// Stack reply returned by `get_protocol_fees`.
struct DedustPoolV1GetProtocolFeesReply {
    /// Accumulated protocol fees for asset0.
    asset0ProtocolFee: int
    /// Accumulated protocol fees for asset1.
    asset1ProtocolFee: int
}

/// Stack reply returned by `estimate_swap_out`.
struct DedustPoolV1EstimateSwapOutReply {
    /// Serialized output asset slice.
    assetOut: slice
    /// Estimated output amount.
    amountOut: int
    /// Estimated trade fee charged in the input asset.
    tradeFee: int
}

/// Stack reply returned by `estimate_deposit_out`.
struct DedustPoolV1EstimateDepositOutReply {
    /// Asset0 amount that would be accepted.
    asset0Deposit: int
    /// Asset1 amount that would be accepted.
    asset1Deposit: int
    /// Estimated fair LP supply contribution.
    fairSupply: int
}

/// Stack reply returned by Pool-as-LP-Jetton-minter `get_jetton_data`.
struct DedustPoolV1JettonDataReply {
    /// Total LP token supply.
    totalSupply: int
    /// Pool can mint LP tokens through liquidity deposit callbacks.
    mintable: bool
    /// Admin stack address; pools return `addr_none`.
    adminAddress: any_address
    /// LP token metadata content cell.
    jettonContent: cell
    /// LP wallet code cell.
    jettonWalletCode: cell
}

/// DeDust Pool v1 exit-code catalog.
enum DedustPoolV1Errors {
    /// LP burn notification or protocol-fee sender is not authorized.
    InvalidLpOrFeeSender = 257
    /// Control message sender is not the stored Factory/proof address.
    InvalidControlSender = 259
    /// Asset tag or proof shape is invalid for this Pool.
    InvalidAssetOrProof = 261
    /// Swap-external sender is not the authenticated Vault.
    InvalidVaultSender = 264
    /// Swap-peer sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Liquidity-deposit callback sender is not the authenticated deposit contract.
    InvalidLiquidityDepositSender = 272
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the DeDust Pool code/interface version.
get fun get_version(): uint16 {
    throw 0;
}

/// Return whether this Pool instance is stable-swap.
get fun is_stable(): bool {
    throw 0;
}

/// Return the current trade-fee numerator and denominator.
get fun get_trade_fee(): DedustPoolV1GetTradeFeeReply {
    throw 0;
}

/// Return current asset reserves.
get fun get_reserves(): DedustPoolV1GetReservesReply {
    throw 0;
}

/// Return accumulated protocol fees for both assets.
get fun get_protocol_fees(): DedustPoolV1GetProtocolFeesReply {
    throw 0;
}

/// Return serialized asset identifiers for this Pool.
get fun get_assets(): DedustPoolV1GetAssetsReply {
    throw 0;
}

/// Estimate output amount and fee for a serialized input asset and amount.
get fun estimate_swap_out(assetIn: slice, amountIn: int): DedustPoolV1EstimateSwapOutReply {
    throw 0;
}

/// Estimate accepted deposit amounts and fair LP supply for proposed asset amounts.
get fun estimate_deposit_out(amount0: int, amount1: int): DedustPoolV1EstimateDepositOutReply {
    throw 0;
}

/// Return LP Jetton minter data for the Pool.
get fun get_jetton_data(): DedustPoolV1JettonDataReply {
    throw 0;
}

/// Return the deterministic LP wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}
