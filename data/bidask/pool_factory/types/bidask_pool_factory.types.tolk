/// Curated ABI for the live Bidask DLMM Pool Factory code hash b3309225...
contract BidaskPoolFactory {
    author: "Bidask Protocol"
    version: "0.9.2-live"
    description: "Bidask DLMM factory for deterministic regular and limit pool deployment, owner administration, and pool-address lookup"
    storage: BidaskPoolFactoryStorage
    incomingMessages: BidaskPoolFactoryIncomingMessage
    outgoingMessages: BidaskPoolFactoryOutgoingMessage
}

/// Root factory storage proven from the saved live account data BoC.
struct BidaskPoolFactoryStorage {
    /// Factory owner address authorized to change fees, code cells, owner, and full data/code.
    owner: address
    /// Regular DLMM Pool code cell; live child hash matches BidaskPool code hash b1215034...
    poolCode: cell
    /// Referenced bundle containing Range, LP, DAMM, and auxiliary code cells plus fee presets.
    codeBundle: Cell<BidaskPoolFactoryCodeBundle>
}

/// First referenced storage bundle after the root pool code.
struct BidaskPoolFactoryCodeBundle {
    /// Range contract code; live child hash matches BidaskRange code hash 4bd7191b...
    rangeCode: cell
    /// LP multitoken code; live child hash matches BidaskLpMultitoken code hash a2ce96a1...
    lpMultitokenCode: cell
    /// Auxiliary DLMM account code; live cell hash 2d15e226... is not matched to a named shared artifact yet.
    tradeAccountCode: cell
    /// Deeper bundle with vault, DAMM, wallet, fees, and preset dictionary.
    extendedCodes: Cell<BidaskPoolFactoryExtendedCodes>
}

/// Second referenced storage bundle.
struct BidaskPoolFactoryExtendedCodes {
    /// Internal liquidity vault code; live child hash matches BidaskInternalLiquidityVault code hash 5b80fb22...
    internalLiquidityVaultCode: cell
    /// DAMM LP/account auxiliary code; live cell hash e538097d... is not matched to a named shared artifact yet.
    dammLpAccountCode: cell
    /// DAMM Pool code; live child hash matches BidaskDammPool code hash 760f60fe...
    dammPoolCode: cell
    /// Final bundle with DAMM LP wallet, two unknown code slots, fee rates, and presets.
    tail: Cell<BidaskPoolFactoryCodeTail>
}

/// Final referenced storage bundle.
struct BidaskPoolFactoryCodeTail {
    /// DAMM LP wallet code; live child hash matches BidaskDammLpWallet code hash 9644004d...
    dammLpWalletCode: cell
    /// Auxiliary code slot with live hash 0062b404..., role still unassigned.
    unknownCode0: cell
    /// Auxiliary code slot with live hash 2d15e226..., duplicating the first-bundle unknown code hash.
    unknownCode1: cell
    /// Default protocol fee returned by `fees`, stored as a 16-bit unsigned integer in the live code.
    protocolFee: uint16
    /// Default referral fee returned by `fees`, stored as a 16-bit unsigned integer in the live code.
    refFee: uint16
    /// Inline HashmapE 257 of bin-step presets; live values include 1->135, 2->67, 3->63, ..., 500->0.
    presets: map<int257, int257>
}

/// Referenced sqrt-price cell used by the live DeployPool receiver.
struct BidaskPoolFactorySqrtPriceCell {
    /// Initial sqrt price; live code rejects zero before constructing child state.
    initSqrtP: uint256
}

/// Referenced amount cell used by the live DeployLimPool receiver.
struct BidaskPoolFactoryLimPoolAmountsCell {
    /// First auxiliary amount loaded from the DeployLimPool reference.
    amount0: coins
    /// Second auxiliary amount loaded from the DeployLimPool reference.
    amount1: coins
    /// Third auxiliary amount loaded from the DeployLimPool reference.
    amount2: coins
}

/// Live regular-pool deployment body for opcode 0xfda6ca3c.
struct (0xfda6ca3c) BidaskPoolFactoryDeployPoolMsg {
    /// Caller-selected query id copied into the outgoing VanityDeployMsg.
    queryId: uint64
    /// Random seed cell used in deterministic child state calculation.
    seed: cell
    /// Pool token X Jetton wallet address; live code rejects addr_none.
    tokenX: address
    /// Pool token Y Jetton wallet address.
    tokenY: address
    /// Pool bin step and key into the factory preset dictionary.
    binStep: uint32
    /// LP fee stored into the child pool/range state.
    lpFee: uint16
    /// Dynamic-fee multiplier/factor inferred from Range storage and live deploy code.
    dynamicFeeFactor: uint32
    /// Dynamic-fee time filter parameter inferred from Range storage and live deploy code.
    timeFilter: uint32
    /// Dynamic-fee time decay parameter; live code requires this to be greater than timeFilter.
    timeDecay: uint32
    /// Initial active bin number.
    initBin: int32
    /// Referenced cell containing the 256-bit initial sqrt price in the live receiver.
    initSqrtPrice: Cell<BidaskPoolFactorySqrtPriceCell>
}

/// Live limit-pool deployment body for opcode 0x0273228f; extra fields are not named by docs/SDK.
struct (0x0273228f) BidaskPoolFactoryDeployLimPoolMsg {
    /// Caller-selected query id copied into the outgoing VanityDeployMsg.
    queryId: uint64
    /// Random seed cell used in deterministic child state calculation.
    seed: cell
    /// Limit pool token X Jetton wallet address; live code rejects addr_none.
    tokenX: address
    /// Limit pool token Y Jetton wallet address.
    tokenY: address
    /// Observed 16-bit configuration value stored twice in child state; semantic name remains unproven.
    configUint16: uint16
    /// First observed 32-bit configuration value stored into child static data.
    configUint32A: uint32
    /// Second observed 32-bit configuration value; live code checks it is non-negative.
    configUint32B: uint32
    /// Third observed 32-bit configuration value; live code requires it to be greater than configUint32B.
    configUint32C: uint32
    /// Observed 64-bit configuration value stored into child static data.
    configUint64: uint64
    /// Base amount loaded as TL-B Coins before the referenced amount cell.
    baseAmount: coins
    /// Referenced cell containing three additional TL-B Coins amounts.
    amounts: Cell<BidaskPoolFactoryLimPoolAmountsCell>
}

/// Owner-only live fee update body for opcode 0xcc6cc979.
struct (0xcc6cc979) BidaskPoolFactoryChangeFees {
    /// Caller-selected query id; parsed but not otherwise used by the live branch.
    queryId: uint64
    /// New default protocol fee written into storage.
    protocolFee: uint16
    /// New default referral fee written into storage.
    refFee: uint16
}

/// Nested code bundle carried by the live ChangeCodes body.
struct BidaskPoolFactoryChangeCodesBundle {
    /// Replacement LP multitoken code.
    lpMultitokenCode: cell
    /// Replacement auxiliary DLMM account code.
    tradeAccountCode: cell
    /// Replacement internal liquidity vault code.
    internalLiquidityVaultCode: cell
    /// Replacement DAMM/account code bundle.
    extendedCodes: Cell<BidaskPoolFactoryChangeCodesExtended>
}

/// Second nested code bundle carried by the live ChangeCodes body.
struct BidaskPoolFactoryChangeCodesExtended {
    /// Replacement DAMM LP/account auxiliary code.
    dammLpAccountCode: cell
    /// Replacement DAMM Pool code.
    dammPoolCode: cell
    /// Replacement DAMM LP wallet code.
    dammLpWalletCode: cell
    /// Final replacement bundle for the two unknown code slots.
    tail: Cell<BidaskPoolFactoryChangeCodesTail>
}

/// Final nested ChangeCodes bundle; fees and presets are preserved from existing storage.
struct BidaskPoolFactoryChangeCodesTail {
    /// Replacement auxiliary code slot with unassigned semantic role.
    unknownCode0: cell
    /// Replacement auxiliary code slot with unassigned semantic role.
    unknownCode1: cell
}

/// Owner-only live code update body for opcode 0x06ef7cc8.
struct (0x06ef7cc8) BidaskPoolFactoryChangeCodes {
    /// Caller-selected query id; parsed but not otherwise used by the live branch.
    queryId: uint64
    /// Replacement regular DLMM Pool code.
    poolCode: cell
    /// Replacement Range code.
    rangeCode: cell
    /// Replacement nested code bundle.
    codeBundle: Cell<BidaskPoolFactoryChangeCodesBundle>
}

/// Owner-only full contract upgrade body for opcode 0x4a01a54b.
struct (0x4a01a54b) BidaskPoolFactoryUpgrade {
    /// Caller-selected query id; parsed before owner check.
    queryId: uint64
    /// Complete replacement data cell passed to set_data.
    newData: cell
    /// Complete replacement code cell passed to set_code.
    newCode: cell
}

/// Internal pool-address request body for opcode 0x1da920f0.
struct (0x1da920f0) BidaskPoolFactoryGetterPoolAddress {
    /// Caller-selected query id copied into the answer body.
    queryId: uint64
    /// Seed cell used with the factory address to calculate the deterministic pool address.
    seed: cell
    /// Optional payload forwarded verbatim to the GetterPoolAddressAnswer.
    forwardPayload: cell?
}

/// Owner-only live owner update body for opcode 0x819dbe99.
struct (0x819dbe99) BidaskPoolFactoryChangeOwner {
    /// Caller-selected query id copied into ChangeOwnerOk.
    queryId: uint64
    /// New factory owner address.
    newOwner: address
}

/// Internal message bodies accepted by the live Pool Factory receiver.
type BidaskPoolFactoryIncomingMessage =
    | BidaskPoolFactoryDeployPoolMsg
    | BidaskPoolFactoryDeployLimPoolMsg
    | BidaskPoolFactoryChangeFees
    | BidaskPoolFactoryChangeCodes
    | BidaskPoolFactoryUpgrade
    | BidaskPoolFactoryGetterPoolAddress
    | BidaskPoolFactoryChangeOwner

/// Outgoing deployment envelope emitted for regular and limit pool child deployment.
struct (0xb814c41a) BidaskPoolFactoryVanityDeployMsg {
    /// Query id copied from the deployment request.
    queryId: uint64
    /// Child data/state-init data cell.
    newData: cell
    /// Child code cell.
    newCode: cell
}

/// Pool-address answer emitted by the internal GetterPoolAddress receiver.
struct (0x82754eb1) BidaskPoolFactoryGetterPoolAddressAnswer {
    /// Query id copied from the request.
    queryId: uint64
    /// Deterministic pool address derived from factory address and seed.
    poolAddress: address
    /// Optional payload copied from the request when present.
    forwardPayload: cell?
}

/// Owner-change acknowledgement emitted before the owner field is updated.
struct (0x327b2b4a) BidaskPoolFactoryChangeOwnerOk {
    /// Query id copied from the owner-change request.
    queryId: uint64
    /// New factory owner address acknowledged by the contract.
    newOwner: address
}

/// Internal message bodies emitted by the live Pool Factory receiver.
type BidaskPoolFactoryOutgoingMessage =
    | BidaskPoolFactoryVanityDeployMsg
    | BidaskPoolFactoryGetterPoolAddressAnswer
    | BidaskPoolFactoryChangeOwnerOk

/// Structured result returned by the live `fees` getter.
struct GetBidaskPoolFactoryFeesReply {
    /// Current default protocol fee returned as a TVM stack integer.
    protocolFee: int
    /// Current default referral fee returned as a TVM stack integer.
    refFee: int
}

/// Tact compatibility getter; live bytecode returns the ASCII hex SDK interface hash.
get fun sdk_interfaces_hash(): string {
    throw 0;
}

/// Return the factory preset dictionary as a raw optional cell.
get fun get_presets(): cell? {
    throw 0;
}

/// Return the current factory owner.
get fun owner(): address {
    throw 0;
}

/// Return the deterministic pool address for a deployer/factory address and seed cell.
get fun get_pool_address(deployer: address, seed: cell): address {
    throw 0;
}

/// Return the raw factory data cell.
get fun get_storage(): cell {
    throw 0;
}

/// Return the current default protocol and referral fees.
get fun fees(): GetBidaskPoolFactoryFeesReply {
    throw 0;
}
