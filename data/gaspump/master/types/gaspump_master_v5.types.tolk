import "./gaspump_master_common.types"

/// GasPump Jetton master revision V5.
contract GasPumpMasterV5 {
    author: "GasPump"
    version: "5"
    description: "GasPump V5 bonding-curve Jetton master with slippage-limited buys."
    storage: GasPumpMasterV5Storage
    storageAtDeployment: GasPumpMasterDeploymentStorage
    incomingMessages: GasPumpMasterV5IncomingMessage
    outgoingMessages: GasPumpMasterV5OutgoingMessage
    forceAbiExport: GasPumpMasterV5OutgoingMessage
    thrownErrors: GasPumpMasterErrors
}

/// Returns the contract owner.
get fun owner(): any_address {
    throw 0;
}

/// Returns complete GasPump and Jetton state.
get fun get_full_jetton_data(): (
    int,
    int,
    any_address,
    cell,
    cell,
    int,
    int,
    int,
    int,
    tuple,
    int,
    int,
    int,
    int,
    int,
) {
    throw 0;
}

/// Returns standard TEP-74 Jetton-master state.
get fun get_jetton_data(): GasPumpJettonData {
    throw 0;
}

/// Computes the deterministic Jetton wallet for an owner.
get fun get_wallet_address(ownerAddress: any_address): any_address {
    throw 0;
}

/// Returns the related wrapped/unwrapped Jetton minter address.
get fun anotherMinterAddress(): any_address {
    throw 0;
}

/// Estimates Jettons received for a TON purchase.
get fun getBuyAmount(tonAmount: int): int {
    throw 0;
}

/// Estimates TON received for a Jetton sale.
get fun getSellAmount(jettonAmount: int): int {
    throw 0;
}

/// Returns the CID of the original Tact ABI as an IPFS slice.
get fun get_abi_ipfs(): slice {
    throw 0;
}

/// Returns the seven supported interface identifiers.
get fun supported_interfaces(): GasPumpSupportedInterfaces {
    throw 0;
}

/// Referenced trading and accounting state used by revision V5.
struct GasPumpMasterV5TradingStorage {
    /// TON accumulated as protocol commission.
    commissionBalance: coins
    /// Revision-specific 128-bit accounting accumulator.
    accountingAccumulator: uint128
    /// Stored GasPump contract revision.
    version: int257
    /// Bonding-curve parameters and embedded wallet code.
    parameters: Cell<GasPumpCurveParametersStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Persistent Tact storage of GasPump master revision V5.
struct GasPumpMasterV5Storage {
    /// Tact lazy-deployment context cell.
    deploymentContext: cell
    /// True after lazy deployment has initialized runtime storage.
    initialized: bool
    /// Current Jetton supply in base units.
    totalSupply: int257
    /// Contract owner address.
    owner: any_address
    /// Runtime configuration flag retained by the generated Tact contract.
    runtimeFlag: bool
    /// TEP-64 Jetton metadata cell.
    content: cell
    /// Auxiliary internal address used by the V5 deployment and DEX flows.
    auxiliaryAddress: any_address
    /// Revision-specific auxiliary code/configuration cell.
    auxiliaryCode: cell
    /// Current trading phase.
    tradeState: uint16
    /// TON retained by the bonding curve.
    bondingCurveBalance: coins
    /// Referenced trading state and curve parameters.
    trading: Cell<GasPumpMasterV5TradingStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// V5 bonding-curve buy request with an optional minimum-output limit.
struct (0x6cd3e4b0) GasPumpMasterV5Buy {
    /// True to execute the purchase; false selects the quote/check path.
    execute: bool
    /// Optional minimum Jetton amount accepted by the buyer.
    limit: int257?
}

/// Internal messages accepted by GasPump master revision V5.
type GasPumpMasterV5IncomingMessage =
    | GasPumpMessage00000400
    | GasPumpMessage1dce79ba
    | GasPumpMessage268800bd
    | GasPumpProvideWalletAddress
    | GasPumpMessage5b22c66d
    | GasPumpMasterV5Buy
    | GasPumpMessage7362d09c
    | GasPumpMessage76b8a294
    | GasPumpBurnNotification
    | GasPumpMessage819dbe99
    | GasPumpMessage9b618389
    | GasPumpMessageA7e7be8a
    | GasPumpUpdateContent
    | GasPumpMessageB70df392
    | GasPumpMessageB8462adf
    | GasPumpMessageCa153636
    | GasPumpMessageD53276db
