/// Grambo bonding-curve Jetton master interface.
contract GramboJettonMaster {
    author: "Grambo"
    description: "Grambo bonding-curve Jetton master and Jetton wallet coordinator."
    storage: GramboJettonMasterStorage
    incomingMessages: GramboJettonMasterIncomingMessage
    outgoingMessages: GramboJettonMasterOutgoingMessage
    forceAbiExport: GramboJettonMasterEvent
    thrownErrors: GramboJettonMasterErrors
}

/// Fee amounts emitted with a completed trade event.
struct GramboJettonMasterTradeFees {
    /// Referrer fee paid from the trade.
    referrerFee: coins
    /// First configured protocol fee.
    fee1: coins
    /// Second configured protocol fee.
    fee2: coins
}

/// Sell constraints carried by a Jetton transfer notification.
struct GramboJettonMasterSellParams {
    /// Minimum GRAM amount accepted for the sale.
    minTonOut: coins
    /// Optional fee-referrer address encoded inline.
    referrer: address?
    /// Optional referenced application payload.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Launch parameters installed by the Grambo factory.
struct (0x372f1ae3) GramboJettonMasterLaunch {
    /// Factory request identifier.
    queryId: uint64
    /// Creator that receives the initial purchase.
    buyer: address
    /// Virtual GRAM reserve used by the curve.
    virtualTonReserve: coins
    /// GRAM target that triggers graduation.
    tonTarget: coins
    /// Creator's initial GRAM purchase amount.
    prebuyAmount: coins
}

/// Buys Jettons from the bonding curve.
struct (0x2f54494e) GramboJettonMasterBuy {
    /// Caller-selected request identifier.
    queryId: uint64
    /// GRAM offered to the curve before fees.
    tonAmount: coins
    /// Recipient of minted Jettons.
    recipient: address
    /// Minimum Jetton output accepted by the caller.
    minTokensOut: coins
    /// Optional referrer address encoded inline.
    referrer: address?
    /// Optional referenced application payload.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Jetton-wallet notification that requests a curve sale.
struct (0x31fc1276) GramboJettonMasterSellNotification {
    /// Original Jetton transfer query identifier.
    queryId: uint64
    /// Jetton amount offered for sale.
    amount: coins
    /// Owner whose wallet sent the notification.
    from: address
    /// Address for excess-value return.
    responseDestination: address?
    /// Optional referenced sale constraints.
    sellParams: Cell<GramboJettonMasterSellParams>?
}

/// Requests the deterministic wallet address for an owner.
struct (0x17b5012c) GramboJettonMasterProvideWalletAddress {
    /// Caller-selected request identifier.
    queryId: uint64
    /// Owner whose wallet address is requested.
    owner: address
    /// Whether the response includes the owner address in a reference.
    includeAddress: bool
}

/// Activates an owner's deterministic Jetton wallet.
struct (0x7966410f) GramboJettonMasterUnlockWallet {
    /// Caller-selected request identifier.
    queryId: uint64
    /// Owner of the wallet to activate.
    owner: address
}

/// Withdraws GRAM held by the curve to its factory.
struct (0x43e84bb5) GramboJettonMasterWithdraw {
    /// Caller-selected request identifier.
    queryId: uint64
    /// GRAM amount requested for withdrawal.
    amount: coins
}

/// Internal bodies accepted by the bonding-curve master.
type GramboJettonMasterIncomingMessage =
    | GramboJettonMasterLaunch
    | GramboJettonMasterBuy
    | GramboJettonMasterSellNotification
    | GramboJettonMasterProvideWalletAddress
    | GramboJettonMasterUnlockWallet
    | GramboJettonMasterWithdraw

/// Standard Jetton transfer sent to a recipient wallet.
struct (0x178d4519) GramboJettonMasterInternalTransfer {
    /// Trade request identifier.
    queryId: uint64
    /// Jetton amount to credit.
    amount: coins
    /// Master contract that initiated the transfer.
    from: address?
    /// Address used for excess-value responses.
    responseAddress: address?
    /// GRAM forwarded with the transfer.
    forwardTonAmount: coins
    /// Empty inline payload or a referenced payload under the Jetton standard.
    forwardPayload: RemainingBitsAndRefs
}

/// Activates a Grambo Jetton wallet.
struct (0x6b75d3e2) GramboJettonMasterActivateWallet {
    /// Request identifier copied from the unlock request.
    queryId: uint64
}

/// Returns a requested deterministic wallet address.
struct (0x29cb7264) GramboJettonMasterTakeWalletAddress {
    /// Request identifier copied from the request.
    queryId: uint64
    /// Optional reference containing the requested owner address.
    ownerAddress: Cell<address>?
}

/// Standard Jetton excess-value response.
struct (0xd53276db) GramboJettonMasterExcess {
    /// Request identifier associated with the excess value.
    queryId: uint64
}

/// Body-bearing internal messages emitted by the master.
type GramboJettonMasterOutgoingMessage =
    | GramboJettonMasterInternalTransfer
    | GramboJettonMasterActivateWallet
    | GramboJettonMasterTakeWalletAddress
    | GramboJettonMasterExcess

/// Emits a completed curve trade as an external outbound message.
struct (0x5025398e) GramboJettonMasterSwapEvent {
    /// Trade request identifier.
    queryId: uint64
    /// Buyer or seller that received the trade result.
    recipient: address?
    /// True for a buy and false for a sell.
    isBuy: bool
    /// Total GRAM collected by the curve after this trade.
    newCollectedTon: coins
    /// GRAM amount used for the trade before fee distribution.
    tonAmount: coins
    /// Jetton amount bought or sold.
    tokenAmount: coins
    /// Optional referrer address encoded inline.
    referrer: address?
    /// Referenced fee split for the trade.
    fees: Cell<GramboJettonMasterTradeFees>
    /// Optional referenced application payload.
    customPayload: Cell<RemainingBitsAndRefs>?
}

/// Emits graduation amounts when the curve reaches its GRAM target.
struct (0x0ab3d75c) GramboJettonMasterGraduateEvent {
    /// Trade request identifier that caused graduation.
    queryId: uint64
    /// GRAM amount forwarded to DEX liquidity.
    tonToDex: coins
    /// Jetton amount forwarded to DEX liquidity.
    tokensToDex: coins
}

/// External outbound events emitted by the master.
type GramboJettonMasterEvent =
    | GramboJettonMasterSwapEvent
    | GramboJettonMasterGraduateEvent

/// Mutable curve counters and fee recipients kept in a referenced cell.
struct GramboJettonMasterCurveState {
    /// GRAM amount currently collected by the curve.
    collectedTon: coins
    /// Jetton amount sold by the curve.
    tokensSold: coins
    /// Whether liquidity graduation has completed.
    graduated: bool
    /// First protocol fee recipient.
    feeAddress1: address
    /// Second protocol fee recipient.
    feeAddress2: address
}

/// DEX endpoints used during curve graduation.
struct GramboJettonMasterDexConfig {
    /// STON.fi router destination.
    stonfiRouter: address
    /// Router pTON wallet destination.
    ptonWallet: address
}

/// Persistent bonding-curve and Jetton-master storage.
struct GramboJettonMasterStorage {
    /// Virtual GRAM reserve used in the curve equation.
    virtualTonReserve: coins
    /// GRAM target that triggers graduation.
    tonTarget: coins
    /// Factory authorized to launch and withdraw.
    factory: address
    /// Fixed total Jetton supply.
    totalSupply: coins
    /// Deterministic seed used in wallet StateInit derivation.
    seed: uint256
    /// Referenced mutable curve counters and fee recipients.
    curveState: Cell<GramboJettonMasterCurveState>
    /// Jetton wallet code embedded in derived wallet StateInits.
    walletCode: cell
    /// Jetton metadata content cell.
    metadata: cell
    /// Referenced DEX configuration for graduation.
    dexConfig: Cell<GramboJettonMasterDexConfig>
}

/// Return tuple of `get_curve_state`.
struct GramboJettonMasterCurveStateResult {
    /// Virtual GRAM reserve used in the curve equation.
    virtualTonReserve: coins
    /// GRAM target that triggers graduation.
    tonTarget: coins
    /// GRAM amount collected by the curve.
    collectedTon: coins
    /// Jetton amount sold by the curve.
    tokensSold: coins
    /// Whether the curve has graduated.
    graduated: bool
}

/// Returns curve reserve and progress counters.
get fun get_curve_state(): GramboJettonMasterCurveStateResult {
    throw 0;
}

/// Quotes Jetton output for a supplied GRAM input before executing a buy.
get fun get_amount_out(tonIn: coins): int {
    throw 0;
}

/// Quotes GRAM output for a supplied Jetton input before executing a sell.
get fun get_ton_out(tokensIn: int): coins {
    throw 0;
}

/// Return tuple of the standard Jetton `get_jetton_data` getter.
struct GramboJettonMasterJettonData {
    /// Fixed total Jetton supply.
    totalSupply: int
    /// Zero indicates that minting is disabled.
    mintable: int
    /// Factory address returned as the Jetton administrator.
    adminAddress: any_address
    /// Jetton metadata content cell.
    jettonContent: cell
    /// Wallet code cell.
    jettonWalletCode: cell
}

/// Returns standard Jetton master metadata.
get fun get_jetton_data(): GramboJettonMasterJettonData {
    throw 0;
}

/// Returns the deterministic wallet address for an owner.
get fun get_wallet_address(ownerAddress: any_address): any_address {
    throw 0;
}

/// Exit codes thrown by the deployed bonding-curve master.
enum GramboJettonMasterErrors {
    /// A sender does not match the expected deterministic wallet or factory.
    UnauthorizedSender = 74
    /// The requested curve transition is invalid.
    InvalidCurveTransition = 65296
    /// The requested output is below the caller's minimum.
    SlippageExceeded = 65344
    /// The sender is not authorized for the requested operation.
    Unauthorized = 65347
    /// Attached or retained GRAM is insufficient.
    InsufficientValue = 65360
    /// The wallet has already been activated.
    WalletAlreadyActivated = 65397
    /// The curve has already graduated.
    CurveGraduated = 65398
}
