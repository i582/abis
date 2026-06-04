/// DeDust Protocol v2 Jetton Vault interface for Jetton-backed asset routing.
contract DedustVaultJettonV2 {
    author: "DeDust"
    version: "2.0"
    description: "Curated DeDust v2 Jetton Vault ABI for Jetton transfer notifications, swap/deposit forward payloads, common vault callbacks, storage, and live-proven getters."
    storage: DedustVaultJettonV2Storage
    incomingMessages: DedustVaultJettonV2IncomingMessage
    outgoingMessages: DedustVaultJettonV2OutgoingMessage
    forceAbiExport: DedustVaultJettonV2ForwardPayload | DedustVaultJettonV2ProvideWalletAddress
}

/// Runtime storage loaded by the verified Jetton Vault code root data cell.
struct DedustVaultJettonV2Storage {
    /// Cached proof data ref containing Factory address, DeDust contract type, and the vaulted asset.
    cachedProof: Cell<DedustVaultJettonV2ProofData>
    /// Blank code cell used with `cachedProof` to reconstruct the deterministic StateInit hash.
    blankCode: cell
    /// Readiness bit returned by `is_ready`; false before the Jetton wallet address is synced.
    isReady: bool
    /// Jetton minter address for the vaulted asset, also duplicated in `cachedProof.asset`.
    jettonMinterAddr: address
    /// Vault-owned Jetton wallet address; stored as `addr_none` until readiness sync completes.
    jettonWalletAddr: address?
    /// Code/interface version returned by `get_version`.
    version: uint16
}

/// DeDust proof data stored by the vault and used in pool/factory authentication.
struct DedustVaultJettonV2ProofData {
    /// Factory address that deterministically owns this vault family.
    factoryAddr: address
    /// DeDust contract type tag; live Jetton Vault storage stores `1` for vault.
    contractType: uint8
    /// Asset parameter for this vault, proven live as the USDT Jetton asset.
    asset: DedustAsset
}

/// Native asset tag used by common DeDust PoolParams, but not by this Jetton Vault storage instance.
struct (0b0000) DedustNativeAsset {}

/// Jetton asset tag supported by DeDust SDK, docs, and the live USDT vault storage.
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

/// Pool identity tuple used by Jetton forward payloads and Factory routing.
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

/// Swap step routed by the Jetton Vault to a Pool.
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

/// Jetton transfer notification accepted from the vault-owned Jetton wallet.
struct (0x7362d09c) DedustVaultJettonV2TransferNotification {
    /// Query id copied from the Jetton internal transfer.
    queryId: uint64
    /// Received Jetton amount in base units.
    amount: coins
    /// Original Jetton sender owner address.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` tail containing a DeDust forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// User Jetton forward payload for swapping the transferred Jetton amount.
struct (0xe3a0d482) DedustVaultJettonV2SwapForwardPayload {
    /// First swap step, stored inline after the opcode.
    step: DedustSwapStep
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustSwapParams>
}

/// User Jetton forward payload for depositing the transferred Jetton amount as liquidity.
struct (0x40e108d6) DedustVaultJettonV2DepositLiquidityForwardPayload {
    /// Pool parameters used to derive or create the Liquidity Deposit contract.
    poolParams: DedustPoolParams
    /// Minimum acceptable LP amount.
    minLpAmount: coins
    /// Required target balance for pool asset0 after deposit accounting.
    asset0TargetBalance: coins
    /// Required target balance for pool asset1 after deposit accounting.
    asset1TargetBalance: coins
    /// Optional payload forwarded on successful deposit fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on deposit rejection.
    rejectPayload: cell?
}

/// DeDust forward payloads embedded in Jetton transfer notifications.
type DedustVaultJettonV2ForwardPayload =
    | DedustVaultJettonV2SwapForwardPayload
    | DedustVaultJettonV2DepositLiquidityForwardPayload

/// Pool-authorized payout callback accepted by the Jetton Vault.
struct (0xad4eb6f5) DedustVaultJettonV2PayOutFromPool {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Raw Pool proof reference checked before payout.
    proof: cell
    /// Jetton amount released by the vault.
    amount: coins
    /// Final recipient address for the outgoing Jetton transfer.
    recipientAddr: address?
    /// Optional forward payload attached to the outgoing Jetton transfer.
    payload: cell?
}

/// Liquidity Deposit-authorized payout callback accepted by the Jetton Vault.
struct (0x6b0b787f) DedustVaultJettonV2PayOutFromDeposit {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Raw Liquidity Deposit proof reference checked before payout.
    proof: cell
    /// Jetton amount released by the vault.
    amount: coins
    /// Optional forward payload attached to the outgoing Jetton transfer.
    payload: cell?
}

/// State-probe request accepted by the Jetton Vault and answered with `take_vault_state`.
struct (0xe93405b9) DedustVaultJettonV2ProvideVaultState {
    /// Query id copied into the state response.
    queryId: uint64
}

/// Common reset-gas request accepted when sent by the authenticated Jetton wallet address.
struct (0x26c63ab7) DedustVaultJettonV2ResetGas {
    /// Query id carried by the maintenance request.
    queryId: uint64
    /// Destination receiving remaining gas after reserve.
    responseDestination: address
}

/// Factory-authorized request to destroy a non-ready Jetton Vault.
struct (0x9d65482b) DedustVaultJettonV2DestroyNonReady {
    /// Query id carried by the destroy request.
    queryId: uint64
}

/// Vault-to-Pool swap routing message constructed after a Jetton transfer notification.
struct (0x61ee542d) DedustVaultJettonV2SwapExternal {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Jetton amount routed into the Pool.
    amount: coins
    /// Original user sender address from the Jetton transfer notification.
    senderAddr: address
    /// Current step parameters forwarded to the Pool.
    current: DedustSwapStepParams
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustSwapParams>
}

/// Vault-to-Factory request constructed after a Jetton liquidity deposit payload.
struct (0xf04ec526) DedustVaultJettonV2CreateLiquidityDeposit {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Original user sender address from the Jetton transfer notification.
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
    /// Deposit asset; Jetton Vault sends its stored Jetton asset tag.
    depositAsset: DedustAsset
    /// Jetton amount deposited through this vault.
    depositAmount: coins
    /// Minimum acceptable LP amount.
    minLpAmount: coins
}

/// Jetton transfer request body sent by the vault to its owned Jetton wallet for payouts and refunds.
struct (0x0f8a7ea5) DedustVaultJettonV2JettonTransfer {
    /// Query id copied from the callback or Jetton notification.
    queryId: uint64
    /// Jetton amount transferred by the vault-owned wallet.
    amount: coins
    /// Recipient of the Jetton transfer.
    destination: address?
    /// Address receiving Jetton excesses; payout paths mirror `destination`.
    responseDestination: address?
    /// Optional custom payload; payout paths store `null`.
    customPayload: cell?
    /// Forward TON amount attached to the recipient notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// State response emitted by the vault to callers of `provide_vault_state`.
struct (0xa913dc0d) DedustVaultJettonV2TakeVaultState {
    /// Query id copied from the state request.
    queryId: uint64
    /// Readiness flag copied from vault storage.
    isReady: bool
}

/// Jetton master wallet-discovery request emitted while syncing the vault wallet.
struct (0x2c76b973) DedustVaultJettonV2ProvideWalletAddress {
    /// Query id copied into `take_wallet_address`; live code sends zero.
    queryId: uint64
    /// Owner address whose Jetton wallet is requested; live code uses the vault address.
    ownerAddress: address
    /// Whether the response must include the owner address by reference.
    includeAddress: bool
}

/// Jetton wallet-discovery response accepted from the Jetton minter during readiness sync.
struct (0xd1735400) DedustVaultJettonV2TakeWalletAddress {
    /// Query id copied from `provide_wallet_address`.
    queryId: uint64
    /// Vault-owned Jetton wallet address to persist.
    walletAddress: address
    /// Whether a referenced owner address is present.
    includeAddress: bool
    /// Optional owner-address ref; live code parses and ignores it when present.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the verified Jetton Vault code.
type DedustVaultJettonV2IncomingMessage =
    | DedustVaultJettonV2TransferNotification
    | DedustVaultJettonV2PayOutFromPool
    | DedustVaultJettonV2PayOutFromDeposit
    | DedustVaultJettonV2ProvideVaultState
    | DedustVaultJettonV2ResetGas
    | DedustVaultJettonV2DestroyNonReady
    | DedustVaultJettonV2TakeWalletAddress

/// Internal message bodies constructed by the verified Jetton Vault code.
type DedustVaultJettonV2OutgoingMessage =
    | DedustVaultJettonV2SwapExternal
    | DedustVaultJettonV2CreateLiquidityDeposit
    | DedustVaultJettonV2JettonTransfer
    | DedustVaultJettonV2TakeVaultState
    | DedustVaultJettonV2ProvideWalletAddress

/// Return the DeDust vault version stored as a 16-bit field.
get fun get_version(): uint16 {
    return 0;
}

/// Return whether the Jetton wallet address has been synced and stored.
get fun is_ready(): bool {
    return false;
}

/// Return the authenticated Factory address stored in Jetton Vault state.
get fun get_factory_addr(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the vault-owned Jetton wallet address, or `addr_none` before readiness sync.
get fun get_wallet_addr(): address? {
    return null;
}

/// Return the Jetton asset slice; live USDT vault returns tag, workchain id, and minter hash.
get fun get_asset(): slice {
    return createEmptyCell().beginParse();
}
