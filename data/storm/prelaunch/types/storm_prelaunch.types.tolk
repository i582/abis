/// Storm Trade Prelaunch vault interface.
contract StormPrelaunch {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade Prelaunch vault for participant storage, jetton notifications, admin controls, reward notifier sends, and public getters."
    storage: StormPrelaunchStorage
    incomingMessages: StormPrelaunchIncomingMessage
    outgoingMessages: StormPrelaunchOutgoingMessage
    forceAbiExport: StormPrelaunchParticipant | StormPrelaunchUserRewardCountsReply
    thrownErrors: StormPrelaunchErrors
}

/// Runtime Prelaunch storage.
struct StormPrelaunchStorage {
    /// Participant dictionary keyed by basechain address hash.
    participants: map<uint256, StormPrelaunchParticipant>
    /// Admin address authorized for configuration, migration, and withdrawal messages.
    adminAddress: address
    /// Deposit window start timestamp stored as Unix seconds.
    startTime: uint32
    /// Deposit window end timestamp stored as Unix seconds.
    endTime: uint32
    /// True after the initial TEP-89 wallet-address discovery reply is accepted.
    walletDiscovered: bool
    /// Jetton wallet after discovery; before discovery this slot is the wallet discovery target.
    jettonWalletAddress: address
    /// Reward notifier address that receives reward-count updates.
    rewardNotifierAddress: address
}

/// Participant dictionary value stored under a uint256 address hash.
struct StormPrelaunchParticipant {
    /// Jetton amount already accepted for this participant.
    depositedAmount: coins
    /// Maximum jetton amount accepted for this participant.
    targetAmount: coins
    /// First reward counter returned by method id 104966 and sent to the notifier.
    rewardCountA: uint32
    /// Second reward counter returned by method id 104966 and sent to the notifier.
    rewardCountB: uint32
}

/// TEP-89 wallet discovery request emitted while `walletDiscovered` is false.
struct (0x2c76b973) StormPrelaunchProvideWalletAddress {
    /// Query id set to the current block timestamp by the live code.
    queryId: uint64
    /// Owner address whose jetton wallet is requested.
    ownerAddress: address
    /// False in the live send site; no owner-address include reference is requested.
    includeAddress: bool
}

/// TEP-89 wallet discovery reply accepted from the discovery target.
struct (0xd1735400) StormPrelaunchTakeWalletAddress {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// Discovered jetton wallet address stored in runtime storage.
    walletAddress: address
    /// Trailing TEP-89 include-address flag.
    includeAddress: bool
}

/// Standard jetton notification accepted only from the discovered jetton wallet.
struct (0x7362d09c) StormPrelaunchJettonNotify {
    /// Query id copied into outgoing jetton refunds.
    queryId: uint64
    /// Jetton amount reported by the wallet.
    amount: coins
    /// User address credited or refunded by the prelaunch logic.
    senderAddress: address
    /// Raw forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin replacement of the full participants dictionary.
struct (0x9f2a689a) StormPrelaunchSetParticipants {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// Replacement participant dictionary.
    participants: map<uint256, StormPrelaunchParticipant>
}

/// Admin update of the reward notifier address.
struct (0xc8e7996d) StormPrelaunchSetRewardNotifier {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// New reward notifier address.
    rewardNotifierAddress: address
}

/// Admin code upgrade message.
struct (0x9c0f3220) StormPrelaunchChangeCode {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// Replacement code cell passed directly to `set_code`.
    code: cell
}

/// Admin raw data replacement message.
struct (0x46e9f1db) StormPrelaunchChangeData {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// Replacement data cell passed directly to `set_data`.
    data: cell
}

/// Admin update of the prelaunch end timestamp.
struct (0x1de16731) StormPrelaunchSetEndTime {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// New end timestamp stored as Unix seconds.
    endTime: uint32
}

/// Admin jetton withdrawal request.
struct (0xbde0d471) StormPrelaunchWithdrawJettons {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
    /// Jetton amount transferred from the contract wallet to the admin address.
    amount: coins
}

/// Admin request to send the terminal reward-notifier body.
struct (0x7079c145) StormPrelaunchNotifyRewardsComplete {
    /// Query id parsed and otherwise ignored by the live code.
    queryId: uint64
}

/// Standard jetton transfer body emitted for accepted deposits and refunds.
struct (0x0f8a7ea5) StormPrelaunchJettonTransfer {
    /// Query id copied from the incoming jetton notification or set to zero by admin withdrawal.
    queryId: uint64
    /// Jetton amount to transfer.
    amount: coins
    /// Jetton transfer destination address.
    destination: address
    /// Response destination address.
    responseDestination: address
    /// Optional custom payload; live send sites use null.
    customPayload: cell?
    /// TON amount forwarded with the jetton transfer.
    forwardTonAmount: coins
    /// Raw forward payload copied or built by the live code.
    forwardPayload: RemainingBitsAndRefs
}

/// Reward-count update emitted to the configured reward notifier.
struct (0x00000002) StormPrelaunchRewardCountsNotify {
    /// Query id set to zero by the live code.
    queryId: uint64
    /// Participant address whose counters changed.
    participantAddress: address
    /// Second participant reward counter delta.
    rewardCountBDelta: uint32
    /// First participant reward counter delta.
    rewardCountADelta: uint32
}

/// Terminal reward-notifier body emitted by the admin completion branch.
struct (0x00000003) StormPrelaunchRewardsCompleteNotify {
    /// Query id set to zero by the live code.
    queryId: uint64
    /// Opaque payload slice built from a contract constant.
    payload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the Prelaunch contract.
type StormPrelaunchIncomingMessage =
    | StormPrelaunchTakeWalletAddress
    | StormPrelaunchJettonNotify
    | StormPrelaunchSetParticipants
    | StormPrelaunchSetRewardNotifier
    | StormPrelaunchChangeCode
    | StormPrelaunchChangeData
    | StormPrelaunchSetEndTime
    | StormPrelaunchWithdrawJettons
    | StormPrelaunchNotifyRewardsComplete

/// Internal message bodies emitted by the Prelaunch contract.
type StormPrelaunchOutgoingMessage =
    | StormPrelaunchProvideWalletAddress
    | StormPrelaunchJettonTransfer
    | StormPrelaunchRewardCountsNotify
    | StormPrelaunchRewardsCompleteNotify

/// Structured result returned by live `get_storage_data` method id 110721.
struct StormPrelaunchStorageDataReply {
    /// Participant dictionary.
    participants: map<uint256, StormPrelaunchParticipant>
    /// Admin address.
    adminAddress: address
    /// Deposit window start timestamp.
    startTime: uint32
    /// Deposit window end timestamp.
    endTime: uint32
    /// Wallet discovery flag returned as a stack boolean integer.
    walletDiscovered: bool
    /// Jetton wallet address after discovery.
    jettonWalletAddress: address
    /// Reward notifier address.
    rewardNotifierAddress: address
}

/// Structured result returned by live raw method id 104966 for one participant address.
struct StormPrelaunchUserRewardCountsReply {
    /// First reward counter for the requested participant address.
    rewardCountA: uint32
    /// Second reward counter for the requested participant address.
    rewardCountB: uint32
}

/// Prelaunch exit-code catalog.
enum StormPrelaunchErrors {
    /// Sender workchain is not basechain.
    WrongWorkchain = 333
    /// Admin-only message was not sent by the stored admin address.
    NotAdmin = 50
    /// Wallet discovery reply was not sent by the current discovery target.
    WrongWalletDiscoverySender = 52
    /// SDK constant for an already configured start timestamp.
    StartAlreadySet = 438
    /// SDK constant for an already configured end timestamp.
    EndAlreadySet = 439
    /// SDK constant for a request before the start timestamp.
    NotStarted = 440
    /// SDK constant for a request after the end timestamp.
    Ended = 441
    /// SDK constant for an invalid start timestamp.
    WrongStartDate = 442
    /// SDK constant for an invalid end timestamp.
    WrongEndDate = 443
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return the full Prelaunch storage tuple.
get fun get_storage_data(): StormPrelaunchStorageDataReply {
    throw 0;
}

/// Synthetic ABI name whose CRC selector is live raw method id 104966.
get fun get_method_104966_jsxb(userAddress: address): StormPrelaunchUserRewardCountsReply {
    throw 0;
}
