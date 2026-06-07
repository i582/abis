/// TONCO v1.6 Pool Factory interface for pool order creation and Router pool deployment.
contract ToncoPoolFactory {
    author: "Algebra / TONCO"
    version: "1.6"
    description: "Curated TONCO PoolFactory ABI for v1.6 pool creation orders, whitelist management, deterministic order address derivation, and Router create-pool callbacks"
    storage: ToncoPoolFactoryStorage
    incomingMessages: ToncoPoolFactoryIncomingMessage
    outgoingMessages: ToncoPoolFactoryOutgoingMessage
    forceAbiExport: ToncoPoolFactoryWhitelistEntry
}

/// Runtime PoolFactory storage loaded from the root data cell.
struct ToncoPoolFactoryStorage {
    /// Factory admin authorized for factory parameter and whitelist updates.
    adminAddress: address
    /// TONCO Router address that receives create-pool callbacks.
    routerAddress: address
    /// TON price parameter stored by the factory; live mainnet currently returns zero.
    tonPrice: coins
    /// Order child contract code used for deterministic pool-order addresses.
    orderCode: cell
    /// Default NFT collection metadata content used for newly created pools.
    nftv3Content: cell
    /// Default Position NFT item metadata content used for newly created pools.
    nftv3itemContent: cell
    /// Optional whitelist dictionary cell; key/value layout is proven only as raw dictionary storage.
    whitelist: cell?
}

/// Whitelist entry value shape used by factory add/delete messages and exported for ABI consumers.
struct ToncoPoolFactoryWhitelistEntry {
    /// Whitelisted address receiving selected pool-creation permissions.
    address: address
    /// Permission to set a pool controller.
    allowSetController: bool
    /// Permission to set a pool creator.
    allowSetCreator: bool
    /// Permission to activate the pool at creation time.
    allowSetActive: bool
    /// Permission to override fee/tick/content settings.
    allowSetSettings: bool
    /// Permission to override NFT metadata content.
    allowSetContent: bool
}

/// Structured return value of `getPoolFactoryData`.
struct ToncoPoolFactoryDataReply {
    /// Factory admin address.
    adminAddress: address
    /// Router address paired with this factory.
    routerAddress: address
    /// Factory TON price parameter.
    tonPrice: int
    /// Default NFT collection metadata content.
    nftv3Content: cell
    /// Default Position NFT item metadata content.
    nftv3itemContent: cell
}

/// Structured return value of `getOrderAddress`.
struct ToncoPoolFactoryOrderAddressReply {
    /// Deterministic order address for the supplied pair of pool Jetton wallets.
    orderAddress: address
}

/// Referenced Jetton wallet pair cell inside `create_pool`.
struct ToncoPoolFactoryCreatePoolWalletCell {
    /// Jetton wallet for token0.
    jetton0Wallet: address
    /// Jetton wallet for token1.
    jetton1Wallet: address
}

/// Referenced Jetton minter pair sent to the deterministic order child during initialization.
struct ToncoPoolFactoryOrderInitMinterCell {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
}

/// Optional v1.6 create-pool settings cell.
struct ToncoPoolFactoryCreatePoolSettingsCell {
    /// LP fee setting requested for the new pool.
    fee: uint16
    /// Tick spacing requested for the new pool.
    tickSpacing: uint24
    /// Whether the new pool should be activated immediately.
    active: bool
    /// Optional replacement NFT content cell.
    nftContent: cell?
}

/// User/admin request to create a pool through a deterministic order contract.
struct (0x9e9a8f7f) ToncoPoolFactoryCreatePool {
    /// Query id propagated through order creation.
    queryId: uint64
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// Packed settings flags used by the v1.6 factory path.
    settings: uint16
    /// Referenced token0/token1 pool Jetton wallet pair.
    walletCell: Cell<ToncoPoolFactoryCreatePoolWalletCell>
    /// Optional referenced v1.6 fee/tick/content settings.
    settingsCell: Cell<ToncoPoolFactoryCreatePoolSettingsCell>?
}

/// Factory-to-order initialization message for the deterministic pool-order child.
struct (0x8b85de63) ToncoPoolFactoryOrderInit {
    /// Query id copied from the user create-pool request.
    queryId: uint64
    /// Router address that the order child uses to complete pool creation.
    routerAddress: address
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// Packed factory settings value copied from the create-pool request.
    settings: uint16
    /// Referenced Jetton minter pair for the pool being ordered.
    minterCell: Cell<ToncoPoolFactoryOrderInitMinterCell>
}

/// Order-child callback that asks PoolFactory to execute the Router create-pool flow.
struct (0xd4b33b0a) ToncoPoolFactoryOrderExecute {
    /// Query id copied from the order initialization path.
    queryId: uint64
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// Packed factory settings value copied from the order initialization path.
    settings: uint16
    /// Referenced token0/token1 pool Jetton wallet pair.
    walletCell: Cell<ToncoPoolFactoryCreatePoolWalletCell>
}

/// Admin message that changes Router and default NFT content parameters.
struct (0xaa0db3d7) ToncoPoolFactoryChangeParams {
    /// Query id for the parameter update.
    queryId: uint64
    /// Replacement Router address.
    routerAddress: address
    /// Replacement default pool collection metadata.
    nftv3Content: cell
    /// Replacement default Position NFT item metadata.
    nftv3itemContent: cell
}

/// Admin message that returns excess TON after preserving factory storage reserve.
struct (0x42a0fb43) ToncoPoolFactoryResetGas {
    /// Query id for tracing the reset-gas command.
    queryId: uint64
}

/// Admin message that adds or replaces a whitelist entry.
struct (0x8d7721f0) ToncoPoolFactoryAddToWhitelist {
    /// Query id for the whitelist update.
    queryId: uint64
    /// Address to insert into the whitelist dictionary.
    address: address
    /// Permission to set a pool controller.
    allowSetController: bool
    /// Permission to set a pool creator.
    allowSetCreator: bool
    /// Permission to activate a pool.
    allowSetActive: bool
    /// Permission to override fee/tick/settings.
    allowSetSettings: bool
    /// Permission to override NFT metadata content.
    allowSetContent: bool
}

/// Admin message that removes an address from the whitelist dictionary.
struct (0x256eb11c) ToncoPoolFactoryDelFromWhitelist {
    /// Query id for the whitelist deletion.
    queryId: uint64
    /// Address key to remove from the whitelist dictionary.
    address: address
}

/// Referenced minter/controller cell forwarded by the factory to Router create-pool.
struct Routerv3CreatePoolMinterCell {
    /// Jetton minter for token0.
    jetton0Minter: address
    /// Jetton minter for token1.
    jetton1Minter: address
    /// Controller address for the newly created pool.
    controllerAddress: address
}

/// Factory-to-Router callback that deploys or initializes a pool.
struct (0x2e3034ef) Routerv3CreatePool {
    /// Query id copied from the factory order flow.
    queryId: uint64
    /// Pool Jetton wallet for token0.
    jettonWallet0: address
    /// Pool Jetton wallet for token1.
    jettonWallet1: address
    /// Pool tick spacing.
    tickSpacing: int24
    /// Initial square-root price Q96 value.
    initialPriceX96: uint160
    /// Whether the Router should activate the pool.
    activatePool: bool
    /// Protocol fee basis-points-like value stored by the pool.
    protocolFee: uint16
    /// Base LP fee stored by the pool.
    lpFeeBase: uint16
    /// Current active LP fee stored by the pool.
    lpFeeCurrent: uint16
    /// Pool NFT collection metadata content.
    nftv3Content: cell
    /// Position NFT item metadata content.
    nftv3itemContent: cell
    /// Referenced Jetton minter and controller data.
    minterCell: Cell<Routerv3CreatePoolMinterCell>
}

/// Internal message bodies accepted by TONCO PoolFactory.
type ToncoPoolFactoryIncomingMessage =
    | ToncoPoolFactoryCreatePool
    | ToncoPoolFactoryOrderExecute
    | ToncoPoolFactoryChangeParams
    | ToncoPoolFactoryResetGas
    | ToncoPoolFactoryAddToWhitelist
    | ToncoPoolFactoryDelFromWhitelist

/// Internal message bodies emitted by PoolFactory toward order children and the Router.
type ToncoPoolFactoryOutgoingMessage =
    | ToncoPoolFactoryOrderInit
    | Routerv3CreatePool

/// Return PoolFactory admin, Router, TON price, and default NFT content cells.
get fun getPoolFactoryData(): ToncoPoolFactoryDataReply {
    throw 0;
}

/// Return the deterministic order address for a pair of pool Jetton wallets.
get fun getOrderAddress(
    jetton0Wallet: address,
    jetton1Wallet: address,
): ToncoPoolFactoryOrderAddressReply {
    throw 0;
}

/// Return the raw whitelist dictionary cell, or null when the dictionary is absent.
get fun getWhitelist(): cell? {
    throw 0;
}
