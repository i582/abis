/// XTR master that coordinates Telegram Stars purchases and a Jetton-compatible supply.
contract XtrMaster {
    author: "Telegram"
    description: "XTR master coordinating signed Stars purchase requests, versioned user and payment contracts, and a Jetton-compatible token supply."
    storage: XtrMasterStorage
    incomingMessages: XtrMasterIncomingMessage
    outgoingMessages: XtrMasterOutgoingMessage
    forceAbiExport: XtrMasterStarPrice
        | XtrMasterUpdateData
        | XtrMasterPushXtr
        | XtrMasterCommitXtr
        | XtrMasterChildRoutePayload
        | XtrMasterSignedTransferPayload
        | XtrMasterPurchaseStatePayload
    thrownErrors: XtrMasterErrors
}

/// Signed price quote embedded inline in a Stars purchase request.
struct XtrMasterStarPrice {
    /// Ed25519 signature over the expiry timestamp and quoted price tail.
    signature: bits512
    /// Unix timestamp used as the quote deadline; requests are accepted while `now <= timestamp`.
    timestamp: uint32
    /// TON-denominated price authorized by the quote signer.
    starPrice: coins
}

/// Requests an XTR purchase using a signed Stars price quote.
@overflow1023_policy("suppress")
struct (0x6fc25520) XtrMasterBuyXtr {
    /// User address used to derive the destination user contract.
    userAddress: address
    /// Number of XTR units requested by the user.
    amount: coins
    /// Signed quote checked by the master before routing the purchase.
    starPrice: XtrMasterStarPrice
}

/// Routes value to a versioned child contract selected for an address.
struct (0x339f0e49) XtrMasterRouteToChild {
    /// Destination child contract address.
    destination: address
}

/// Standard Jetton transfer notification accepted from a deterministic wallet.
struct (0x7362d09c) XtrMasterTransferNotification {
    /// Query identifier copied from the Jetton transfer flow.
    queryId: uint64
    /// Jetton amount transferred to the master.
    amount: coins
    /// Previous owner of the transferred Jettons.
    sender: address?
    /// Referenced signed quote and application payload consumed by the master.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton burn notification accepted from a deterministic wallet.
struct (0x7bdd97de) XtrMasterBurnNotification {
    /// Query identifier copied into an optional excess response.
    queryId: uint64
    /// Jetton amount removed from the tracked supply.
    amount: coins
    /// Owner whose deterministic wallet reported the burn.
    sender: address
    /// Optional address that receives the excess-value response.
    responseDestination: address?
    /// Optional payload copied into the external burn event.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Requests a Jetton transfer after validating the calling deterministic wallet.
struct (0x308b2848) XtrMasterTransferFromWallet {
    /// Destination owner used to derive the recipient wallet.
    destination: address
    /// Jetton amount transferred to the recipient wallet.
    amount: coins
}

/// Routes an opaque payload through the latest payment-contract version.
struct (0x2a999df4) XtrMasterUpdatePayment {
    /// Versioned payment contract that receives the routed request.
    destination: address
    /// Payload processed by the selected payment contract.
    payload: Cell<RemainingBitsAndRefs>
}

/// Routes an opaque payload through the latest user-contract version.
struct (0x59ff81d6) XtrMasterUpdateUser {
    /// Versioned user contract that receives the routed request.
    destination: address
    /// Payload processed by the selected user contract.
    payload: Cell<RemainingBitsAndRefs>
}

/// Installs the next user-contract version.
struct (0xf480aa15) XtrMasterInstallUserVersion {
    /// Replacement Jetton wallet code stored as the third user-version reference.
    jettonWalletCode: cell
    /// Replacement component stored as the second user-version reference.
    component1: cell
}

/// Installs the next payment-contract version.
struct (0x8f724fdc) XtrMasterInstallPaymentVersion {
    /// Replacement component stored as the third payment-version reference.
    component2: cell
    /// Replacement component stored as the second payment-version reference.
    component1: cell
}

/// Accepted no-op message used by the deployed master.
struct (0xbe30a46d) XtrMasterNoop {}

/// Internal message bodies accepted directly by the deployed master.
type XtrMasterIncomingMessage =
    | XtrMasterBuyXtr
    | XtrMasterRouteToChild
    | XtrMasterTransferNotification
    | XtrMasterBurnNotification
    | XtrMasterTransferFromWallet
    | XtrMasterUpdatePayment
    | XtrMasterUpdateUser
    | XtrMasterInstallUserVersion
    | XtrMasterInstallPaymentVersion
    | XtrMasterNoop

/// Versioned child-contract update installed before a payload is processed.
struct XtrMasterUpdateData {
    /// Child-contract code selected for the requested version.
    code: cell
    /// Initial or replacement child-contract data.
    data: cell
    /// Monotonically increasing child-contract version.
    version: uint32
}

/// Deploys or updates a versioned child contract and passes it a payload.
struct (0xe2628539) XtrMasterUpdateContractAndProcessMessage {
    /// Version definition installed by the receiving child contract.
    updateData: Cell<XtrMasterUpdateData>
    /// Original sender copied from the request received by the master.
    fromAddress: address
    /// TON value copied from the request received by the master.
    fromAmount: coins
    /// Original referenced payload passed to the child contract.
    payload: Cell<RemainingBitsAndRefs>
}

/// Standard Jetton transfer request emitted toward a deterministic wallet.
struct (0x0f8a7ea5) XtrMasterJettonTransfer {
    /// Query identifier; the deployed master emits zero.
    queryId: uint64
    /// Jetton amount transferred to the destination owner.
    amount: coins
    /// Destination owner whose deterministic wallet receives the transfer.
    destination: address
    /// Optional address that receives excess TON.
    responseDestination: address?
    /// Optional application payload passed to the destination wallet.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// TON amount forwarded by the destination wallet.
    forwardTonAmount: coins
    /// Inline or referenced payload forwarded by the destination wallet.
    forwardPayload: RemainingBitsAndRefs
}

/// Purchase dispatch emitted by the master toward a versioned user contract.
struct (0x4af6f2fe) XtrMasterPurchaseDispatch {
    /// Exact nested StateInit and request payload retained as an opaque tail.
    payload: RemainingBitsAndRefs
}

/// External event emitted after the master accepts a Jetton burn notification.
struct (0xca444ce6) XtrMasterBurnEvent {
    /// Jetton amount removed from the tracked supply.
    amount: coins
    /// Owner copied from the accepted burn notification.
    sender: address
    /// Optional payload copied from the burn notification.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Standard Jetton excess-value response.
struct (0xd53276db) XtrMasterExcess {
    /// Query identifier copied from the completed request.
    queryId: uint64
}

/// Body-bearing messages emitted directly by the deployed master.
type XtrMasterOutgoingMessage =
    | XtrMasterUpdateContractAndProcessMessage
    | XtrMasterJettonTransfer
    | XtrMasterPurchaseDispatch
    | XtrMasterBurnEvent
    | XtrMasterExcess

/// Child-contract request to account for a pushed XTR amount.
struct (0x6f027868) XtrMasterPushXtr {
    /// Child-contract sequence number associated with the request.
    seqno: uint64
    /// XTR amount pushed by the request.
    amount: coins
}

/// User payload that commits an XTR amount to the master supply.
struct (0xe472935c) XtrMasterCommitXtr {
    /// Child-contract sequence number used in sender derivation.
    seqno: uint64
    /// User address used in sender derivation.
    userAddress: address
    /// XTR amount added to the tracked supply.
    amount: coins
}

/// Empty child payload used when the master routes a version update.
struct (0xfbef68d0) XtrMasterChildRoutePayload {}

/// Validated transfer amounts passed to a versioned child contract.
struct (0x57057b6b) XtrMasterSignedTransferPayload {
    /// Jetton amount reported by the transfer notification.
    amount: coins
    /// TON-denominated price accepted from the signed payload.
    starPrice: coins
}

/// Nested purchase state assembled for a versioned child contract.
struct (0x9416422e) XtrMasterPurchaseStatePayload {
    /// Exact child-code, StateInit, and request tail retained without speculative field names.
    payload: RemainingBitsAndRefs
}

/// Version record for user child contracts.
struct XtrMasterUserVersion {
    /// Monotonically increasing user-contract version.
    version: uint32
    /// Stable component retained when a new version is installed.
    component0: cell
    /// Mutable component replaced when a new version is installed.
    component1: cell
    /// Deterministic Jetton wallet code returned by `get_jetton_data`.
    jettonWalletCode: cell
}

/// Version record for payment child contracts and their request sequence.
struct XtrMasterPaymentVersion {
    /// Monotonically increasing payment-contract version.
    version: uint32
    /// Stable component retained when a new version is installed.
    component0: cell
    /// Mutable component replaced when a new version is installed.
    component1: cell
    /// Auxiliary component replaced when a new version is installed.
    component2: cell
    /// Next payment sequence number used by the purchase flow.
    seqno: uint64
}

/// Referenced user and payment version records.
struct XtrMasterVersions {
    /// Latest user-contract version definition.
    user: Cell<XtrMasterUserVersion>
    /// Latest payment-contract version definition and sequence.
    payment: Cell<XtrMasterPaymentVersion>
}

/// Persistent root state of the deployed XTR master.
struct XtrMasterStorage {
    /// Administrator authorized to install new user- and payment-contract versions.
    admin: address
    /// Coordinator authorized to submit signed purchase requests.
    purchaseCoordinator: address
    /// Third coordinator address retained by the deployed master.
    auxiliaryCoordinator: address
    /// Current Jetton-compatible XTR supply.
    totalSupply: coins
    /// Referenced user and payment version records.
    versions: Cell<XtrMasterVersions>
    /// Jetton metadata content returned by `get_jetton_data`.
    jettonContent: cell
}

/// Standard Jetton master tuple returned by `get_jetton_data`.
struct XtrMasterJettonData {
    /// Current Jetton-compatible XTR supply.
    totalSupply: int
    /// The deployed master reports that minting is enabled.
    mintable: int
    /// Master administrator address.
    adminAddress: any_address
    /// Jetton metadata content cell.
    jettonContent: cell
    /// Deterministic Jetton wallet code cell.
    jettonWalletCode: cell
}

/// Returns the latest user-contract version.
get fun get_user_latest_version(): uint32 {
    throw 0;
}

/// Returns the deterministic Jetton wallet address for an owner.
get fun get_wallet_address(ownerAddress: any_address): any_address {
    throw 0;
}

/// Returns standard Jetton master data.
get fun get_jetton_data(): XtrMasterJettonData {
    throw 0;
}

/// Returns the latest payment-contract version.
get fun get_payment_latest_version(): uint32 {
    throw 0;
}

/// Exit codes thrown by the deployed XTR master.
enum XtrMasterErrors {
    /// A burn notification does not come from the expected deterministic wallet.
    InvalidJettonWallet = 74
    /// The sender, nested address, or signed payload does not match the expected value.
    Unauthorized = 1000
    /// Attached TON is below the minimum required by the selected operation.
    InsufficientValue = 1003
    /// The Ed25519 Stars price signature is invalid.
    InvalidPriceSignature = 1005
    /// The signed Stars price quote has expired.
    PriceExpired = 1006
    /// The incoming opcode is not supported.
    UnsupportedOperation = 65535
}
