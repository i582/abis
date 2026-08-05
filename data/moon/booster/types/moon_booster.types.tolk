/// MoonCX booster that releases GRAM or Jettons to a pool in scheduled rounds.
contract MoonBooster {
    author: "MoonCX"
    version: "1.0"
    description: "MoonCX pool booster with administrator-controlled funding, scheduled tick-tock payouts, and GRAM or Jetton boost delivery."
    storage: MoonBoosterStorage
    storageAtDeployment: MoonBoosterDeploymentStorage
    incomingMessages: MoonBoosterIncomingMessage
    outgoingMessages: MoonBoosterOutgoingMessage
    forceAbiExport: MoonBoosterBoostData | MoonBoosterJettonBoostPayload
    thrownErrors: MoonBoosterErrors
}

/// Per-round boost schedule stored by an active booster.
struct MoonBoosterBoostData {
    /// GRAM or Jetton amount released in each round, in the asset's elementary units.
    amountPerRound: coins
    /// Unix timestamp from which the first round can be released.
    startTime: uint64
    /// Zero-based index of the next scheduled round.
    currentRound: uint16
    /// Delay between scheduled rounds, in seconds.
    roundInterval: uint64
    /// Total number of scheduled rounds.
    roundCount: uint16
    /// Jetton wallet used for Jetton boosts, or `addr_none` for direct GRAM boosts.
    jettonWallet: address?
}

/// Persistent root stored before a boost schedule is installed.
struct MoonBoosterDeploymentStorage {
    /// Lifecycle state; zero means that no active boost schedule is stored.
    status: uint8
    /// Protocol-assigned booster identifier.
    boosterId: uint64
    /// Administrator authorized to configure the booster.
    admin: address?
    /// Protocol address that can close an expired boost and receives excess value.
    responseDestination: address?
    /// MoonCX pool that receives scheduled boosts.
    pool: address?
}

/// Persistent root stored while the booster has a boost schedule.
struct MoonBoosterStorage {
    /// Lifecycle state; one is scheduled and two awaits a Jetton funding notification.
    status: uint8
    /// Protocol-assigned booster identifier.
    boosterId: uint64
    /// Administrator authorized to configure the booster.
    admin: address?
    /// Protocol address that can close an expired boost and receives excess value.
    responseDestination: address?
    /// MoonCX pool that receives scheduled boosts.
    pool: address?
    /// Referenced schedule and optional Jetton wallet.
    boost: Cell<MoonBoosterBoostData>
}

/// Extra inline fields supplied when configuration requests Jetton funding.
struct MoonBoosterFundingTail {
    /// Address passed unchanged to the protocol funding request.
    fundingAddress: address?
    /// Jetton amount requested from the protocol funding contract.
    amount: coins
}

/// Configuration tail: absent for a direct schedule or present for Jetton funding.
type MoonBoosterConfigurationTail = MoonBoosterFundingTail | void

/// Installs a boost schedule or requests Jetton funding for one.
struct (0x9b77f0b2) MoonBoosterConfigure {
    /// Request identifier copied into the optional funding request.
    queryId: uint64
    /// Configuration mode: one installs the schedule and two requests Jetton funding.
    mode: uint8
    /// Referenced schedule to install or fund.
    boost: Cell<MoonBoosterBoostData>
    /// Mode-dependent funding fields, or an empty tail for direct installation.
    funding: MoonBoosterConfigurationTail
}

/// Standard Jetton transfer notification received during Jetton funding.
struct (0x7362d09c) MoonBoosterJettonTransferNotification {
    /// Query identifier received from the Jetton wallet.
    queryId: uint64
    /// Amount of Jettons received in elementary units.
    amount: coins
    /// Previous Jetton owner whose wallet initiated the transfer.
    sender: address?
    /// Inline or referenced forward payload left opaque by the deployed booster.
    forwardPayload: RemainingBitsAndRefs
}

/// Signals that an expired boost can return its remaining balance.
struct (0xa9e3e577) MoonBoosterCloseExpired {
    /// Request identifier copied into refund and excess messages.
    queryId: uint64
}

/// Internal message bodies handled explicitly by the deployed booster.
type MoonBoosterIncomingMessage =
    | MoonBoosterConfigure
    | MoonBoosterJettonTransferNotification
    | MoonBoosterCloseExpired

/// Requests protocol-side Jetton funding for a configured boost.
@overflow1023_policy("suppress")
struct (0xb3644f09) MoonBoosterFundingRequest {
    /// Request identifier copied from the configuration message.
    queryId: uint64
    /// Protocol-assigned booster identifier.
    boosterId: uint64
    /// Address that receives protocol responses and excess value.
    responseDestination: address?
    /// MoonCX pool that will receive the scheduled boost.
    pool: address?
    /// Address copied from the configuration funding tail.
    fundingAddress: address?
    /// Requested Jetton amount in elementary units.
    amount: coins
}

/// Standard Jetton transfer emitted for a boost or a rejected notification refund.
struct (0x0f8a7ea5) MoonBoosterJettonTransfer {
    /// Request identifier; scheduled boost transfers use zero.
    queryId: uint64
    /// Jetton amount transferred in elementary units.
    amount: coins
    /// Destination owner of the transferred Jettons.
    destination: address?
    /// Address that receives the Jetton wallet's excess-value response.
    responseDestination: address?
    /// Optional Jetton-wallet custom payload; the booster emits none.
    customPayload: Cell<RemainingBitsAndRefs>?
    /// GRAM amount forwarded with the Jetton transfer notification.
    forwardTonAmount: coins
    /// Inline or referenced payload forwarded by the destination Jetton wallet.
    forwardPayload: RemainingBitsAndRefs
}

/// Direct GRAM boost request sent to the MoonCX pool.
struct (0x96aa1586) MoonBoosterPoolBoost {
    /// Request identifier; scheduled tick-tock payouts use zero.
    queryId: uint64
}

/// Payload forwarded through a Jetton wallet when boosting a pool with Jettons.
struct (0x96aa1586) MoonBoosterJettonBoostPayload {
    /// Protocol address embedded after the Moon boost opcode.
    responseDestination: address?
}

/// Standard excess-value response emitted when a boost closes.
struct (0xd53276db) MoonBoosterExcesses {
    /// Request identifier copied from the close request, or zero after the final round.
    queryId: uint64
}

/// Body-bearing internal messages emitted directly by the deployed booster.
type MoonBoosterOutgoingMessage =
    | MoonBoosterFundingRequest
    | MoonBoosterJettonTransfer
    | MoonBoosterPoolBoost
    | MoonBoosterExcesses

/// Returns the complete persistent root as a cell.
get fun get_booster(): cell {
    throw 0;
}

/// Returns the current lifecycle state.
get fun get_status(): uint8 {
    throw 0;
}

/// Returns the referenced boost schedule, or an empty cell before configuration.
get fun get_boost_data(): cell {
    throw 0;
}

/// Returns the MoonCX pool that receives scheduled boosts.
get fun get_pool(): any_address {
    throw 0;
}

/// Exit codes thrown by the deployed MoonCX booster.
enum MoonBoosterErrors {
    /// The sender is not authorized for the selected operation.
    UnauthorizedSender = 300
    /// The operation is invalid for the current lifecycle state or schedule time.
    InvalidState = 410
    /// The incoming message does not carry enough GRAM for the selected operation.
    InsufficientValue = 500
}
