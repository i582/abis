/// Curated ABI for the DeDust Jetton Vault v1 implementation.
contract DedustVaultJettonV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust Jetton Vault v1 ABI for Jetton transfer notifications, swap/deposit forward payloads, payout callbacks, wallet discovery, upgrade handling, storage, and getters."
    storage: DedustVaultJettonV1Storage
    incomingMessages: DedustVaultJettonV1IncomingMessage
    outgoingMessages: DedustVaultJettonV1OutgoingMessage
    forceAbiExport: DedustVaultJettonV1ForwardPayload | DedustVaultJettonV1ProvideWalletAddress | DedustVaultJettonV1BouncedProvideWalletAddress
    thrownErrors: DedustVaultJettonV1Errors
}

/// Runtime storage loaded by the v1 Jetton Vault root data cell.
struct DedustVaultJettonV1Storage {
    /// Cached proof data ref containing Factory address, contract type, and the vaulted asset.
    cachedProof: Cell<DedustVaultJettonV1ProofData>
    /// Blank code cell used with `cachedProof` for deterministic StateInit derivation.
    blankCode: cell
    /// Readiness bit returned by `is_ready`; false before the Jetton wallet address is synced.
    isReady: bool
    /// Jetton minter address for the vaulted asset.
    jettonMinterAddr: address
    /// Vault-owned Jetton wallet address, or `addr_none` before readiness sync completes.
    jettonWalletAddr: address?
    /// Vault code/storage version returned by `get_version`.
    version: uint16
}

/// DeDust proof data stored by the vault and used for child-address authentication.
struct DedustVaultJettonV1ProofData {
    /// Factory address that deterministically owns this vault.
    factoryAddr: address
    /// DeDust contract type tag; v1 Vault proofs use `1`.
    contractType: uint8
    /// Asset parameter committed to the vault proof.
    asset: DedustVaultJettonV1Asset
}

/// Native TON asset tag used by common DeDust pool parameters.
struct (0b0000) DedustVaultJettonV1NativeAsset {}

/// Jetton asset tag used by this Jetton Vault family.
struct (0b0001) DedustVaultJettonV1JettonAsset {
    /// Jetton master workchain id encoded as signed 8-bit integer.
    workchainId: int8
    /// Jetton master address hash encoded without the standard address tag.
    address: bits256
}

/// Asset variants accepted by v1 DeDust vault and pool payloads.
type DedustVaultJettonV1Asset =
    | DedustVaultJettonV1NativeAsset
    | DedustVaultJettonV1JettonAsset

/// Volatile pool type tag used in PoolParams.
struct (0b0) DedustVaultJettonV1VolatilePool {}

/// Stable pool type tag used in PoolParams.
struct (0b1) DedustVaultJettonV1StablePool {}

/// Pool type variants encoded as one bit in DeDust pool parameters.
type DedustVaultJettonV1PoolType =
    | DedustVaultJettonV1VolatilePool
    | DedustVaultJettonV1StablePool

/// Pool identity tuple used by Jetton forward payloads and Factory routing.
struct DedustVaultJettonV1PoolParams {
    /// Pool curve type, volatile or stable.
    poolType: DedustVaultJettonV1PoolType
    /// First sorted pool asset.
    asset0: DedustVaultJettonV1Asset
    /// Second sorted pool asset.
    asset1: DedustVaultJettonV1Asset
}

/// Swap kind tag for exact-in swaps.
struct (0b0) DedustVaultJettonV1GivenIn {}

/// Swap kind tag reserved for exact-out swaps.
struct (0b1) DedustVaultJettonV1GivenOut {}

/// One-bit swap direction encoded inside a swap step.
type DedustVaultJettonV1SwapKind =
    | DedustVaultJettonV1GivenIn
    | DedustVaultJettonV1GivenOut

/// Per-step swap parameters embedded after the Pool address.
struct DedustVaultJettonV1SwapStepParams {
    /// Swap kind selector.
    kind: DedustVaultJettonV1SwapKind
    /// Minimum output for exact-in swaps, or limit value for the step.
    limit: coins
    /// Optional next step for multi-hop swaps.
    next: Cell<DedustVaultJettonV1SwapStep>?
}

/// Swap step routed by the Jetton Vault to a Pool.
struct DedustVaultJettonV1SwapStep {
    /// Pool responsible for this swap step.
    poolAddr: address
    /// Step kind, limit, and optional next-hop reference.
    params: DedustVaultJettonV1SwapStepParams
}

/// Whole-swap options stored in a required referenced cell.
struct DedustVaultJettonV1SwapParams {
    /// Unix timestamp deadline, or zero when disabled.
    deadline: uint32
    /// Optional final recipient; `addr_none` means the default sender/owner path.
    recipientAddr: address?
    /// Optional referral address.
    referralAddr: address?
    /// Optional payload sent on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload sent on rejection.
    rejectPayload: cell?
}

/// Jetton transfer notification accepted from the vault-owned Jetton wallet.
struct (0x7362d09c) DedustVaultJettonV1TransferNotification {
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
struct (0xe3a0d482) DedustVaultJettonV1SwapForwardPayload {
    /// First swap step, stored inline after the opcode.
    step: DedustVaultJettonV1SwapStep
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustVaultJettonV1SwapParams>
}

/// User Jetton forward payload for depositing the transferred Jetton amount as liquidity.
struct (0x40e108d6) DedustVaultJettonV1DepositLiquidityForwardPayload {
    /// Pool parameters used to derive or create the Liquidity Deposit contract.
    poolParams: DedustVaultJettonV1PoolParams
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
type DedustVaultJettonV1ForwardPayload =
    | DedustVaultJettonV1SwapForwardPayload
    | DedustVaultJettonV1DepositLiquidityForwardPayload

/// Pool-authorized payout callback accepted by the Jetton Vault.
struct (0xad4eb6f5) DedustVaultJettonV1PayOutFromPool {
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
struct (0x6b0b787f) DedustVaultJettonV1PayOutFromDeposit {
    /// Query id copied into the outgoing Jetton transfer.
    queryId: uint64
    /// Raw Liquidity Deposit proof reference checked before payout.
    proof: cell
    /// Jetton amount released by the vault.
    amount: coins
    /// Optional forward payload attached to the outgoing Jetton transfer.
    payload: cell?
}

/// Factory-authorized request to install a newer child code cell.
struct (0x000001bc) DedustVaultJettonV1UpgradeChildCode {
    /// Query id copied from the factory upgrade request.
    queryId: uint64
    /// Monotonic replacement code version.
    codeVersion: uint16
    /// Replacement contract code cell.
    code: cell
}

/// Jetton wallet-discovery response accepted from the Jetton minter.
struct (0xd1735400) DedustVaultJettonV1TakeWalletAddress {
    /// Query id copied from `provide_wallet_address`.
    queryId: uint64
    /// Vault-owned Jetton wallet address to persist.
    walletAddress: address
    /// Whether a referenced owner address is present.
    includeAddress: bool
    /// Optional owner-address ref; the v1 code parses and ignores it when present.
    ownerAddress: Cell<address>?
}

/// Factory-authorized request to destroy a non-ready Jetton Vault.
struct (0x9d65482b) DedustVaultJettonV1DestroyNonReady {
    /// Body tail ignored by the v1 handler.
    tail: RemainingBitsAndRefs
}

/// Vault-to-Pool swap routing message constructed after a Jetton transfer notification.
struct (0x61ee542d) DedustVaultJettonV1SwapExternal {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Jetton amount routed into the Pool.
    amount: coins
    /// Original user sender address from the Jetton transfer notification.
    senderAddr: address
    /// Current step parameters forwarded to the Pool.
    current: DedustVaultJettonV1SwapStepParams
    /// Required referenced whole-swap parameter cell.
    swapParams: Cell<DedustVaultJettonV1SwapParams>
}

/// Vault-to-Factory request constructed after a Jetton liquidity deposit payload.
struct (0xf04ec526) DedustVaultJettonV1CreateLiquidityDeposit {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Raw Vault proof reference proving the sender vault.
    proof: cell
    /// Original user sender address from the Jetton transfer notification.
    ownerAddr: address
    /// Pool parameters used by the Factory to address the Liquidity Deposit contract.
    poolParams: DedustVaultJettonV1PoolParams
    /// Referenced deposit amount and target-balance cell.
    depositParams: Cell<DedustVaultJettonV1CreateLiquidityDepositParams>
    /// Optional payload forwarded on successful fulfillment.
    fulfillPayload: cell?
    /// Optional payload forwarded on rejection.
    rejectPayload: cell?
}

/// Referenced amount cell inside `create_liquidity_deposit`.
struct DedustVaultJettonV1CreateLiquidityDepositParams {
    /// Target balance for pool asset0.
    asset0TargetBalance: coins
    /// Target balance for pool asset1.
    asset1TargetBalance: coins
    /// Deposit asset; Jetton Vault sends its stored Jetton asset tag.
    depositAsset: DedustVaultJettonV1Asset
    /// Jetton amount deposited through this vault.
    depositAmount: coins
    /// Minimum acceptable LP amount.
    minLpAmount: coins
}

/// Jetton transfer request body sent by the vault to its owned Jetton wallet.
struct (0x0f8a7ea5) DedustVaultJettonV1JettonTransfer {
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

/// Jetton master wallet-discovery request emitted while syncing the vault wallet.
struct (0x2c76b973) DedustVaultJettonV1ProvideWalletAddress {
    /// Query id copied into `take_wallet_address`.
    queryId: uint64
    /// Owner address whose Jetton wallet is requested; v1 uses the vault address.
    ownerAddress: address
    /// Whether the response must include the owner address by reference.
    includeAddress: bool
}

/// Bounced body prefix accepted before checking bounced `provide_wallet_address`.
struct (0xffffffff) DedustVaultJettonV1BouncedProvideWalletAddress {
    /// Original bounced opcode; v1 only reacts to `provide_wallet_address`.
    originalOpcode: uint32
    /// Remaining bounced body bits/refs are ignored.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the v1 Jetton Vault dispatcher.
type DedustVaultJettonV1IncomingMessage =
    | DedustVaultJettonV1TransferNotification
    | DedustVaultJettonV1PayOutFromPool
    | DedustVaultJettonV1PayOutFromDeposit
    | DedustVaultJettonV1UpgradeChildCode
    | DedustVaultJettonV1TakeWalletAddress
    | DedustVaultJettonV1DestroyNonReady

/// Internal message bodies constructed by the v1 Jetton Vault code.
type DedustVaultJettonV1OutgoingMessage =
    | DedustVaultJettonV1SwapExternal
    | DedustVaultJettonV1CreateLiquidityDeposit
    | DedustVaultJettonV1JettonTransfer
    | DedustVaultJettonV1ProvideWalletAddress

/// DeDust Jetton Vault v1 exit-code catalog.
enum DedustVaultJettonV1Errors {
    /// Wallet-discovery response sender is not the stored Jetton minter.
    InvalidJettonMinterSender = 257
    /// Factory message sender is not the stored Factory.
    InvalidFactorySender = 259
    /// Asset tag, forward payload, or proof shape is invalid for this Vault.
    InvalidAssetOrPayload = 261
    /// Pool payout sender is not the authenticated Pool.
    InvalidPoolSender = 265
    /// Liquidity-deposit payout sender is not the authenticated Liquidity Deposit.
    InvalidLiquidityDepositSender = 272
    /// Vault is not ready for code upgrade.
    VaultNotReady = 273
    /// Vault readiness state does not match the requested operation.
    InvalidReadinessState = 274
    /// Incoming internal opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Return the DeDust vault version stored as a 16-bit field.
get fun get_version(): uint16 {
    throw 0;
}

/// Return whether the Jetton wallet address has been synced and stored.
get fun is_ready(): bool {
    throw 0;
}

/// Return the authenticated Factory address stored in Jetton Vault state.
get fun get_factory_addr(): address {
    throw 0;
}

/// Return the vault-owned Jetton wallet address, or `addr_none` before readiness sync.
get fun get_wallet_addr(): address? {
    throw 0;
}

/// Return the vaulted asset slice.
get fun get_asset(): slice {
    throw 0;
}
