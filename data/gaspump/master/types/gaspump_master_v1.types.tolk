import "./gaspump_master_common.types"

/// GasPump Jetton master revision V1.
contract GasPumpMasterV1 {
    author: "GasPump"
    version: "1"
    description: "GasPump V1 bonding-curve Jetton master."
    storage: GasPumpMasterV1Storage
    storageAtDeployment: GasPumpMasterDeploymentStorage
    incomingMessages: GasPumpMasterV1IncomingMessage
    outgoingMessages: GasPumpMasterV1V4OutgoingMessage
    forceAbiExport: GasPumpMasterV1V4OutgoingMessage
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

/// Referenced trading state used by revision V1.
struct GasPumpMasterV1TradingStorage {
    /// Stored GasPump contract revision.
    version: int257
    /// Bonding-curve parameters and embedded wallet code.
    parameters: Cell<GasPumpCurveParametersStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Persistent Tact storage of GasPump master revision V1.
struct GasPumpMasterV1Storage {
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
    /// Legacy auxiliary code/configuration cell.
    auxiliaryCode: cell
    /// Current trading phase.
    tradeState: uint16
    /// TON retained by the bonding curve.
    bondingCurveBalance: coins
    /// TON accumulated as protocol commission.
    commissionBalance: coins
    /// Revision-specific 128-bit accounting accumulator.
    accountingAccumulator: uint128
    /// Referenced trading state and curve parameters.
    trading: Cell<GasPumpMasterV1TradingStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// V1 bonding-curve buy request.
struct (0x6cd3e4b0) GasPumpMasterV1Buy {
    /// True to execute the purchase; false selects the quote/check path.
    execute: bool
}

/// Internal messages accepted by GasPump master revision V1.
type GasPumpMasterV1IncomingMessage =
    | GasPumpMessage00000400
    | GasPumpMessage1dce79ba
    | GasPumpMessage268800bd
    | GasPumpProvideWalletAddress
    | GasPumpMessage5b22c66d
    | GasPumpMasterV1Buy
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
