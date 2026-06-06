/// DeDust Protocol v2 Native Vault interface for TON-native asset routing.
contract DedustVaultNativeV2 {
    author: "DeDust"
    version: "2.0"
    description: "Curated DeDust v2 Native Vault ABI for native swaps, liquidity deposit routing, payout callbacks, storage, safe getters, and exit codes."
    storage: DedustVaultNativeV2Storage
    incomingMessages: DedustVaultNativeV2IncomingMessage
    outgoingMessages: DedustVaultNativeV2OutgoingMessage
    forceAbiExport: DedustVaultNativeV2InlineDepositLiquidityCandidate
}

/// Runtime storage loaded by the verified native vault code root data cell.
struct DedustVaultNativeV2Storage {
    /// Cached proof data reference forwarded to Pool and Factory messages.
    cachedProof: Cell<DedustVaultNativeV2ProofData>
    /// Factory address authenticated by proof checks and returned by `get_factory_addr`.
    factoryAddr: address
    /// Blank code cell used with `cachedProof` for deterministic StateInit derivation.
    blankCode: cell
    /// Code/interface version returned by `get_version`.
    version: uint16
    /// Native TON balance tracked by the vault for routed deposits and payouts.
    nativeBalance: coins
}

/// Cached DeDust proof data stored by the Native Vault.
struct DedustVaultNativeV2ProofData {
    /// Factory address committed into the deterministic proof data.
    factoryAddr: address
    /// DeDust contract type tag; live Native Vault storage stores `1` for vault.
    contractType: uint8
    /// Native asset parameter for this vault.
    asset: DedustAsset
}

/// Native asset tag used by DeDust SDK and live `get_asset`.
struct (0b0000) DedustNativeAsset {}

/// Jetton asset tag supported by SDK pool params and factory-derived messages.
struct (0b0001) DedustJettonAsset {
    /// Jetton minter workchain id.
    workchainId: int8
    /// Jetton minter account hash.
    address: bits256
}

/// Asset variants proven by SDK/local TL-B for DeDust v2 core messages.
type DedustAsset =
    | DedustNativeAsset
    | DedustJettonAsset

/// Volatile pool type tag used in PoolParams.
struct (0b0) DedustVolatilePool {}

/// Stable pool type tag used in PoolParams.
struct (0b1) DedustStablePool {}

/// Pool type variants encoded as one bit in DeDust pool parameters.
type DedustPoolType =
    | DedustVolatilePool
    | DedustStablePool

/// Pool identity tuple used by native deposit liquidity and factory routing.
struct DedustPoolParams {
    /// Pool curve type, volatile or stable.
    poolType: DedustPoolType
    /// First sorted pool asset.
    asset0: DedustAsset
    /// Second sorted pool asset.
    asset1: DedustAsset
}

/// Swap kind tag for exact-in swaps; SDK currently stores only this value.
struct (0b0) DedustGivenIn {}

/// Swap kind tag for exact-out swaps; docs say this variant is not implemented.
struct (0b1) DedustGivenOut {}

/// One-bit swap direction encoded inside a swap step.
type DedustSwapKind =
    | DedustGivenIn
    | DedustGivenOut

/// Per-step swap parameters embedded after the Pool address.
struct DedustSwapStepParams {
    /// Swap kind; live SDK writes `given_in` and reserves `given_out`.
    kind: DedustSwapKind
    /// Minimum output for `given_in`, or limit value for the step.
    limit: coins
    /// Optional next step for multi-hop swaps.
    next: Cell<DedustSwapStep>?
}

/// Swap step routed by the Native Vault to a Pool.
struct DedustSwapStep {
    /// Pool responsible for this swap step.
    poolAddr: address
    /// Step kind, limit, and optional next-hop reference.
    params: DedustSwapStepParams
}

/// Whole-swap options stored in a required referenced cell.
struct DedustSwapParams {
    /// Unix timestamp deadline, or zero when disabled.
    deadline: uint32
    /// Optional final recipient; `addr_none` means the default sender/owner path.
    recipientAddr: address?
    /// Optional referral address; `addr_none` disables referral routing.
    referralAddr: address?
    /// Optional payload sent on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload sent on rejection.
    rejectPayload: cell?
}

/// Ref-backed Native Vault liquidity-deposit parameters proven by SDK and live code.
struct DedustDepositLiquidityParams {
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Required target balance for pool asset0 after deposit accounting.
    asset0TargetBalance: coins
    /// Required target balance for pool asset1 after deposit accounting.
    asset1TargetBalance: coins
}

/// Docs/Toncenter inline candidate kept for ABI diff visibility; live code parses the ref-backed variant instead.
struct DedustVaultNativeV2InlineDepositLiquidityCandidate {
    /// Candidate minimum LP amount from the inline documentation variant.
    minLpAmount: coins
    /// Candidate target balance for asset0 from the inline documentation variant.
    asset0TargetBalance: coins
    /// Candidate target balance for asset1 from the inline documentation variant.
    asset1TargetBalance: coins
}

/// User-originated native TON swap accepted by the live Native Vault code.
struct (0xea06185d) DedustVaultNativeV2Swap {
    /// Query id copied into Pool routing messages.
    queryId: uint64
    /// Native TON amount credited into the vault's internal accounting.
    amount: coins
    /// First swap step, stored inline after amount.
    step: DedustSwapStep
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustSwapParams>
}

/// User-originated native TON liquidity deposit using the ref-backed params cell.
struct (0xd55e4686) DedustVaultNativeV2DepositLiquidity {
    /// Query id copied into the Factory liquidity-deposit deployment request.
    queryId: uint64
    /// Native TON amount credited into the vault's internal accounting.
    amount: coins
    /// Pool parameters used to derive or create the Liquidity Deposit contract.
    poolParams: DedustPoolParams
    /// Ref-backed deposit constraints; the inline docs variant is not accepted by live code evidence.
    params: Cell<DedustDepositLiquidityParams>
    /// Optional payload forwarded on successful deposit fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on deposit rejection.
    rejectPayload: cell?
}

/// Pool-authorized payout callback accepted by the Native Vault.
struct (0xad4eb6f5) DedustVaultNativeV2PayOutFromPool {
    /// Query id copied into the final payout body.
    queryId: uint64
    /// Raw Pool proof reference checked before payout.
    proof: cell
    /// Native TON amount released from vault accounting.
    amount: coins
    /// Final recipient address for the outgoing payout.
    recipientAddr: address?
    /// Optional payload attached to the outgoing payout.
    payload: cell?
}

/// Liquidity Deposit-authorized payout callback accepted by the Native Vault.
struct (0x6b0b787f) DedustVaultNativeV2PayOutFromDeposit {
    /// Query id copied into the final payout body.
    queryId: uint64
    /// Raw Liquidity Deposit proof reference checked before payout.
    proof: cell
    /// Native TON amount released from vault accounting.
    amount: coins
    /// Optional payload attached to the outgoing payout.
    payload: cell?
}

/// State-probe request accepted by the Native Vault and answered with `take_vault_state`.
struct (0xe93405b9) DedustVaultNativeV2ProvideVaultState {
    /// Query id copied into the state response.
    queryId: uint64
}

/// Common reset-gas request accepted when sent by the authenticated operator address.
struct (0x26c63ab7) DedustVaultNativeV2ResetGas {
    /// Query id carried by the maintenance request.
    queryId: uint64
    /// Destination receiving remaining gas after reserve.
    responseDestination: address
}

/// Vault-to-Pool swap routing message constructed after a native swap.
struct (0x61ee542d) DedustVaultNativeV2SwapExternal {
    /// Query id copied from the incoming native swap.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Native TON amount routed into the Pool.
    amount: coins
    /// Original user sender address from the inbound internal message envelope.
    senderAddr: address
    /// Current step parameters forwarded to the Pool.
    current: DedustSwapStepParams
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustSwapParams>
}

/// Vault-to-Factory request constructed after a native liquidity deposit.
struct (0xf04ec526) DedustVaultNativeV2CreateLiquidityDeposit {
    /// Query id copied from the incoming native deposit.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Original user sender address from the inbound internal message envelope.
    ownerAddr: address
    /// Pool parameters used by the Factory to address the Liquidity Deposit contract.
    poolParams: DedustPoolParams
    /// Referenced deposit amount and target-balance cell.
    depositParams: Cell<DedustCreateLiquidityDepositParams>
    /// Optional payload forwarded on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on rejection.
    rejectPayload: cell?
}

/// Referenced amount cell inside `create_liquidity_deposit`.
struct DedustCreateLiquidityDepositParams {
    /// Target balance for pool asset0.
    asset0TargetBalance: coins
    /// Target balance for pool asset1.
    asset1TargetBalance: coins
    /// Deposit asset; native vault sends the native asset tag.
    depositAsset: DedustAsset
    /// Native TON amount deposited through this vault.
    depositAmount: coins
    /// Minimum acceptable LP amount.
    minLpAmount: coins
}

/// Final native payout body emitted by the vault to recipients.
struct (0x474f86cf) DedustVaultNativeV2Payout {
    /// Query id copied from the Pool or Liquidity Deposit payout callback.
    queryId: uint64
    /// Optional recipient payload.
    payload: cell?
}

/// State response emitted by the vault to callers of `provide_vault_state`.
struct (0xa913dc0d) DedustVaultNativeV2TakeVaultState {
    /// Query id copied from the state request.
    queryId: uint64
    /// Readiness flag; live Native Vault sends true for the verified account.
    isReady: bool
}

/// Internal message bodies accepted by the verified Native Vault code.
type DedustVaultNativeV2IncomingMessage =
    | DedustVaultNativeV2Swap
    | DedustVaultNativeV2DepositLiquidity
    | DedustVaultNativeV2PayOutFromPool
    | DedustVaultNativeV2PayOutFromDeposit
    | DedustVaultNativeV2ProvideVaultState
    | DedustVaultNativeV2ResetGas

/// Internal message bodies constructed by the verified Native Vault code.
type DedustVaultNativeV2OutgoingMessage =
    | DedustVaultNativeV2SwapExternal
    | DedustVaultNativeV2CreateLiquidityDeposit
    | DedustVaultNativeV2Payout
    | DedustVaultNativeV2TakeVaultState

/// DeDust Native Vault v2 exit-code catalog.
enum DedustVaultNativeV2Errors {
    /// Factory message sender is not the stored Factory.
    InvalidFactorySender = 259
    /// Asset tag, user payload, or proof shape is invalid for this Vault.
    InvalidAssetOrPayload = 261
    /// Attached value cannot cover the required downstream fee budget.
    InsufficientValue = 263
    /// Pool payout sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Liquidity-deposit payout sender is not the authenticated Liquidity Deposit.
    InvalidLiquidityDepositSender = 272
    /// Liquidity-deposit target amounts must be positive.
    InvalidDepositAmounts = 276
    /// Routed swap path exceeds the accepted depth.
    SwapPathTooLong = 278
    /// Liquidity-deposit asset does not match the vault asset side.
    InvalidDepositAsset = 291
    /// Reset-gas sender is not the deterministic Operator contract.
    InvalidOperatorSender = 296
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the DeDust vault version stored as a 16-bit field.
get fun get_version(): uint16 {
    assert (true) throw DedustVaultNativeV2Errors.InvalidFactorySender;
    assert (true) throw DedustVaultNativeV2Errors.InvalidAssetOrPayload;
    assert (true) throw DedustVaultNativeV2Errors.InsufficientValue;
    assert (true) throw DedustVaultNativeV2Errors.InvalidPoolSender;
    assert (true) throw DedustVaultNativeV2Errors.InvalidLiquidityDepositSender;
    assert (true) throw DedustVaultNativeV2Errors.InvalidDepositAmounts;
    assert (true) throw DedustVaultNativeV2Errors.SwapPathTooLong;
    assert (true) throw DedustVaultNativeV2Errors.InvalidDepositAsset;
    assert (true) throw DedustVaultNativeV2Errors.InvalidOperatorSender;
    assert (true) throw DedustVaultNativeV2Errors.UnsupportedOperation;
    return 0;
}

/// Return the authenticated Factory address stored in Native Vault state.
get fun get_factory_addr(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the raw DeDust asset slice; live code returns the four-bit native tag.
get fun get_asset(): slice {
    return createEmptyCell().beginParse();
}
