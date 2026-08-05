import "./gaspump_master_common.types"

/// ABI-compatible GasPump Jetton master revisions V2 and V3.
contract GasPumpMasterV2 {
    author: "GasPump"
    version: "2-3"
    description: "ABI-compatible GasPump V2 and V3 bonding-curve Jetton masters."
    storage: GasPumpMasterV2V3Storage
    storageAtDeployment: GasPumpMasterDeploymentStorage
    incomingMessages: GasPumpMasterV2V3IncomingMessage
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

/// Estimates Jettons received for a GRAM purchase.
get fun getBuyAmount(tonAmount: int): int {
    throw 0;
}

/// Estimates GRAM received for a Jetton sale.
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

/// Referenced trading state shared by revisions V2 and V3.
struct GasPumpMasterV2V3TradingStorage {
    /// Stored GasPump contract revision, two or three for these contracts.
    version: int257
    /// Bonding-curve parameters and embedded wallet code.
    parameters: Cell<GasPumpCurveParametersStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Persistent storage shared byte-for-byte by the V2 and V3 ABI layouts.
struct GasPumpMasterV2V3Storage {
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
    /// GRAM retained by the bonding curve.
    bondingCurveBalance: coins
    /// GRAM accumulated as protocol commission.
    commissionBalance: coins
    /// Revision-specific 128-bit accounting accumulator.
    accountingAccumulator: uint128
    /// Referenced trading state and curve parameters.
    trading: Cell<GasPumpMasterV2V3TradingStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// V2/V3 bonding-curve buy request.
struct (0x6cd3e4b0) GasPumpMasterV2V3Buy {
    /// True to execute the purchase; false selects the quote/check path.
    execute: bool
}

/// Internal messages accepted by GasPump master revisions V2 and V3.
type GasPumpMasterV2V3IncomingMessage =
    | GasPumpMessage00000400
    | GasPumpMessage1dce79ba
    | GasPumpMessage268800bd
    | GasPumpProvideWalletAddress
    | GasPumpMessage5b22c66d
    | GasPumpMasterV2V3Buy
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
