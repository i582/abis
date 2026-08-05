/// Ethena tsUSDe vault that accepts USDe deposits, mints tsUSDe shares, and vests rewards.
contract TsusdeVault {
    author: "Ethena / LayerZero Labs"
    description: "tsUSDe Vault accounts for deposited assets and shares, applies reward vesting, and coordinates the tsUSDe Jetton contracts."
    storage: TsusdeVaultStorage
    incomingMessages: TsusdeVaultIncomingMessage
    outgoingMessages: TsusdeVaultOutgoingMessage
    forceAbiExport: TsusdeVaultEmptyBody
    thrownErrors: TsusdeVaultErrors
}

/// LayerZero classlib base-storage object referenced by the vault root cell.
struct TsusdeVaultBaseStorage {
    /// Raw 350-bit classlib descriptor for the `baseStore` class and its four fields.
    classlibHeader: bits350
    /// Basechain address hash of the administrator that owns the vault.
    ownerHash: uint256
    /// Whether the one-time owner authentication step has completed.
    authenticated: bool
    /// Whether the vault-specific initialization payload has been applied.
    initialized: bool
    /// Initial classlib storage snapshot; initialized deployments normally retain an empty object.
    initialStorage: cell
}

/// First overflow cell used by the 12-field LayerZero classlib vault object.
struct TsusdeVaultStorageBalances {
    /// Basechain address hash of the account authorized to distribute rewards.
    rewarderHash: uint256
    /// Gross USDe asset balance before subtracting the currently unvested reward amount.
    assetBalance: uint256
    /// Total outstanding tsUSDe shares.
    totalShares: uint256
}

/// Second overflow cell used by the 12-field LayerZero classlib vault object.
struct TsusdeVaultStorageVesting {
    /// Basechain address hash of the pending owner, or zero when no transfer is pending.
    tentativeOwnerHash: uint256
    /// Cooldown applied to the first redemption step, in seconds.
    cooldownDuration: uint64
    /// Unix timestamp at which the latest reward distribution began vesting.
    lastDistributionTimestamp: uint64
    /// Fixed-width reward amount subject to the current vesting schedule.
    vestingAmount: uint128
    /// Duration of the current reward vesting schedule, in seconds.
    vestingDuration: uint64
}

/// Exact three-cell LayerZero classlib storage layout used by the live vault.
struct TsusdeVaultStorage {
    /// Raw 350-bit classlib descriptor for the `Vault` class and its 12 fields.
    classlibHeader: bits350
    /// Basechain address hash of the vault-owned USDe Jetton wallet.
    assetWalletHash: uint256
    /// Basechain address hash of the tsUSDe Jetton minter.
    shareMinterHash: uint256
    /// Fixed-width GRAM amount attached to share-mint calls.
    mintNanos: uint128
    /// Referenced ownership and initialization state stored at root ref 0.
    baseStorage: Cell<TsusdeVaultBaseStorage>
    /// Empty structural ref reserved by classlib when an object spans three data cells.
    classlibPadding: cell
    /// Referenced rewarder and aggregate-balance fields stored in overflow cell 1.
    balances: Cell<TsusdeVaultStorageBalances>
    /// Referenced ownership-transfer and vesting fields stored in overflow cell 2.
    vesting: Cell<TsusdeVaultStorageVesting>
}

/// Exact classlib object carrying a basechain address hash.
struct TsusdeVaultAddressPayload {
    /// Raw 350-bit classlib descriptor for the single-field `Address` class.
    classlibHeader: bits350
    /// Basechain address hash carried by the management request.
    addressHash: uint256
}

/// Exact classlib object carrying a fixed-width nanograms amount.
struct TsusdeVaultCoinsPayload {
    /// Raw 350-bit classlib descriptor for the single-field `coins` class.
    classlibHeader: bits350
    /// Amount encoded as classlib's fixed-width unsigned 128-bit `coins` type.
    amount: uint128
}

/// Exact classlib object carrying a cooldown duration.
struct TsusdeVaultCooldownPayload {
    /// Raw 350-bit classlib descriptor for the single-field `CoolDown` class.
    classlibHeader: bits350
    /// New redemption cooldown duration, in seconds.
    cooldownDuration: uint64
}

/// Exact classlib object carrying a vesting duration.
struct TsusdeVaultVestingPayload {
    /// Raw 350-bit classlib descriptor for the single-field `Vesting` class.
    classlibHeader: bits350
    /// New reward vesting duration, in seconds.
    vestingDuration: uint64
}

/// Two-reference classlib object used by initialization and code upgrades.
struct TsusdeVaultMdObject {
    /// Raw 350-bit classlib descriptor for the two-field `MdObj` class.
    classlibHeader: bits350
    /// First referenced metadata object.
    metadata: cell
    /// Second referenced object or storage cell.
    object: cell
}

/// Classlib initialization payload whose refs carry the three role addresses and mint amount.
struct TsusdeVaultInitializationPayload {
    /// Raw 350-bit classlib descriptor for the two-field `MdObj` class.
    classlibHeader: bits350
    /// Compact address-list cell containing asset wallet, share minter, and rewarder hashes in order.
    addressList: cell
    /// Referenced classlib amount used as the initial share-mint GRAM attachment.
    mintNanos: Cell<TsusdeVaultCoinsPayload>
}

/// Untagged body used by the LayerZero refund send site and accepted as a funding-only input.
struct TsusdeVaultEmptyBody {}

/// Owner-originated one-time initialization request for the deployment storage values.
struct (0xf65ce988) TsusdeVaultInitialize {
    /// Correlation id propagated by LayerZero message helpers.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing initialization.
    donationNanos: coins
    /// Owner origin used by the LayerZero authorization context.
    origin: address
    /// Referenced classlib payload containing addresses and the mint GRAM amount.
    payload: Cell<TsusdeVaultInitializationPayload>
}

/// TEP-74 transfer notification accepted from the configured asset wallet or share minter.
struct (0x7362d09c) TsusdeVaultTransferNotification {
    /// Query id copied from the originating Jetton transfer.
    queryId: uint64
    /// Jetton amount interpreted by the vault as the incoming donation amount.
    amount: coins
    /// Logical sender embedded by the notifying Jetton wallet.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` payload tail; asset deposits may use an inline empty payload,
    /// while redemption notifications use a ref whose first bit selects the redemption step.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-only request to replace the GRAM amount attached to share-mint calls.
struct (0xb58f5cc0) TsusdeVaultSetMintNanos {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced fixed-width classlib amount.
    payload: Cell<TsusdeVaultCoinsPayload>
}

/// Owner-only request to replace the account authorized to distribute rewards.
struct (0x95fd1707) TsusdeVaultSetRewarderAddress {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib address-hash object.
    payload: Cell<TsusdeVaultAddressPayload>
}

/// Pending-owner request to accept ownership of the vault.
struct (0xa67308c8) TsusdeVaultClaimOwnership {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash must match the pending owner.
    origin: address
    /// Referenced payload ignored by the implementation.
    payload: cell
}

/// Owner-only request to nominate a replacement vault owner.
struct (0xb721bed0) TsusdeVaultTransferOwnership {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib address-hash object for the pending owner.
    payload: Cell<TsusdeVaultAddressPayload>
}

/// Owner-only request to replace both the executable code and classlib storage.
struct (0x9d511912) TsusdeVaultUpgradeCode {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced `MdObj` whose refs are the replacement code and replacement storage.
    payload: Cell<TsusdeVaultMdObject>
}

/// Owner-only request to replace the vault-owned USDe Jetton wallet.
struct (0xc1b1b3d6) TsusdeVaultSetAssetWalletAddress {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib address-hash object for the replacement wallet.
    payload: Cell<TsusdeVaultAddressPayload>
}

/// Owner-only request to replace the tsUSDe Jetton minter.
struct (0x2f6a98c0) TsusdeVaultSetShareMinterAddress {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib address-hash object for the replacement minter.
    payload: Cell<TsusdeVaultAddressPayload>
}

/// Owner-only request to replace the redemption cooldown duration.
struct (0x1630aa78) TsusdeVaultSetCooldownDuration {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib cooldown object.
    payload: Cell<TsusdeVaultCooldownPayload>
}

/// Owner-only request to replace the reward vesting duration.
struct (0x54615baf) TsusdeVaultSetVestingDuration {
    /// Correlation id propagated by LayerZero helpers and event messages.
    queryId: uint64
    /// GRAM deliberately retained by the vault while processing the request.
    donationNanos: coins
    /// Logical origin whose basechain hash is used for refunds and authorization context.
    origin: address
    /// Referenced classlib vesting object.
    payload: Cell<TsusdeVaultVestingPayload>
}

/// Extended Jetton internal-transfer body nested in a share-mint request.
struct (0x178d4519) TsusdeVaultInternalTransfer {
    /// Query id copied from the triggering vault request.
    queryId: uint64
    /// Share or asset-denominated amount credited by the receiving wallet.
    amount: coins
    /// Unix timestamp after which timelocked tokens may be redeemed, or zero for ordinary shares.
    timelockLimit: uint64
    /// Logical sender address; vault-generated mint payloads encode `addr_none`.
    from: address?
    /// Optional address that receives excess GRAM after processing.
    responseAddress: address?
    /// GRAM forwarded with a transfer notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Share-mint instruction emitted to the configured tsUSDe Jetton minter.
struct (0x642b7d07) TsusdeVaultMintShares {
    /// Query id copied from the triggering vault request.
    queryId: uint64
    /// Owner address whose deterministic wallet receives the minted amount.
    destination: address
    /// GRAM amount attached to the minter call.
    forwardTonAmount: coins
    /// Referenced extended internal-transfer body processed by the minter.
    internalTransfer: Cell<TsusdeVaultInternalTransfer>
}

/// Standard Jetton transfer emitted through the vault-owned USDe wallet during redemption or refund.
struct (0x0f8a7ea5) TsusdeVaultJettonTransfer {
    /// Query id copied from the triggering vault request.
    queryId: uint64
    /// USDe amount transferred in base units.
    amount: coins
    /// Recipient owner address.
    destination: address
    /// Address that receives excess GRAM after processing.
    responseDestination: address
    /// Optional custom payload; vault-generated messages leave it absent.
    customPayload: cell?
    /// GRAM forwarded with a transfer notification; vault-generated messages use zero.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Classlib event action referenced by the LayerZero event envelope.
struct TsusdeVaultEvent {
    /// Raw 350-bit classlib descriptor for the three-field `event` class.
    classlibHeader: bits350
    /// Unsigned 256-bit event topic derived from the source event name.
    topic: uint256
    /// Event-specific classlib payload.
    payload: cell
    /// Initial-storage snapshot; the vault emits an empty classlib object.
    initialStorage: cell
}

/// LayerZero event message emitted back to the vault address as a deliberately reverting transaction.
struct (0xe33b9873) TsusdeVaultEventMessage {
    /// Query id copied from the triggering request.
    queryId: uint64
    /// GRAM retained by the event sink; emitted events use zero.
    donationNanos: coins
    /// Logical deposit or management origin propagated from the triggering request.
    origin: address
    /// Referenced classlib event action.
    event: Cell<TsusdeVaultEvent>
}

/// Tagged internal message bodies accepted during deployment or by the initialized tsUSDe vault.
type TsusdeVaultIncomingMessage =
    | TsusdeVaultInitialize
    | TsusdeVaultTransferNotification
    | TsusdeVaultSetMintNanos
    | TsusdeVaultSetRewarderAddress
    | TsusdeVaultClaimOwnership
    | TsusdeVaultTransferOwnership
    | TsusdeVaultUpgradeCode
    | TsusdeVaultSetAssetWalletAddress
    | TsusdeVaultSetShareMinterAddress
    | TsusdeVaultSetCooldownDuration
    | TsusdeVaultSetVestingDuration
    | TsusdeVaultEventMessage

/// Tagged internal message bodies emitted by the tsUSDe vault.
///
/// Untagged value refunds are exported separately as `TsusdeVaultEmptyBody`.
type TsusdeVaultOutgoingMessage =
    | TsusdeVaultMintShares
    | TsusdeVaultJettonTransfer
    | TsusdeVaultEventMessage

/// Exit-code catalog derived from the exact verified vault and LayerZero framework sources.
enum TsusdeVaultErrors {
    /// Reserved-balance calculation found that the requested outflow exceeds available GRAM.
    InsufficientTonForActions = 37
    /// Incoming amount failed a vault-specific validation.
    InvalidAmount = 317
    /// Transfer notification sender is not the configured asset wallet or share minter.
    OnlyShareMinterOrAssetWallet = 384
    /// Caller is not the current owner.
    OnlyOwner = 492
    /// Caller is not the nominated pending owner.
    OnlyTentativeOwner = 550
    /// Replacement cooldown exceeds the 90-day maximum.
    InvalidCooldownDuration = 243
    /// Replacement vesting duration exceeds the 90-day maximum.
    InvalidVestingDuration = 1733
    /// Existing rewards have not completed vesting.
    VestingNotCompleted = 1753
    /// Transfer notification caller is inconsistent with the configured vault wallets.
    InvalidCaller = 1325
    /// Vault has not completed owner authentication.
    NotAuthenticated = 1690
    /// Vault-specific initialization has not completed.
    NotInitialized = 1273
    /// LayerZero base handler received an unauthenticated request.
    BaseNotAuthenticated = 257
    /// LayerZero base handler rejected a non-owner request.
    BaseOnlyOwner = 258
    /// LayerZero base handler was invoked before initialization.
    BaseNotInitialized = 259
    /// LayerZero initialization was requested more than once.
    BaseAlreadyInitialized = 260
    /// Incoming opcode is not implemented or lacks an explicit permission branch.
    BaseInvalidOpcode = 261
    /// Event sink intentionally rejects the self-directed event transaction.
    BaseEventEmitted = 262
    /// Dispatcher encountered an unsupported action tuple type.
    BaseInvalidActionType = 263
    /// Event source failed LayerZero event-sink validation.
    BaseInvalidEventSource = 264
}

/// Return the fixed GRAM amount attached to share-mint calls.
get fun getMintNanos(): int {
    throw 0;
}

/// Return the portion of the latest reward distribution that remains unvested.
get fun getUnvestedAmount(): int {
    throw 0;
}

/// Return gross accounted assets minus the currently unvested reward amount.
get fun getTotalAssets(): int {
    throw 0;
}

/// Return the total outstanding tsUSDe share supply tracked by the vault.
get fun getTotalShares(): int {
    throw 0;
}

/// Convert an asset amount to shares using floor division and the current vault ratio.
get fun convertToShares(amountAssets: int): int {
    throw 0;
}

/// Convert a share amount to assets using floor division and the current vault ratio.
get fun convertToAssets(amountShares: int): int {
    throw 0;
}
