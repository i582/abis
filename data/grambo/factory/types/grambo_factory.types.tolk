/// Registry that deploys Grambo bonding-curve Jetton masters from shared code and configuration.
contract GramboFactory {
    author: "Grambo"
    description: "Grambo launchpad registry and bonding-curve Jetton deployer."
    storage: GramboFactoryStorage
    incomingMessages: GramboFactoryIncomingMessage
    outgoingMessages: GramboFactoryOutgoingMessage
    forceAbiExport: GramboFactoryDeployConfig
        | GramboFactoryDeployConfigResult
        | GramboFactoryLegacyNoop
    thrownErrors: GramboFactoryErrors
}

/// Persistent registry owner and referenced deployment configuration.
struct GramboFactoryStorage {
    /// Administrator authorized to replace the deployment configuration or code.
    admin: address
    /// Shared code, fee, and DEX addresses used for new bonding-curve masters.
    deployConfig: Cell<GramboFactoryDeployConfig>
}

/// Shared inputs used to derive and initialize each new Grambo Jetton master.
struct GramboFactoryDeployConfig {
    /// Bonding-curve Jetton master code installed in the deployed StateInit.
    bondingCurveCode: cell
    /// Jetton wallet code embedded in each deployed master.
    jettonWalletCode: cell
    /// GRAM amount paid to the configured fee collector for each deployment.
    deployFee: coins
    /// Account that receives the deployment fee.
    feeCollector: address
    /// STON.fi router used when a bonding curve graduates.
    stonfiRouter: address
    /// Router pTON wallet used to seed graduated liquidity.
    stonfiRouterPtonWallet: address
}

/// Creates a new Grambo bonding-curve Jetton master.
struct (0x0d4295e0) GramboFactoryDeploy {
    /// Caller-supplied request identifier forwarded to the launched master.
    queryId: uint64
    /// Referenced Jetton metadata content stored by the launched master.
    metadata: cell
    /// GRAM reserve threshold at which the bonding curve graduates.
    tonTarget: coins
    /// GRAM amount spent for the creator's initial token purchase.
    prebuyAmount: coins
}

/// Replaces the shared deployment configuration.
struct (0x20b031d9) GramboFactoryUpdateDeployConfig {
    /// Administrative request identifier retained for wire compatibility.
    queryId: uint64
    /// New master/wallet code, fee, and DEX configuration.
    deployConfig: Cell<GramboFactoryDeployConfig>
}

/// Replaces the Registry contract code.
struct (0x61d196c1) GramboFactoryUpgradeContract {
    /// Administrative request identifier retained for wire compatibility.
    queryId: uint64
    /// New executable code cell.
    code: cell
}

/// Legacy accepted opcode whose remaining body is intentionally ignored.
struct (0x0a61fb91) GramboFactoryLegacyNoop {
    /// Uninterpreted legacy payload after the opcode.
    tail: RemainingBitsAndRefs
}

/// Internal messages accepted by the Grambo Registry.
type GramboFactoryIncomingMessage =
    | GramboFactoryDeploy
    | GramboFactoryUpdateDeployConfig
    | GramboFactoryUpgradeContract
    | GramboFactoryLegacyNoop

/// Initializes a freshly deployed Grambo bonding-curve Jetton master.
struct (0x372f1ae3) GramboFactoryLaunch {
    /// Request identifier copied from the deployment request.
    queryId: uint64
    /// Account that requested and initially buys the token.
    buyer: address
    /// Initial virtual GRAM reserve used by the bonding curve.
    virtualTonReserve: coins
    /// GRAM reserve threshold at which the token graduates.
    tonTarget: coins
    /// GRAM amount spent on the creator's initial purchase.
    prebuyAmount: coins
}

/// Body-bearing internal messages emitted by the Grambo Registry.
type GramboFactoryOutgoingMessage = GramboFactoryLaunch

/// Return tuple of `get_deploy_config`.
struct GramboFactoryDeployConfigResult {
    /// GRAM amount paid to the fee collector for a deployment.
    deployFee: coins
    /// Account that receives the deployment fee.
    feeCollector: address
    /// STON.fi router used for bonding-curve graduation.
    stonfiRouter: address
    /// Router pTON wallet used to seed graduated liquidity.
    stonfiRouterPtonWallet: address
}

/// Returns the fee and DEX addresses used for new deployments.
get fun get_deploy_config(): GramboFactoryDeployConfigResult {
    throw 0;
}

/// Exit codes thrown by the exact deployed Grambo Registry.
enum GramboFactoryErrors {
    /// Bonding-curve reserve or target parameters are outside allowed bounds.
    InvalidCurveParameters = 65299
    /// The sender is not the configured Registry administrator.
    Unauthorized = 65347
    /// Attached GRAM does not cover deployment, forwarding, and fee requirements.
    InsufficientMessageValue = 65360
    /// The non-empty message body has an unsupported opcode.
    UnsupportedOpcode = 65535
}
