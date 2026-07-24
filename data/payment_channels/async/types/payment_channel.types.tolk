/// TON Foundation asynchronous two-party payment channel.
contract AsyncPaymentChannel {
    author: "TON Foundation"
    version: "1.0"
    description: "Asynchronous two-party TON payment channel with cooperative commitment and closure, challenged uncooperative closure, and conditional settlement."
    storage: AsyncPaymentChannelStorage
    incomingMessages: AsyncPaymentChannelIncomingMessage
    incomingExternal: AsyncPaymentChannelIncomingExternalMessage
    outgoingMessages: AsyncPaymentChannelOutgoingMessage
    forceAbiExport: AsyncPaymentChannelDataReply
    thrownErrors: AsyncPaymentChannelErrors
}

/// Complete persistent data root for an asynchronous payment channel.
struct AsyncPaymentChannelStorage {
    /// Whether the current channel session was initialized.
    inited: bool
    /// TON balance assigned to party A.
    balanceA: coins
    /// TON balance assigned to party B.
    balanceB: coins
    /// Ed25519 public key of party A.
    keyA: uint256
    /// Ed25519 public key of party B.
    keyB: uint256
    /// Per-deployment channel identifier signed by both parties.
    channelId: uint128
    /// Timing and penalty configuration.
    closingConfig: Cell<AsyncPaymentChannelClosingConfig>
    /// Latest jointly committed sequence number for party A.
    committedSeqnoA: uint32
    /// Latest jointly committed sequence number for party B.
    committedSeqnoB: uint32
    /// Optional state held during an uncooperative close.
    quarantine: Cell<AsyncPaymentChannelQuarantinedState>?
    /// Payout destinations and retained fee configuration.
    paymentConfig: Cell<AsyncPaymentChannelPaymentConfig>
}

/// Timing and penalty values fixed for the deployment.
struct AsyncPaymentChannelClosingConfig {
    /// Grace period in seconds during which the proposed state can be challenged.
    quarantineDuration: uint32
    /// TON penalty added to the cheater's sent amount after a successful challenge.
    misbehaviorFine: coins
    /// Additional period in seconds allowed for conditional settlement.
    conditionalCloseDuration: uint32
}

/// Payout configuration fixed for the deployment.
@overflow1023_policy("suppress")
struct AsyncPaymentChannelPaymentConfig {
    /// TON fee retained from channel funding calculations.
    excessFee: coins
    /// Party A payout destination encoded as a complete `MsgAddress`.
    destinationA: any_address
    /// Party B payout destination encoded as a complete `MsgAddress`.
    destinationB: any_address
}

/// Conditional transfer stored in a semi-channel dictionary.
struct AsyncPaymentChannelConditionalPayment {
    /// TON amount released when `condition` accepts the submitted input.
    amount: coins
    /// Executable condition cell mutually authorized by both parties.
    condition: cell
}

/// One party's monotonically sequenced off-chain state.
struct AsyncPaymentChannelSemiChannelBody {
    /// Sequence number of this semi-channel state.
    seqno: uint64
    /// Cumulative amount sent by this party.
    sent: coins
    /// Conditional payments keyed by a 32-bit conditional id.
    conditionals: map<uint32, AsyncPaymentChannelConditionalPayment>
}

/// Signed-state payload identified by the fixed `0x43685374` state tag.
struct (0x43685374) AsyncPaymentChannelSemiChannel {
    /// Channel identifier that prevents cross-channel replay.
    channelId: uint128
    /// Current party state.
    data: AsyncPaymentChannelSemiChannelBody
    /// Optional latest state that this party has received from the counterparty.
    counterpartyData: Cell<AsyncPaymentChannelSemiChannelBody>?
}

/// Ed25519 signature followed inline by a semi-channel state.
struct AsyncPaymentChannelSignedSemiChannel {
    /// Signature over the following semi-channel cell remainder.
    signature: bits512
    /// Signed semi-channel state.
    state: AsyncPaymentChannelSemiChannel
}

/// State retained while an uncooperative closure is pending.
struct AsyncPaymentChannelQuarantinedState {
    /// Party A semi-channel state selected for final settlement.
    stateA: AsyncPaymentChannelSemiChannelBody
    /// Party B semi-channel state selected for final settlement.
    stateB: AsyncPaymentChannelSemiChannelBody
    /// Unix timestamp at which quarantine started.
    quarantineStartedAt: uint32
    /// Party that submitted the currently retained state.
    stateCommittedByA: bool
    /// Optional challenged bit in initial/challenged states; absent after `settle_conditionals`.
    compatibilityTail: RemainingBitsAndRefs
}

/// Add TON funding attributed to each side before initialization.
struct (0x67c7d281) AsyncPaymentChannelTopUpBalance {
    /// Amount added to party A's assigned balance.
    addA: coins
    /// Amount added to party B's assigned balance.
    addB: coins
}

/// Initialize the channel after the caller funds its assigned side.
struct (0x0e0620c2) AsyncPaymentChannelInit {
    /// True when the initializer is party A, false for party B.
    isA: bool
    /// Initializer signature over all fields that follow it.
    signature: bits512
    /// Fixed signed-domain tag `0x696e6974` (`init`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// Expected funded balance of party A.
    balanceA: coins
    /// Expected funded balance of party B.
    balanceB: coins
}

/// Close immediately using a final state authorized by both parties.
struct (0x5577587e) AsyncPaymentChannelCooperativeClose {
    /// Party A signature cell over all fields following both references.
    signatureA: Cell<bits512>
    /// Party B signature cell over all fields following both references.
    signatureB: Cell<bits512>
    /// Fixed signed-domain tag `0x436c6f73` (`Clos`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// Final payout balance for party A.
    balanceA: coins
    /// Final payout balance for party B.
    balanceB: coins
    /// New committed sequence number for party A.
    seqnoA: uint64
    /// New committed sequence number for party B.
    seqnoB: uint64
}

/// Commit sequence numbers jointly authorized by both parties.
struct (0x79a126ef) AsyncPaymentChannelCooperativeCommit {
    /// Party A signature cell over all fields following both references.
    signatureA: Cell<bits512>
    /// Party B signature cell over all fields following both references.
    signatureB: Cell<bits512>
    /// Fixed signed-domain tag `0x43436d74` (`CCmt`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// New committed sequence number for party A.
    seqnoA: uint64
    /// New committed sequence number for party B.
    seqnoB: uint64
}

/// Start uncooperative closure using the latest signed states known to one party.
struct (0x1f151acf) AsyncPaymentChannelStartUncooperativeClose {
    /// True when the root request was signed by party A.
    signedByA: bool
    /// Root signature over all request fields that follow it.
    signature: bits512
    /// Fixed signed-domain tag `0x556e436c` (`UnCl`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// Party A signed semi-channel state.
    semiChannelA: Cell<AsyncPaymentChannelSignedSemiChannel>
    /// Party B signed semi-channel state.
    semiChannelB: Cell<AsyncPaymentChannelSignedSemiChannel>
}

/// Challenge a quarantined closure state with fresher signed semi-channel states.
struct (0x088eaa32) AsyncPaymentChannelChallengeQuarantinedState {
    /// True when the challenge was signed by party A.
    challengedByA: bool
    /// Root signature over all request fields that follow it.
    signature: bits512
    /// Fixed signed-domain tag `0x43686751` (`ChgQ`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// Party A signed semi-channel state.
    semiChannelA: Cell<AsyncPaymentChannelSignedSemiChannel>
    /// Party B signed semi-channel state.
    semiChannelB: Cell<AsyncPaymentChannelSignedSemiChannel>
}

/// Submit inputs for conditional transfers after the quarantine grace period.
struct (0x66f6f069) AsyncPaymentChannelSettleConditionals {
    /// True when party A is settling party B's conditionals.
    fromA: bool
    /// Root signature over all request fields that follow it.
    signature: bits512
    /// Fixed signed-domain tag `0x436c436e` (`ClCn`).
    tag: uint32
    /// Expected channel identifier.
    channelId: uint128
    /// `HashmapE 32 Cell` of arbitrary input slices keyed by conditional id.
    conditionalsToSettle: dict
}

/// Finish an uncooperative closure after all grace periods expire.
struct (0x25432a91) AsyncPaymentChannelFinishUncooperativeClose {}

/// Payout notification emitted to each party when a channel closes.
struct (0xdddc88ba) AsyncPaymentChannelClosed {
    /// Identifier of the channel that closed.
    channelId: uint128
}

/// Internal bodies accepted by the payment channel.
type AsyncPaymentChannelIncomingMessage =
    | AsyncPaymentChannelTopUpBalance
    | AsyncPaymentChannelInit
    | AsyncPaymentChannelCooperativeClose
    | AsyncPaymentChannelCooperativeCommit
    | AsyncPaymentChannelStartUncooperativeClose
    | AsyncPaymentChannelChallengeQuarantinedState
    | AsyncPaymentChannelSettleConditionals
    | AsyncPaymentChannelFinishUncooperativeClose

/// External bodies accepted after both-party signature authorization.
type AsyncPaymentChannelIncomingExternalMessage =
    | AsyncPaymentChannelCooperativeClose
    | AsyncPaymentChannelCooperativeCommit

/// Internal bodies emitted by the contract.
type AsyncPaymentChannelOutgoingMessage = AsyncPaymentChannelClosed

/// Pair of current party balances returned by `get_channel_data`.
struct AsyncPaymentChannelBalances {
    /// Current assigned balance of party A.
    a: int
    /// Current assigned balance of party B.
    b: int
}

/// Pair of Ed25519 public keys returned by `get_channel_data`.
struct AsyncPaymentChannelKeys {
    /// Party A public key.
    a: uint256
    /// Party B public key.
    b: uint256
}

/// Closing configuration returned by `get_channel_data`.
struct AsyncPaymentChannelClosingConfigReply {
    /// Quarantine duration in seconds.
    quarantineDuration: uint32
    /// Misbehavior fine in nanotons.
    misbehaviorFine: int
    /// Conditional settlement duration in seconds.
    conditionalCloseDuration: uint32
}

/// Pair of committed sequence numbers returned by `get_channel_data`.
struct AsyncPaymentChannelCommittedSeqnos {
    /// Party A committed sequence number.
    a: uint32
    /// Party B committed sequence number.
    b: uint32
}

/// Payment configuration returned by `get_channel_data`.
struct AsyncPaymentChannelPaymentConfigReply {
    /// Retained fee in nanotons.
    excessFee: int
    /// Party A payout `MsgAddress` returned as a stack slice.
    destinationA: slice
    /// Party B payout `MsgAddress` returned as a stack slice.
    destinationB: slice
}

/// Named shape of the eight values returned by `get_channel_data`.
struct AsyncPaymentChannelDataReply {
    /// Lifecycle state: 0 uninitialized, 1 open, 2 quarantined, 3 settling, 4 finalizable.
    state: int
    /// Current party balances.
    balances: AsyncPaymentChannelBalances
    /// Party public keys.
    keys: AsyncPaymentChannelKeys
    /// Channel identifier.
    channelId: uint128
    /// Closing configuration.
    closingConfig: AsyncPaymentChannelClosingConfigReply
    /// Latest committed sequence numbers.
    committedSeqnos: AsyncPaymentChannelCommittedSeqnos
    /// Raw quarantined state stack value, or null outside uncooperative closure.
    quarantine: cell?
    /// Payout configuration.
    paymentConfig: AsyncPaymentChannelPaymentConfigReply
}

/// Payment-channel exit codes.
enum AsyncPaymentChannelErrors {
    /// Initialization was attempted after the channel was already initialized.
    AlreadyInitialized = 100
    /// A signature or sender-side authorization check failed.
    NotAuthorized = 101
    /// The contract balance is below the balances requested by initialization.
    NotEnoughMoneyForInitialization = 102
    /// A signed-domain tag or semi-channel state tag is invalid.
    WrongTag = 104
    /// Proposed signed state is older or contradicts the retained state.
    OutdatedState = 105
    /// An uncooperative closure is already active.
    QuarantineAlreadyActive = 106
    /// A quarantine-dependent operation was requested without quarantined state.
    NoQuarantinedState = 107
    /// Cooperative sequence numbers did not strictly increase.
    SequenceNumberRegressed = 108
    /// The party challenging a state is not the previous committer's counterparty.
    UnauthorizedChallenge = 109
    /// Conditional settlement was attempted before quarantine expired.
    QuarantineNotFinished = 110
    /// A challenge arrived after the quarantine challenge window.
    TooLateForQuarantineChallenge = 111
    /// Conditional inputs arrived after the conditional settlement window.
    TooLateToSettleConditionals = 112
    /// Finalization was attempted before both closure periods expired.
    TooEarlyToClose = 113
    /// A request or signed semi-channel carries a different channel identifier.
    WrongChannelId = 114
    /// The quarantined state was already challenged once.
    QuarantineAlreadyChallenged = 115
    /// Incoming message opcode is unsupported by the common dispatcher.
    UnknownOperation = 65535
}

/// Return the current lifecycle state.
get fun get_channel_state(): int {
    throw 0;
}

/// Return an eight-item tuple containing lifecycle state, balances, keys, channel id,
/// closing configuration, committed sequence numbers, quarantine, and payment configuration.
/// Tuple item 6 is TVM `null` outside closure and the quarantine cell during closure.
get fun get_channel_data(): tuple {
    throw 0;
}
