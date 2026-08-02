/// Eight parameters used by the GasPump bonding-curve quote formulas.
struct GasPumpBondingCurveParameters {
    /// Fixed-point scale used by the curve arithmetic.
    mathScale: int
    /// Coin-denomination scale used by the curve arithmetic.
    coinScale: int
    /// First curve coefficient.
    alpha: int
    /// Second curve coefficient.
    beta: int
    /// Absolute maximum Jetton supply.
    maxSupply: int
    /// Supply allocated to the bonding-curve phase.
    bondingCurveMaxSupply: int
    /// TON target that ends the bonding-curve phase.
    maxTonAmount: int
    /// TON amount reserved for DEX deployment.
    dexFeeAmount: int
}

/// Complete public state returned by `get_full_jetton_data`.
struct GasPumpFullJettonData {
    /// Current Jetton supply in base units.
    totalSupply: int
    /// Whether this revision permits additional minting through the legacy interface.
    mintable: bool
    /// Contract owner address.
    owner: any_address
    /// TEP-64 Jetton metadata cell.
    content: cell
    /// Code cell used for deterministic Jetton wallets.
    walletCode: cell
    /// Trading phase: zero for curve trading, one for DEX deployment, and two for DEX trading.
    tradeState: int
    /// TON retained by the bonding curve.
    bondingCurveBalance: int
    /// TON accumulated as protocol commission.
    commissionBalance: int
    /// GasPump contract revision stored on chain.
    version: int
    /// Parameters of the bonding-curve quote formulas in canonical GasPump field order.
    bondingCurveParameters: (
        int,
        int,
        int,
        int,
        int,
        int,
        int,
        int,
    )
    /// Protocol commission in promille.
    commissionPromille: int
    /// Current contract balance in nanotons.
    tonBalance: int
    /// Current Jetton price in nanotons.
    priceNanotons: int
    /// Jetton supply not yet sold by the curve.
    supplyLeft: int
    /// Absolute maximum Jetton supply.
    maxSupply: int
}

/// Standard TEP-74 Jetton-master data returned by `get_jetton_data`.
struct GasPumpJettonData {
    /// Current Jetton supply in base units.
    totalSupply: int
    /// Whether the master accepts standard mint requests.
    mintable: bool
    /// Jetton administrator address.
    adminAddress: any_address
    /// TEP-64 Jetton metadata cell.
    jettonContent: cell
    /// Code cell used for deterministic Jetton wallets.
    jettonWalletCode: cell
}

/// Interface identifiers reported by the Tact-generated contract.
struct GasPumpSupportedInterfaces {
    /// Tact IPFS ABI interface identifier.
    ipfsAbi: int
    /// Tact lazy-deployment interface identifier.
    lazyDeployment: int
    /// Tact contract interface identifier.
    tactContract: int
    /// Contract-specific GasPump interface identifier.
    gasPump: int
    /// TEP-74 Jetton-master interface identifier.
    jettonMaster: int
    /// TEP-89 discoverable Jetton interface identifier.
    discoverableJetton: int
    /// Ownable contract interface identifier.
    ownable: int
}

/// Curve parameters persisted in the Tact-generated data tree.
struct GasPumpCurveParametersStorage {
    /// Fixed-point scale used by the curve arithmetic.
    mathScale: uint256
    /// Coin-denomination scale used by the curve arithmetic.
    coinScale: uint256
    /// First curve coefficient.
    alpha: uint256
    /// Referenced limits and the second curve coefficient.
    limits: Cell<GasPumpCurveLimitsStorage>
    /// Referenced fee configuration and embedded wallet code.
    feeAndCode: Cell<GasPumpFeeAndCodeStorage>
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Supply and TON limits persisted by the bonding curve.
struct GasPumpCurveLimitsStorage {
    /// Second curve coefficient.
    beta: uint256
    /// Absolute maximum Jetton supply.
    maxSupply: coins
    /// Supply allocated to the bonding-curve phase.
    bondingCurveMaxSupply: coins
    /// TON target that ends the bonding-curve phase.
    maxTonAmount: coins
    /// TON amount reserved for DEX deployment.
    dexFeeAmount: coins
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Fee configuration and code cells embedded in GasPump storage.
struct GasPumpFeeAndCodeStorage {
    /// Protocol commission in promille.
    commissionPromille: int257
    /// Code cell used for deterministic Jetton wallets.
    walletCode: cell
    /// Alternative wallet/minter code used during wrapping or DEX deployment.
    auxiliaryCode: cell
    /// Reserved tail retained for byte-exact forward compatibility.
    tail: RemainingBitsAndRefs
}

/// Uninitialized lazy-deployment storage shared by the covered revisions.
struct GasPumpMasterDeploymentStorage {
    /// Tact lazy-deployment context cell.
    deploymentContext: cell
    /// False until runtime storage has been initialized.
    initialized: bool
    /// Reserved trailing deployment data; empty in revisions V0 through V5.
    tail: RemainingBitsAndRefs
}

/// Notification emitted when the first non-purchase deployment path completes.
struct (0x67617300) GasPumpDeploymentEvent {
    /// Account that initiated deployment.
    from: address
}

/// A purchase accepted while the token is on the bonding curve.
struct (0x67617301) GasPumpDeployAndBuyEvent {
    /// Buyer address.
    from: address
    /// TON attached to the initial purchase before accounting.
    inputTonAmount: coins
    /// TON credited to the curve after fees and forwarding costs.
    tonAmount: coins
    /// Jetton amount delivered to the buyer.
    jettonAmount: coins
    /// TON commission retained by the protocol.
    feeTonAmount: coins
    /// True when the purchase exceeded the remaining bonding-curve capacity.
    bondingCurveOverflow: bool
}

/// A subsequent bonding-curve purchase.
struct (0x67617302) GasPumpBuyEvent {
    /// Buyer address.
    from: address
    /// TON attached to the purchase before accounting.
    inputTonAmount: coins
    /// TON credited to the curve after fees and forwarding costs.
    tonAmount: coins
    /// Jetton amount delivered to the buyer.
    jettonAmount: coins
    /// TON commission retained by the protocol.
    feeTonAmount: coins
    /// True when the purchase exceeded the remaining bonding-curve capacity.
    bondingCurveOverflow: bool
}

/// A bonding-curve sale completed through a Jetton burn.
struct (0x67617303) GasPumpSellEvent {
    /// Seller address.
    from: address
    /// TON returned to the seller after commission.
    tonAmount: coins
    /// Jetton amount burned by the seller.
    jettonAmount: coins
    /// TON commission retained by the protocol.
    feeTonAmount: coins
}

/// External log messages emitted by GasPump revisions V1 through V4.
type GasPumpMasterV1V4Event =
    | GasPumpDeploymentEvent
    | GasPumpDeployAndBuyEvent
    | GasPumpBuyEvent
    | GasPumpSellEvent
    | GasPumpUnwrapEvent
    | GasPumpDexDepositEvent
    | GasPumpTradeStateEvent

/// External log messages emitted by GasPump revision V5.
type GasPumpMasterV5Event =
    | GasPumpDeploymentEvent
    | GasPumpDeployAndBuyEvent
    | GasPumpBuyEvent
    | GasPumpSellEvent
    | GasPumpUnwrapEvent
    | GasPumpDexDepositEvent
    | GasPumpTradeStateEvent
    | GasPumpSlippageEvent

/// A Jetton amount unwrapped after a burn notification.
struct (0x67617304) GasPumpUnwrapEvent {
    /// Owner whose wrapped Jettons were burned.
    from: address
    /// Jetton amount unwrapped in base units.
    jettonAmount: coins
}

/// Three TON amounts reported when GasPump starts the DEX deposit flow.
struct (0x67617305) GasPumpDexDepositEvent {
    /// First TON amount supplied to the DEX transition.
    amount0: coins
    /// Second TON amount supplied to the DEX transition.
    amount1: coins
    /// Third TON amount retained for the transition.
    amount2: coins
}

/// Trading-state transition emitted by the owner-only state update.
struct (0x67617306) GasPumpTradeStateEvent {
    /// Trading state before the transition.
    previousState: uint16
    /// Trading state after the transition.
    newState: uint16
}

/// V5 notification emitted before rejecting a purchase below its minimum output.
struct (0x67617307) GasPumpSlippageEvent {
    /// Buyer whose minimum-output condition failed.
    from: address
    /// Minimum Jetton amount requested by the buyer.
    minimumJettonAmount: coins
    /// Jetton amount quoted by the bonding curve.
    quotedJettonAmount: coins
}

/// TEP-74 burn notification accepted from a deterministic Jetton wallet.
struct (0x7bdd97de) GasPumpBurnNotification {
    /// Query id copied from the wallet burn request.
    queryId: uint64
    /// Burned Jetton amount in base units.
    amount: coins
    /// Owner whose wallet burned the Jettons.
    owner: address
    /// Optional address that receives the excess-value response.
    responseDestination: address?
}

/// TEP-89 request for a deterministic Jetton wallet address.
struct (0x2c76b973) GasPumpProvideWalletAddress {
    /// Caller-selected query id copied into the response.
    queryId: uint64
    /// Owner whose deterministic wallet address is requested.
    ownerAddress: address
    /// True when the response must include a copy of `ownerAddress`.
    includeAddress: bool
}

/// Owner request that replaces the TEP-64 metadata cell.
struct (0xaf1ca26a) GasPumpUpdateContent {
    /// Referenced replacement Jetton metadata cell.
    content: cell
}

/// Accepted body for opcode `0x00000400` with an opcode-specific raw tail.
struct (0x00000400) GasPumpMessage00000400 {
    /// Opcode-specific payload retained as bits and references.
    payload: RemainingBitsAndRefs
}

/// Owner-authorized TON withdrawal body.
struct (0x1dce79ba) GasPumpMessage1dce79ba {
    /// TON amount to send.
    amount: coins
    /// Internal destination of the withdrawal.
    destination: address
}

/// Owner-authorized trading-state update.
struct (0x268800bd) GasPumpMessage268800bd {
    /// New state value; the event surface serializes its low 16 bits.
    newTradeState: int257
}

/// Owner-authorized value transfer.
struct (0x5b22c66d) GasPumpMessage5b22c66d {
    /// TON amount to transfer.
    amount: coins
    /// Internal destination of the transfer.
    destination: address
}

/// TEP-74 transfer notification accepted from a Jetton wallet.
struct (0x7362d09c) GasPumpMessage7362d09c {
    /// Query id copied from the originating transfer.
    queryId: uint64
    /// Transferred Jetton amount in base units.
    amount: coins
    /// Owner that initiated the transfer.
    sender: address
    /// `Either Cell ^Cell` forward payload, including its selector bit.
    forwardPayload: RemainingBitsAndRefs
}

/// Empty owner-authorized DEX transition request.
struct (0x76b8a294) GasPumpMessage76b8a294 {}

/// Request that assigns the related minter address.
struct (0x819dbe99) GasPumpMessage819dbe99 {
    /// Query id copied into the outgoing assignment notification.
    queryId: uint64
    /// Related wrapped or unwrapped Jetton minter address.
    minterAddress: address
}

/// Owner-authorized arbitrary internal-message send parameters.
struct (0x9b618389) GasPumpMessage9b618389 {
    /// Bounce flag written to the outgoing message header.
    bounce: bool
    /// Internal destination of the outgoing message.
    destination: address
    /// TON value written to the outgoing message.
    value: int257
    /// TVM send mode passed to `send_raw_message`.
    sendMode: int257
    /// Optional referenced outgoing body; absence selects an empty body.
    body: cell?
    /// Optional code cell in the outgoing `StateInit`.
    stateInitCode: cell?
    /// Optional data cell in the outgoing `StateInit`.
    stateInitData: cell?
}

/// Empty owner-authorized DEX transition request used by V1 and later code.
struct (0xa7e7be8a) GasPumpMessageA7e7be8a {}

/// Empty owner-authorized auxiliary deployment request.
struct (0xb70df392) GasPumpMessageB70df392 {}

/// Owner-authorized DEX deployment configuration.
struct (0xb8462adf) GasPumpMessageB8462adf {
    /// First DEX-side internal address.
    address0: address
    /// Second DEX-side internal address.
    address1: address
    /// First referenced DEX code or configuration cell.
    config0: cell
    /// Second referenced DEX code or configuration cell.
    config1: cell
}

/// Owner-authorized accounting increase paired with a value transfer.
struct (0xca153636) GasPumpMessageCa153636 {
    /// Amount added to the tracked balance.
    amount: coins
    /// Internal destination of the paired transfer.
    destination: address
}

/// Empty-body excess-value response keyed by a query id.
struct (0xd53276db) GasPumpMessageD53276db {
    /// Query id associated with the response.
    queryId: uint64
}

/// TEP-74 internal transfer emitted to deterministic Jetton wallets.
struct (0x178d4519) GasPumpJettonInternalTransfer {
    /// Query id copied from the initiating flow.
    queryId: uint64
    /// Jetton amount in base units.
    amount: coins
    /// Address that owns or originated the transferred Jettons.
    from: address
    /// Address that receives excess TON.
    responseDestination: address
    /// TON forwarded with the wallet notification.
    forwardTonAmount: coins
    /// `Either Cell ^Cell` forward payload, including its selector bit.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 transfer emitted while unwrapping through another minter.
struct (0x0f8a7ea5) GasPumpJettonTransfer {
    /// Query id copied from the burn notification.
    queryId: uint64
    /// Jetton amount in base units.
    amount: coins
    /// Destination owner of the transferred Jettons.
    destination: address
    /// Address that receives excess TON.
    responseDestination: address
    /// Optional custom payload reference.
    customPayload: cell?
    /// TON forwarded with the transfer.
    forwardTonAmount: coins
    /// `Either Cell ^Cell` forward payload, including its selector bit.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-89 deterministic wallet-address response.
struct (0xd1735400) GasPumpTakeWalletAddress {
    /// Query id copied from `GasPumpProvideWalletAddress`.
    queryId: uint64
    /// Deterministic Jetton wallet address.
    walletAddress: address
    /// Optional copy of the requested owner address.
    ownerAddress: address?
}

/// Related-minter assignment notification.
struct (0x327b2b4a) GasPumpMinterAssignment {
    /// Query id copied from the assignment request.
    queryId: uint64
    /// Related wrapped or unwrapped Jetton minter address.
    minterAddress: address
}

/// DEX-side request with a zero query id and the null internal address.
struct (0x00000003) GasPumpDexMessage03 {
    /// Query id; GasPump serializes zero.
    queryId: uint64
    /// Null internal address serialized by the DEX transition.
    destination: address
}

/// DEX-side request that carries a referenced Jetton internal-transfer body.
struct (0x00000015) GasPumpDexMessage15 {
    /// Query id; GasPump serializes zero.
    queryId: uint64
    /// GasPump master address.
    master: address
    /// TON forwarded to the DEX-side contract.
    forwardTonAmount: coins
    /// Referenced TEP-74 internal-transfer body.
    transfer: Cell<GasPumpJettonInternalTransfer>
}

/// Internal outgoing bodies constructed by revision V0.
type GasPumpMasterV0OutgoingMessage =
    | GasPumpJettonInternalTransfer
    | GasPumpJettonTransfer
    | GasPumpTakeWalletAddress
    | GasPumpMinterAssignment
    | GasPumpDexMessage15

/// Internal and external outgoing bodies constructed by revisions V1 through V4.
type GasPumpMasterV1V4OutgoingMessage =
    | GasPumpJettonInternalTransfer
    | GasPumpJettonTransfer
    | GasPumpTakeWalletAddress
    | GasPumpMinterAssignment
    | GasPumpDexMessage03
    | GasPumpDexMessage15
    | GasPumpMasterV1V4Event

/// Internal and external outgoing bodies constructed by revision V5.
type GasPumpMasterV5OutgoingMessage =
    | GasPumpJettonInternalTransfer
    | GasPumpJettonTransfer
    | GasPumpTakeWalletAddress
    | GasPumpMinterAssignment
    | GasPumpDexMessage03
    | GasPumpDexMessage15
    | GasPumpMasterV5Event

/// Exit codes used by the covered GasPump master revisions.
enum GasPumpMasterErrors {
    /// Stack underflow or equivalent TVM primitive failure.
    StackUnderflow = 11
    /// Contract-specific validation failure.
    Validation73 = 73
    /// Contract-specific validation failure.
    Validation74 = 74
    /// Contract-specific validation failure.
    Validation75 = 75
    /// Invalid incoming message prefix.
    InvalidMessage = 128
    /// Invalid opcode or serialized message body.
    InvalidOpcode = 129
    /// Unauthorized message sender.
    Unauthorized = 130
    /// Unexpected trailing data or invalid reference shape.
    InvalidBody = 132
    /// Address serialization has an unexpected bit length or workchain.
    InvalidAddress = 136
    /// Address is not a supported internal address.
    UnsupportedAddress = 137
    /// Operation is unavailable in the current trade state.
    InvalidTradeState = 333
    /// Contract-specific launch or DEX transition failure.
    Operation705 = 705
    /// Contract-specific launch or DEX transition failure.
    Operation706 = 706
    /// Contract-specific launch or DEX transition failure.
    Operation707 = 707
    /// Contract-specific launch or DEX transition failure.
    Operation708 = 708
    /// Contract-specific launch or DEX transition failure.
    Operation709 = 709
}
