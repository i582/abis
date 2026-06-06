/// DeDust Protocol v2 Pool interface covering volatile and stable pools sharing the verified live code hash.
contract DedustPoolV2 {
    author: "DeDust"
    version: "2.0"
    description: "Curated DeDust v2 Pool ABI for swaps, liquidity deposit callbacks, LP Jetton getters, public pool getters, and exit codes."
    storage: DedustPoolV2Storage
    incomingMessages: DedustPoolV2IncomingMessage
    outgoingMessages: DedustPoolV2OutgoingMessage
}

/// Runtime Pool storage loaded by the verified v2 Pool code root data cell.
struct DedustPoolV2Storage {
    /// Pool proof containing Factory address, contract type, and pair identity.
    proof: Cell<DedustPoolV2PoolProof>
    /// Code cell used with the proof to authenticate deterministic DeDust child addresses.
    proofCode: cell
    /// LP Jetton wallet code returned by `get_jetton_data` and used by `get_wallet_address`.
    lpWalletCode: cell
    /// Referenced Pool configuration with decimals, Vault addresses, fee receiver, and optional quote-provider data.
    config: Cell<DedustPoolV2Config>
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
    /// Cumulative price accumulator for asset0.
    cumulativePrice0: uint128
    /// Cumulative price accumulator for asset1.
    cumulativePrice1: uint128
}

/// Referenced Pool configuration cell loaded by safe getters.
struct DedustPoolV2Config {
    /// Asset0 decimals used for stable-pool normalization.
    asset0Decimals: uint8
    /// Asset1 decimals used for stable-pool normalization.
    asset1Decimals: uint8
    /// Vault address for asset0.
    asset0VaultAddr: address
    /// Vault address for asset1.
    asset1VaultAddr: address
    /// Optional fee collector address; initial installed storage stores `addr_none`.
    feeCollectorAddr: address?
    /// Optional extra quote-provider dictionary.
    quoteProviderData: cell?
}

/// Native TON asset tag used in Pool assets and proofs.
struct (0b0000) DedustPoolV2NativeAsset {}

/// Jetton asset tag with minter workchain and account hash.
struct (0b0001) DedustPoolV2JettonAsset {
    /// Jetton minter workchain id.
    workchainId: int8
    /// Jetton minter account hash.
    address: bits256
}

/// Asset variants proven by saved SDK artifacts, the local Toncenter TL-B excerpt, and live examples.
type DedustPoolV2Asset =
    | DedustPoolV2NativeAsset
    | DedustPoolV2JettonAsset

/// Volatile curve tag used in pool parameters and proofs.
struct (0b0) DedustPoolV2VolatilePool {}

/// Stable curve tag used in pool parameters and proofs.
struct (0b1) DedustPoolV2StablePool {}

/// One-bit pool type, represented by docs as volatile/stable and by Toncenter as `is_stable`.
type DedustPoolV2PoolType =
    | DedustPoolV2VolatilePool
    | DedustPoolV2StablePool

/// Pool identity tuple embedded in pool proofs and liquidity-deposit requests.
struct DedustPoolV2PoolParams {
    /// Pool curve type for the asset pair.
    poolType: DedustPoolV2PoolType
    /// First sorted pool asset.
    asset0: DedustPoolV2Asset
    /// Second sorted pool asset.
    asset1: DedustPoolV2Asset
}

/// Contract-type tag proving a sender is a DeDust Vault.
struct (0b00000001) DedustPoolV2VaultContractType {}

/// Contract-type tag proving a sender is a DeDust Pool.
struct (0b00000010) DedustPoolV2PoolContractType {}

/// Contract-type tag proving a sender is a DeDust Liquidity Deposit.
struct (0b00000011) DedustPoolV2LiquidityDepositContractType {}

/// Vault proof body referenced by swap-external messages.
struct DedustPoolV2VaultProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Vault tag for this proof shape.
    contractType: DedustPoolV2VaultContractType
    /// Vault asset committed into the proof.
    params: DedustPoolV2Asset
}

/// Pool proof body referenced by peer swaps, pool payouts, and liquidity callbacks.
struct DedustPoolV2PoolProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Pool tag for this proof shape.
    contractType: DedustPoolV2PoolContractType
    /// Pool identity committed into the proof.
    params: DedustPoolV2PoolParams
}

/// Referenced proof parameters for a Liquidity Deposit contract.
struct DedustPoolV2LiquidityDepositProofParams {
    /// Liquidity provider address that owns the deposit contract.
    ownerAddr: address
    /// Pool identity for which the deposit contract was derived.
    poolParams: DedustPoolV2PoolParams
}

/// Liquidity Deposit proof body referenced by deposit-liquidity-all messages.
struct DedustPoolV2LiquidityDepositProof {
    /// DeDust Factory address committed into the proof.
    factoryAddr: address
    /// Contract-type byte; must be the Liquidity Deposit tag for this proof shape.
    contractType: DedustPoolV2LiquidityDepositContractType
    /// Referenced owner and pool-params tuple.
    params: Cell<DedustPoolV2LiquidityDepositProofParams>
}

/// Exact-input swap kind used by SDK and observed live swap bodies.
struct (0b0) DedustPoolV2GivenIn {}

/// Exact-output swap kind listed in docs but not used by the SDK examples.
struct (0b1) DedustPoolV2GivenOut {}

/// One-bit swap kind embedded in each swap step.
type DedustPoolV2SwapKind =
    | DedustPoolV2GivenIn
    | DedustPoolV2GivenOut

/// Parameters for the current step of a routed swap.
struct DedustPoolV2SwapStepParams {
    /// Step kind; live public routes use `given_in`.
    kind: DedustPoolV2SwapKind
    /// Minimum output for `given_in`, or the limit value for the step.
    limit: coins
    /// Optional next swap step for multi-hop routes.
    next: Cell<DedustPoolV2SwapStep>?
}

/// Full next-hop swap step referenced from step parameters.
struct DedustPoolV2SwapStep {
    /// Pool address responsible for the next hop.
    poolAddr: address
    /// Step kind, limit, and optional continuation.
    params: DedustPoolV2SwapStepParams
}

/// Whole-swap options stored in the required referenced swap-params cell.
struct DedustPoolV2SwapParams {
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
struct DedustPoolV2DepositLiquidityAllAmounts {
    /// Asset0 identity from the Liquidity Deposit contract.
    asset0: DedustPoolV2Asset
    /// Amount of asset0 supplied by the deposit contract.
    asset0Amount: coins
    /// Asset1 identity from the Liquidity Deposit contract.
    asset1: DedustPoolV2Asset
    /// Amount of asset1 supplied by the deposit contract.
    asset1Amount: coins
}

/// Vault-to-Pool swap message for the first step of a user swap.
struct (0x61ee542d) DedustPoolV2SwapExternal {
    /// Query id copied from the initiating Vault message.
    queryId: uint64
    /// Referenced Vault proof authenticating the sending Vault and input asset.
    proof: Cell<DedustPoolV2VaultProof>
    /// Input amount routed from the Vault.
    amount: coins
    /// Original user or contract that initiated the swap.
    senderAddr: address
    /// Parameters for this Pool step.
    current: DedustPoolV2SwapStepParams
    /// Referenced whole-swap parameter cell.
    swapParams: Cell<DedustPoolV2SwapParams>
}

/// Pool-to-Pool peer swap message for later hops in a multi-hop route.
struct (0x72aca8aa) DedustPoolV2SwapPeer {
    /// Query id copied from the previous swap step.
    queryId: uint64
    /// Referenced Pool proof authenticating the sending Pool.
    proof: Cell<DedustPoolV2PoolProof>
    /// Asset being delivered into this Pool step.
    asset: DedustPoolV2Asset
    /// Input amount delivered into this Pool step.
    amount: coins
    /// Original user or contract that initiated the routed swap.
    senderAddr: address
    /// Parameters for this Pool step.
    current: DedustPoolV2SwapStepParams
    /// Referenced whole-swap parameter cell.
    swapParams: Cell<DedustPoolV2SwapParams>
}

/// Liquidity Deposit-to-Pool callback that supplies both assets and requests LP minting.
struct (0xb56b9598) DedustPoolV2DepositLiquidityAll {
    /// Query id copied from the Liquidity Deposit flow.
    queryId: uint64
    /// Referenced Liquidity Deposit proof authenticating the sender.
    proof: Cell<DedustPoolV2LiquidityDepositProof>
    /// Liquidity provider owner address.
    ownerAddr: address
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Referenced asset and amount tuple for both pool sides.
    depositAmounts: Cell<DedustPoolV2DepositLiquidityAllAmounts>
    /// Optional payload forwarded after successful deposit fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded after deposit rejection.
    rejectPayload: cell?
}

/// LP Jetton burn notification accepted by Pool-as-LP-minter to withdraw reserves.
struct (0x7bdd97de) DedustPoolV2JettonBurnNotification {
    /// Query id copied from the LP wallet burn request.
    queryId: uint64
    /// Amount of LP tokens burned.
    amount: coins
    /// LP token owner whose reserves should be released.
    sender: address
    /// Optional response destination from the burn request.
    responseDestination: address?
}

/// Pool-to-Vault payout request used by swap and withdrawal flows.
struct (0xad4eb6f5) DedustPoolV2PayOutFromPool {
    /// Query id copied from the Pool operation.
    queryId: uint64
    /// Referenced Pool proof authenticating this Pool to the target Vault.
    proof: Cell<DedustPoolV2PoolProof>
    /// Asset amount to pay out through the Vault.
    amount: coins
    /// Final recipient address, or `addr_none` if the downstream Vault applies a default.
    recipientAddr: address?
    /// Optional recipient payload forwarded by the Vault payout.
    payload: cell?
}

/// Pool-to-Liquidity-Deposit success callback after LP accounting succeeds.
struct (0xaae79256) DedustPoolV2FulfillDeposit {
    /// Query id copied from the deposit-liquidity-all request.
    queryId: uint64
    /// Referenced Pool proof authenticating the Pool to the Liquidity Deposit contract.
    proof: Cell<DedustPoolV2PoolProof>
    /// Accepted asset0 amount.
    asset0Deposit: coins
    /// Accepted asset1 amount.
    asset1Deposit: coins
}

/// Pool-to-Liquidity-Deposit rejection callback when LP minting constraints fail.
struct (0xe1a36cd4) DedustPoolV2RejectDeposit {
    /// Query id copied from the deposit-liquidity-all request.
    queryId: uint64
    /// Referenced Pool proof authenticating the Pool to the Liquidity Deposit contract.
    proof: Cell<DedustPoolV2PoolProof>
    /// Optional payload selected by the original depositor.
    payload: cell?
}

/// LP wallet mint transfer emitted by Pool-as-LP-minter after successful liquidity deposit.
struct (0x178d4519) DedustPoolV2JettonInternalTransfer {
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
struct DedustPoolV2SwapEventTail {
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
struct (0x9c610de3) DedustPoolV2SwapEvent {
    /// Asset supplied to the Pool.
    assetIn: DedustPoolV2Asset
    /// Asset received from the Pool.
    assetOut: DedustPoolV2Asset
    /// Amount supplied by the user.
    amountIn: coins
    /// Amount received by the user.
    amountOut: coins
    /// Referenced sender, referral, and post-swap reserves.
    details: Cell<DedustPoolV2SwapEventTail>
}

/// External event emitted after successful liquidity deposit.
struct (0xb544f4a4) DedustPoolV2DepositEvent {
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
struct (0x3aa870a6) DedustPoolV2WithdrawalEvent {
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

/// Internal message bodies accepted by the verified Pool v2 code hash.
type DedustPoolV2IncomingMessage =
    | DedustPoolV2SwapExternal
    | DedustPoolV2SwapPeer
    | DedustPoolV2DepositLiquidityAll
    | DedustPoolV2JettonBurnNotification

/// Internal payout/callback bodies and external event bodies emitted by Pool v2.
type DedustPoolV2OutgoingMessage =
    | DedustPoolV2PayOutFromPool
    | DedustPoolV2SwapPeer
    | DedustPoolV2FulfillDeposit
    | DedustPoolV2RejectDeposit
    | DedustPoolV2JettonInternalTransfer
    | DedustPoolV2SwapEvent
    | DedustPoolV2DepositEvent
    | DedustPoolV2WithdrawalEvent

/// Stack reply returned by `get_reserves`.
struct DedustPoolV2GetReservesReply {
    /// Current asset0 reserve.
    reserve0: int
    /// Current asset1 reserve.
    reserve1: int
}

/// Stack reply returned by `get_assets`; each slice encodes a `DedustPoolV2Asset`.
struct DedustPoolV2GetAssetsReply {
    /// Serialized asset0 slice.
    asset0: slice
    /// Serialized asset1 slice.
    asset1: slice
}

/// Stack reply returned by `get_trade_fee`.
struct DedustPoolV2GetTradeFeeReply {
    /// Trade-fee numerator.
    tradeFeeNumerator: uint16
    /// Trade-fee denominator, observed as 10000.
    tradeFeeDenominator: uint16
}

/// Stack reply returned by `get_protocol_fees`.
struct DedustPoolV2GetProtocolFeesReply {
    /// Accumulated protocol fees for asset0.
    asset0ProtocolFee: int
    /// Accumulated protocol fees for asset1.
    asset1ProtocolFee: int
}

/// Stack reply returned by `estimate_swap_out`.
struct DedustPoolV2EstimateSwapOutReply {
    /// Serialized output asset slice.
    assetOut: slice
    /// Estimated output amount.
    amountOut: int
    /// Estimated trade fee charged in the input asset.
    tradeFee: int
}

/// Stack reply returned by SDK getter `estimate_deposit_out`.
struct DedustPoolV2EstimateDepositOutReply {
    /// Asset0 amount that would be accepted.
    asset0Deposit: int
    /// Asset1 amount that would be accepted.
    asset1Deposit: int
    /// Estimated fair LP supply contribution.
    fairSupply: int
}

/// Stack reply returned by Pool-as-LP-Jetton-minter `get_jetton_data`.
struct DedustPoolV2JettonDataReply {
    /// Total LP token supply.
    totalSupply: int
    /// Pool can mint LP tokens through liquidity deposit callbacks.
    mintable: bool
    /// Admin stack address; live pools return `addr_none`.
    adminAddress: any_address
    /// LP token metadata content cell.
    jettonContent: cell
    /// LP wallet code cell.
    jettonWalletCode: cell
}

/// DeDust Pool v2 exit-code catalog.
enum DedustPoolV2Errors {
    /// LP burn notification sender is not the deterministic LP wallet.
    InvalidLpWalletSender = 257
    /// Control message sender is not the stored Factory/proof address.
    InvalidControlSender = 259
    /// Asset tag or proof shape is invalid for this Pool.
    InvalidAssetOrProof = 261
    /// Attached value cannot cover the required downstream fee budget.
    InsufficientValue = 263
    /// Swap-external sender is not the authenticated Vault.
    InvalidVaultSender = 264
    /// Swap-peer sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Liquidity-deposit callback sender is not the authenticated deposit contract.
    InvalidLiquidityDepositSender = 272
    /// Trade fee is outside the accepted range.
    InvalidTradeFee = 279
    /// Message token wallet does not match either Pool asset wallet.
    InvalidTokenWallet = 288
    /// Payout target address is absent.
    MissingPayoutTarget = 289
    /// Withdrawal branch does not match the requested asset side.
    InvalidWithdrawalAsset = 290
    /// Requested asset does not match either Pool asset.
    InvalidRequestAsset = 291
    /// Requested amount must be positive.
    InvalidAmount = 292
    /// Protocol-fee withdrawal exceeds accumulated fees.
    ProtocolFeeExceeded = 293
    /// Pool has no LP supply for swap pricing.
    EmptyLiquidity = 294
    /// Deterministic child-contract sender does not match the expected address.
    InvalidChildSender = 296
    /// Swap output is below the requested minimum.
    SlippageExceeded = 304
    /// Swap deadline has passed.
    DeadlineExceeded = 305
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the DeDust Pool code/interface version.
get fun get_version(): uint16 {
    assert (true) throw DedustPoolV2Errors.InvalidLpWalletSender;
    assert (true) throw DedustPoolV2Errors.InvalidControlSender;
    assert (true) throw DedustPoolV2Errors.InvalidAssetOrProof;
    assert (true) throw DedustPoolV2Errors.InsufficientValue;
    assert (true) throw DedustPoolV2Errors.InvalidVaultSender;
    assert (true) throw DedustPoolV2Errors.InvalidPoolSender;
    assert (true) throw DedustPoolV2Errors.InvalidLiquidityDepositSender;
    assert (true) throw DedustPoolV2Errors.InvalidTradeFee;
    assert (true) throw DedustPoolV2Errors.InvalidTokenWallet;
    assert (true) throw DedustPoolV2Errors.MissingPayoutTarget;
    assert (true) throw DedustPoolV2Errors.InvalidWithdrawalAsset;
    assert (true) throw DedustPoolV2Errors.InvalidRequestAsset;
    assert (true) throw DedustPoolV2Errors.InvalidAmount;
    assert (true) throw DedustPoolV2Errors.ProtocolFeeExceeded;
    assert (true) throw DedustPoolV2Errors.EmptyLiquidity;
    assert (true) throw DedustPoolV2Errors.InvalidChildSender;
    assert (true) throw DedustPoolV2Errors.SlippageExceeded;
    assert (true) throw DedustPoolV2Errors.DeadlineExceeded;
    assert (true) throw DedustPoolV2Errors.UnsupportedOperation;
    return 0;
}

/// Return whether this Pool instance is stable-swap.
get fun is_stable(): bool {
    return false;
}

/// Return the current trade-fee numerator and denominator.
get fun get_trade_fee(): DedustPoolV2GetTradeFeeReply {
    return {
        tradeFeeNumerator: 0,
        tradeFeeDenominator: 0,
    };
}

/// Return current asset reserves.
get fun get_reserves(): DedustPoolV2GetReservesReply {
    return {
        reserve0: 0,
        reserve1: 0,
    };
}

/// Return accumulated protocol fees for both assets.
get fun get_protocol_fees(): DedustPoolV2GetProtocolFeesReply {
    return {
        asset0ProtocolFee: 0,
        asset1ProtocolFee: 0,
    };
}

/// Return serialized asset identifiers for this Pool.
get fun get_assets(): DedustPoolV2GetAssetsReply {
    return {
        asset0: createEmptyCell().beginParse(),
        asset1: createEmptyCell().beginParse(),
    };
}

/// Estimate output amount and fee for a serialized input asset and amount.
get fun estimate_swap_out(assetIn: slice, amountIn: int): DedustPoolV2EstimateSwapOutReply {
    return {
        assetOut: createEmptyCell().beginParse(),
        amountOut: 0,
        tradeFee: 0,
    };
}

/// Estimate accepted deposit amounts and fair LP supply for proposed asset amounts.
get fun estimate_deposit_out(amount0: int, amount1: int): DedustPoolV2EstimateDepositOutReply {
    return {
        asset0Deposit: 0,
        asset1Deposit: 0,
        fairSupply: 0,
    };
}

/// Return LP Jetton minter data for the Pool.
get fun get_jetton_data(): DedustPoolV2JettonDataReply {
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000") as any_address,
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic LP wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
