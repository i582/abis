/// StonksPump factory that deploys and initializes virtual-liquidity Jetton minters.
contract StonksPumpVirtualFactory {
    author: "Stonks"
    version: "2"
    description: "StonksPump factory validates launch parameters, deploys deterministic virtual-liquidity Jetton minters, and controls factory availability."
    storage: StonksPumpVirtualFactoryStonfiStorage
    incomingMessages: StonksPumpVirtualFactoryIncomingMessage
    outgoingMessages: StonksPumpVirtualFactoryOutgoingMessage
    forceAbiExport: StonksPumpVirtualFactoryDedustStorage
        | StonksPumpVirtualFactoryDedustData
        | StonksPumpVirtualMinterFactoryInit
        | StonksPumpVirtualFactoryDevBuy
    thrownErrors: StonksPumpVirtualFactoryErrors
}

/// Persistent state of the STON.fi factory implementation represented by the catalog fixture.
struct StonksPumpVirtualFactoryStonfiStorage {
    /// Code used to derive and deploy virtual-minter state initialization.
    virtualMinterCode: cell
    /// Code embedded in every deployed virtual minter for deterministic user Jetton wallets.
    jettonWalletCode: cell
    /// STON.fi router used when the bonding curve migrates to a live DEX pool.
    routerAddress: address
    /// True when the factory rejects new virtual-minter creation requests.
    disabled: bool
}

/// Persistent state shared by the current and legacy DeDust factory implementations.
struct StonksPumpVirtualFactoryDedustStorage {
    /// Code used to derive and deploy virtual-minter state initialization.
    virtualMinterCode: cell
    /// Code embedded in every deployed virtual minter for deterministic user Jetton wallets.
    jettonWalletCode: cell
    /// DeDust-specific launch configuration copied into virtual-minter initialization.
    dexConfig: cell
    /// True when the factory rejects new virtual-minter creation requests.
    disabled: bool
}

/// Request to deploy and initialize one virtual-liquidity Jetton minter.
struct (0xcc1a9801) StonksPumpCreateVirtualLiquidityJetton {
    /// Caller-selected correlation id copied into the minter initialization.
    queryId: uint64
    /// Referenced TEP-64 metadata content stored by the new Jetton minter.
    content: cell
    /// GRAM amount used for an optional developer purchase during initialization.
    devBuyTonAmount: coins
    /// Maximum percentage of total supply accepted by one virtual-presale buy.
    maxBuyPercent: uint16
    /// Wallet receiving Jettons from the optional developer purchase.
    devWallet: address
}

/// Authenticated request to transfer GRAM from the factory to the protocol controller.
struct (0xcc1a9804) StonksPumpVirtualFactoryWithdrawTon {
    /// Controller-selected correlation id.
    queryId: uint64
    /// GRAM amount transferred from the factory balance, in nanograms.
    amount: coins
}

/// Authenticated request to enable or disable new virtual-minter creation.
struct (0xcc1a9805) StonksPumpVirtualFactorySetDisabled {
    /// Controller-selected correlation id.
    queryId: uint64
    /// New factory availability flag.
    disabled: bool
}

/// Optional developer purchase embedded in the emitted virtual-minter initialization.
struct StonksPumpVirtualFactoryDevBuy {
    /// GRAM amount reserved for the developer's initial virtual-presale buy.
    tonAmount: coins
    /// Wallet that receives Jettons bought during initialization.
    recipient: address
    /// Minimum Jetton amount accepted for the developer buy.
    minJettonsOut: coins
}

/// Factory-emitted initialization for a newly deployed virtual-liquidity minter.
struct (0xcc1a9802) StonksPumpVirtualMinterFactoryInit {
    /// Query id copied from the creation request.
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
    devBuy: Cell<StonksPumpVirtualFactoryDevBuy>
}

/// Internal message bodies accepted by every production factory variant.
type StonksPumpVirtualFactoryIncomingMessage =
    | StonksPumpCreateVirtualLiquidityJetton
    | StonksPumpVirtualFactoryWithdrawTon
    | StonksPumpVirtualFactorySetDisabled

/// Statically decoded internal message bodies emitted by factory creation.
type StonksPumpVirtualFactoryOutgoingMessage = StonksPumpVirtualMinterFactoryInit

/// STON.fi factory state returned by `get_factory_data`.
struct StonksPumpVirtualFactoryStonfiData {
    /// Code used to derive and deploy virtual-minter state initialization.
    virtualMinterCode: cell
    /// Code embedded in virtual minters for deterministic user Jetton wallets.
    jettonWalletCode: cell
    /// STON.fi router used for post-bonding-curve migration.
    routerAddress: address
    /// True when new virtual-minter creation is disabled.
    disabled: bool
}

/// DeDust factory state returned by `get_factory_data`.
struct StonksPumpVirtualFactoryDedustData {
    /// Code used to derive and deploy virtual-minter state initialization.
    virtualMinterCode: cell
    /// Code embedded in virtual minters for deterministic user Jetton wallets.
    jettonWalletCode: cell
    /// DeDust-specific launch configuration copied into minter initialization.
    dexConfig: cell
    /// True when new virtual-minter creation is disabled.
    disabled: bool
}

/// Exit codes shared by the STON.fi and DeDust production factory variants.
enum StonksPumpVirtualFactoryErrors {
    /// Attached value, requested withdrawal, or remaining factory balance is insufficient.
    InsufficientValue = 709
    /// Creation parameters are outside the factory's accepted bounds.
    InvalidCreationParameters = 713
    /// Caller is not the authenticated protocol controller for a control request.
    UnauthorizedController = 715
    /// Factory creation is currently disabled.
    FactoryDisabled = 716
    /// Incoming opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return code cells, the STON.fi router, and the disabled flag.
get fun get_factory_data(): StonksPumpVirtualFactoryStonfiData {
    throw 0;
}
