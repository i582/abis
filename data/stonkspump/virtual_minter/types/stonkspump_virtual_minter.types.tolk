/// StonksPump virtual-liquidity Jetton minter used before migration to a production DEX pool.
contract StonksPumpVirtualMinter {
    author: "Stonks"
    version: "7-8"
    description: "StonksPump Jetton master implements virtual-presale buys and sells, exposes bonding-curve state, and migrates liquidity to STON.fi or DeDust."
    storage: StonksPumpVirtualMinterStorage
    incomingMessages: StonksPumpVirtualMinterIncomingMessage
    outgoingMessages: StonksPumpVirtualMinterOutgoingMessage
    forceAbiExport: StonksPumpAskToPresaleSell
        | StonksPumpPresaleTradeEvent
        | StonksPumpVirtualMinterInit
        | StonksPumpVirtualDevBuy
        | StonksPumpBondingData
    thrownErrors: StonksPumpVirtualMinterErrors
}

/// Complete persistent state shared by the STON.fi and DeDust virtual-minter variants.
struct StonksPumpVirtualMinterStorage {
    /// Issued Jetton supply in base token units.
    totalSupply: coins
    /// Factory/admin address authorized to initialize and mutate the minter.
    adminAddress: address
    /// Referenced TEP-64 Jetton metadata content.
    jettonContent: cell
    /// Referenced code used to derive and deploy user Jetton wallets.
    jettonWalletCode: cell
    /// Optional curve and migration state; absent before factory initialization.
    bondingState: Cell<StonksPumpVirtualMinterBondingState>?
}

/// Initialized bonding-curve state stored behind the optional root reference.
struct StonksPumpVirtualMinterBondingState {
    /// True while buys and sells use the virtual presale curve.
    presaleOpen: bool
    /// GRAM collection target that triggers DEX migration, in nanograms.
    migrationTonTarget: coins
    /// Net GRAM collected through presale buys minus sells, in nanograms.
    tonsCollected: coins
    /// Initial Jetton-side component of the cumulative virtual reserve.
    baseJettonReserve: coins
    /// Additional GRAM-side component included in the cumulative virtual reserve.
    additionalTonReserve: coins
    /// Additional Jetton-side component included in the cumulative virtual reserve.
    additionalJettonReserve: coins
    /// Maximum percentage of total supply accepted by one buy; zero disables the cap.
    maxBuyPercent: uint16
    /// Jettons sold through the virtual presale in base token units.
    tokensSold: coins
    /// First DEX-specific launch configuration reference.
    launchConfig: cell
    /// Factory-supplied migration configuration retained for post-presale actions.
    migrationConfig: cell
}

/// Optional developer purchase appended as the second referenced initialization payload.
struct StonksPumpVirtualDevBuy {
    /// GRAM amount reserved for the developer's initial virtual-presale buy.
    tonAmount: coins
    /// Wallet that receives Jettons bought during initialization.
    recipient: address
    /// Minimum Jetton amount accepted for the developer buy.
    minJettonsOut: coins
}

/// Standard Jetton admin mint request accepted by the virtual minter.
struct (0x00000015) StonksPumpJettonMint {
    /// Factory-selected query id.
    queryId: uint64
    /// Owner address whose deterministic wallet receives the minted Jettons.
    recipient: address
    /// Nanograms attached to wallet deployment and delivery.
    forwardTonAmount: coins
    /// Referenced Jetton internal-transfer body sent to the wallet.
    internalTransfer: cell
}

/// Standard Jetton burn callback accepted from an authenticated user wallet.
struct (0x7bdd97de) StonksPumpJettonBurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned Jetton amount in base token units.
    amount: coins
    /// Owner whose deterministic wallet burned the Jettons.
    owner: address
    /// Optional address that receives excess GRAM.
    responseAddress: address?
}

/// TEP-89 request for the deterministic Jetton wallet of an owner.
struct (0x2c76b973) StonksPumpProvideWalletAddress {
    /// Caller-selected query id copied into the response.
    queryId: uint64
    /// Owner for whom the wallet address is derived.
    ownerAddress: address
    /// Whether the response must include a referenced copy of the owner address.
    includeAddress: bool
}

/// Standard Jetton admin-change request.
struct (0x00000003) StonksPumpChangeAdmin {
    /// Admin-selected query id.
    queryId: uint64
    /// Replacement admin/factory address.
    newAdminAddress: address
}

/// Standard Jetton metadata update request.
struct (0x00000004) StonksPumpChangeContent {
    /// Admin-selected query id.
    queryId: uint64
    /// Referenced replacement TEP-64 metadata content.
    jettonContent: cell
}

/// Factory initialization for virtual liquidity and optional developer purchase.
struct (0xcc1a9802) StonksPumpVirtualMinterInit {
    /// Factory-selected query id.
    queryId: uint64
    /// Initial virtual-presale availability flag.
    presaleOpen: bool
    /// GRAM collection target that triggers DEX migration.
    migrationTonTarget: coins
    /// Initial collected GRAM amount.
    tonsCollected: coins
    /// Initial Jetton-side component of the cumulative virtual reserve.
    baseJettonReserve: coins
    /// Initial additional GRAM-side virtual-reserve component.
    additionalTonReserve: coins
    /// Initial additional Jetton-side virtual-reserve component.
    additionalJettonReserve: coins
    /// Maximum percentage of total supply accepted by one buy.
    maxBuyPercent: uint16
    /// Referenced DEX-specific launch and migration configuration.
    migrationConfig: cell
    /// Referenced optional developer-buy request; zero GRAM means no developer buy.
    devBuy: Cell<StonksPumpVirtualDevBuy>
}

/// Buy Jettons from the virtual presale before DEX migration.
struct (0xcc1a97ae) StonksPumpBuyFromPresale {
    /// Caller-selected correlation id.
    queryId: uint64
    /// GRAM-side swap input before protocol fee and curve clipping.
    tonAmount: coins
    /// Minimum Jetton output accepted by the buyer.
    minJettonsOut: coins
}

/// Wallet-to-minter notification carrying Jettons sold back into the virtual presale.
struct (0xcc1a97b0) StonksPumpPresaleSellNotificationForMinter {
    /// Correlation id copied from the wallet sell request.
    queryId: uint64
    /// Jetton amount sold in base token units.
    jettonAmount: coins
    /// Owner that initiated the sell through a Jetton wallet.
    sellInitiator: address
    /// Optional account receiving the GRAM proceeds.
    tonsRecipient: address?
    /// Minimum GRAM output accepted by the seller.
    minTonOut: coins
}

/// User-to-wallet request that starts a virtual-presale sell.
struct (0xcc1a97af) StonksPumpAskToPresaleSell {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Jetton amount sold in base token units.
    jettonAmount: coins
    /// Optional account receiving the GRAM proceeds.
    tonsRecipient: address?
    /// Minimum GRAM output accepted by the seller.
    minTonOut: coins
}

/// Standard Jetton internal transfer emitted to a deterministic user wallet after a buy or mint.
struct (0x178d4519) StonksPumpJettonInternalTransfer {
    /// Query id copied from the buy or mint request.
    queryId: uint64
    /// Jetton amount credited to the wallet.
    amount: coins
    /// Source owner; may be `addr_none` for newly minted supply.
    fromAddress: address?
    /// Optional excess-value response destination.
    responseAddress: address?
    /// Nanograms forwarded with the wallet notification.
    forwardTonAmount: coins
    /// Raw standard Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excess-value response.
struct (0xd53276db) StonksPumpJettonExcesses {
    /// Query id copied from the triggering operation.
    queryId: uint64
}

/// TEP-89 response containing an owner's deterministic wallet address.
struct (0xd1735400) StonksPumpTakeWalletAddress {
    /// Query id copied from the discovery request.
    queryId: uint64
    /// Derived wallet address, or `addr_none` when the owner cannot be resolved.
    walletAddress: address?
    /// Optional referenced owner address requested by the caller.
    ownerAddress: Cell<address>?
}

/// External-out settlement log emitted after a successful virtual-presale buy or sell.
struct (0xcc1a97b3) StonksPumpPresaleTradeEvent {
    /// Query id copied from the original buy or sell request.
    queryId: uint64
    /// True for a buy and false for a sell.
    isBuy: bool
    /// GRAM input for buys or Jetton input for sells.
    amountIn: coins
    /// Jetton output for buys or GRAM output for sells.
    amountOut: coins
    /// Account receiving the swap output.
    recipient: address
    /// Unused GRAM input returned after curve or max-buy clipping.
    leftover: coins
}

/// Internal message bodies accepted by both production virtual-minter variants.
type StonksPumpVirtualMinterIncomingMessage =
    | StonksPumpJettonMint
    | StonksPumpJettonBurnNotification
    | StonksPumpProvideWalletAddress
    | StonksPumpChangeAdmin
    | StonksPumpChangeContent
    | StonksPumpVirtualMinterInit
    | StonksPumpBuyFromPresale
    | StonksPumpPresaleSellNotificationForMinter

/// Statically decoded internal message bodies emitted by the virtual minter.
type StonksPumpVirtualMinterOutgoingMessage =
    | StonksPumpJettonInternalTransfer
    | StonksPumpJettonExcesses
    | StonksPumpTakeWalletAddress

/// Compact curve and migration state returned by `get_bonding_data`.
struct StonksPumpBondingData {
    /// Migration progress in basis points.
    progressBps: int
    /// GRAM collection target that triggers migration.
    migrationTonTarget: int
    /// Total GRAM-side virtual reserve.
    cumulativeTonReserve: int
    /// Total Jetton-side virtual reserve.
    cumulativeJettonReserve: int
    /// Net GRAM collected by presale buys minus sells.
    tonsCollected: int
    /// Per-buy cap as a percentage of total supply.
    maxBuyPercent: int
    /// Jetton amount sold through the presale.
    tokensSold: int
    /// One while the virtual presale is open, otherwise zero.
    presaleOpen: int
}

/// Standard Jetton master data returned by `get_jetton_data`.
struct StonksPumpJettonData {
    /// Issued Jetton supply in base token units.
    totalSupply: int
    /// Whether the contract can mint additional Jettons.
    mintable: bool
    /// Current admin/factory address.
    adminAddress: address
    /// TEP-64 metadata content cell.
    jettonContent: cell
    /// Jetton wallet code cell.
    jettonWalletCode: cell
}

/// Exit codes shared by the STON.fi and DeDust production variants.
enum StonksPumpVirtualMinterErrors {
    /// Nested Jetton mint payload has an unexpected opcode or shape.
    InvalidMintPayload = 63
    /// Caller is not the stored factory/admin for an authenticated operation.
    UnauthorizedAdmin = 73
    /// Burn notification did not originate from the reported owner's wallet.
    InvalidBurnNotificationSender = 74
    /// Attached value cannot fund a wallet-address response.
    InsufficientWalletDiscoveryValue = 75
    /// DEX migration callback does not match the pending migration state.
    InvalidMigrationCallback = 708
    /// Attached GRAM value is below the operation's gas and forwarding budget.
    InsufficientValue = 709
    /// Sell notification sender is not the expected deterministic wallet.
    InvalidSellSender = 710
    /// Virtual presale is closed or the requested trade exceeds a configured limit.
    PresaleUnavailable = 711
    /// Swap amount, reserve, balance, or output constraint is invalid.
    InvalidAmountOrReserve = 712
    /// Factory initialization or DEX migration configuration is invalid.
    InvalidConfiguration = 713
    /// Message did not originate from the configured DEX component.
    InvalidDexSender = 715
    /// Incoming opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return the deterministic Jetton wallet address for an owner.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return supply, mintability, admin, metadata, and wallet-code fields.
get fun get_jetton_data(): StonksPumpJettonData {
    throw 0;
}

/// Return the deployed virtual-minter implementation version.
get fun get_version(): int {
    throw 0;
}

/// Return the compact virtual-presale curve and migration state.
get fun get_bonding_data(): StonksPumpBondingData {
    throw 0;
}
