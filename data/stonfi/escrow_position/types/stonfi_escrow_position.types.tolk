/// STON.fi escrow order position with bilateral unlock and cron-triggered settlement.
contract StonfiEscrowPosition {
    author: "STON.fi"
    description: "STON.fi Escrow Position holds one order, validates lock and unlock requests, and settles the position through its minter."
    storage: StonfiEscrowPositionStorage
    incomingMessages: StonfiEscrowPositionIncomingMessage
    incomingExternal: StonfiEscrowPositionIncomingExternalMessage
    outgoingMessages: StonfiEscrowPositionOutgoingMessage
    forceAbiExport: StonfiEscrowPositionForwardParams
        | StonfiEscrowPositionLockForwardParams
        | StonfiEscrowPositionBilateralLockArgs
        | StonfiEscrowPositionBilateralUnlockArgs
        | StonfiEscrowPositionWithdrawSignMessage
        | StonfiEscrowPositionGetCronInfoReply
        | StonfiEscrowPositionGetOrderDataReply
    thrownErrors: StonfiEscrowPositionErrors
}

/// Complete persistent state of an initialized escrow position.
struct StonfiEscrowPositionStorage {
    /// Lifecycle state of the order.
    status: uint8
    /// Quote identifier assigned by the escrow minter.
    quoteId: uint256
    /// Escrow minter authorized to drive internal state transitions.
    minter: address
    /// Jetton wallet holding the bid asset for this position.
    bidJettonWallet: address
    /// Bid asset amount still held by the position.
    bidJettonAmount: coins
    /// Order owner, fee, ask-asset, and settlement parameters.
    order: Cell<StonfiEscrowPositionOrder>
    /// Mutable state consumed by the unlock-condition program.
    conditionState: cell
    /// Executable unlock-condition program.
    conditionCode: cell
    /// Optional forward value and success payload used after a user unlock.
    userUnlockForward: Cell<StonfiEscrowPositionStoredForward>?
}

/// Order parameters stored in the first referenced state cell.
struct StonfiEscrowPositionOrder {
    /// User that supplied the bid asset.
    bidFromUser: address
    /// Account that receives the referral fee.
    refFee: address
    /// Minter of the ask-side Jetton.
    askJettonMinter: address
    /// Referral fee tier in protocol basis units.
    refFeeTier: uint16
    /// Internal accumulated amount maintained during partial settlement.
    accumulatedAmount: coins
    /// Whether the user's fill is delivered through an escrow vault.
    userFillToVault: bool
    /// Ask wallet, authorization, pending amount, and forwarding values.
    details: Cell<StonfiEscrowPositionOrderDetails>
}

/// Order fields stored in the nested details cell.
struct StonfiEscrowPositionOrderDetails {
    /// Jetton wallet from which the ask asset is received.
    askJettonWallet: address
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
    /// Ask asset amount pending delivery to the user.
    pendingUserReceiveAmount: coins
    /// TON value reserved for safe deposit and forwarding.
    safeDepositAndForwardValue: uint64
    /// Account that receives excess TON after settlement.
    excessesReceiver: address
}

/// Optional user-unlock forwarding state stored at the root tail.
struct StonfiEscrowPositionStoredForward {
    /// TON value attached to the success forward.
    value: coins
    /// Optional body forwarded after successful settlement.
    successPayload: cell?
}

/// TON value and success/rejection bodies forwarded by an escrow action.
struct StonfiEscrowPositionForwardParams {
    /// TON value attached to the forwarded message.
    value: coins
    /// Optional body used when the action succeeds.
    successPayload: cell?
    /// Optional body used when the action is rejected.
    rejectPayload: cell?
}

/// Optional destination and forwarding parameters used after a lock.
struct StonfiEscrowPositionLockForwardParams {
    /// Destination of the lock result notification.
    destination: address?
    /// Value and payloads for the result notification.
    forwardParams: StonfiEscrowPositionForwardParams
}

/// Packed Dutch-auction segments interpreted by the unlock condition.
struct StonfiEscrowPositionDutchSegments {
    /// Number of encoded segments.
    count: uint4
    /// Packed segment data retained for the condition program.
    segments: RemainingBitsAndRefs
}

/// Condition arguments supplied when the escrow position is locked.
struct StonfiEscrowPositionBilateralLockArgs {
    /// Optional resolver allowed to satisfy the bilateral condition.
    resolver: address?
    /// Resolver timeout measured from the lock time.
    resolverTimeoutDelta: uint64
    /// Ask amount expected from the resolver.
    resolverAskAmount: coins
    /// Optional resolver Ed25519 public key.
    resolverPublicKey: uint256?
    /// Dutch-auction segments used by the condition program.
    dutchSegments: Cell<StonfiEscrowPositionDutchSegments>
}

/// Resolver authorization data signed for an unlock.
struct StonfiEscrowPositionBilateralSignedMessage {
    /// Unix timestamp after which the authorization is invalid.
    expirationTime: uint64
    /// Resolver authorized by the signature.
    resolver: address?
}

/// Signature and referenced resolver authorization.
struct StonfiEscrowPositionBilateralSignPayload {
    /// Ed25519 signature over the referenced authorization cell.
    signature: bits512
    /// Resolver authorization covered by the signature.
    message: Cell<StonfiEscrowPositionBilateralSignedMessage>
}

/// Bilateral-condition arguments supplied during an unlock.
struct StonfiEscrowPositionBilateralUnlockArgs {
    /// Minimum amount the user accepts from the unlock.
    minOut: coins
    /// Refund amount the condition may ignore.
    ignoreRefundAmount: coins
    /// Optional signed resolver authorization.
    signed: StonfiEscrowPositionBilateralSignPayload?
}

/// Additional addresses stored in the referenced lock metadata cell.
struct StonfiEscrowPositionLockMetadataMore {
    /// Minter of the ask-side Jetton.
    askJettonMinter: address?
    /// User that owns the order.
    orderOwner: address?
    /// Account that receives rejected or unused assets.
    refundTo: address?
}

/// Position parameters supplied by the escrow minter during a lock.
struct StonfiEscrowPositionLockMetadata {
    /// Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis units.
    refFeeTier: uint16
    /// TON value reserved for safe deposit and forwarding.
    safeDepositAndForwardValue: coins
    /// Whether the user's fill is delivered through an escrow vault.
    userFillToVault: bool
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
    /// Referenced ask-minter, owner, and refund addresses.
    more: Cell<StonfiEscrowPositionLockMetadataMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowPositionForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowPositionLockForwardParams>?
}

/// Recipient addresses supplied with an internal unlock.
struct StonfiEscrowPositionUnlockExtraFields {
    /// Account that receives the unlocked bid asset.
    recipient: address?
    /// Account that receives refunded ask assets.
    refundTo: address?
    /// Account that receives excess TON.
    excesses: address?
}

/// Payload covered by an externally submitted withdrawal signature.
struct StonfiEscrowPositionExternalWithdrawPayload {
    /// Escrow position to which the signature is bound.
    escrowItem: address?
    /// Maximum signature age in seconds.
    signatureTtl: uint64
    /// Condition-specific withdrawal arguments.
    withdrawArgs: cell
}

/// Domain-separated message signed by the position owner.
struct (0x75569022) StonfiEscrowPositionWithdrawSignMessage {
    /// Schema identifier included in the signed data.
    schemaHash: uint32
    /// Unix timestamp at which the signature was produced.
    timestamp: uint64
    /// Wallet whose key authorizes the withdrawal.
    userWalletAddress: address?
    /// Referenced signing-domain cell.
    domain: cell
    /// Referenced position, TTL, and withdrawal arguments.
    payload: Cell<StonfiEscrowPositionExternalWithdrawPayload>
}

/// Lock an empty position with bid assets and a bilateral condition.
struct (0x7ab06181) StonfiEscrowPositionInternalLock {
    /// Correlation identifier copied to result messages.
    queryId: uint64
    /// Bid-side Jetton wallet assigned to the position.
    tokenAddress: address?
    /// Bid asset amount deposited into the position.
    amount: coins
    /// Account that receives excess TON.
    excesses: address?
    /// Whether rejected bid assets are refunded through a vault.
    refundToVault: bool
    /// Referenced order and forwarding metadata.
    additionalField: Cell<StonfiEscrowPositionLockMetadata>
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowPositionBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
}

/// Apply an ask-side fill and unlock all or part of a position.
struct (0x696fa2d8) StonfiEscrowPositionInternalUnlock {
    /// Correlation identifier copied to settlement messages.
    queryId: uint64
    /// Whether the user's fill is delivered through a vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a vault.
    refundToVault: bool
    /// Resolver responsible for the ask-side fill.
    resolver: address?
    /// Resolver Jetton wallet that supplied the ask asset.
    resolverSentJettonWallet: address?
    /// Ask asset amount supplied by the resolver.
    resolverSentAmount: coins
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowPositionBilateralUnlockArgs>
    /// Referenced recipient, refund, and excess addresses.
    extraFields: Cell<StonfiEscrowPositionUnlockExtraFields>
    /// Optional post-unlock forwarding parameters.
    forwardParams: Cell<StonfiEscrowPositionForwardParams>?
}

/// Withdraw a position through an internal message from the escrow minter.
struct (0x12b8a987) StonfiEscrowPositionWithdraw {
    /// Correlation identifier copied to settlement messages.
    queryId: uint64
    /// Condition-specific withdrawal arguments.
    withdrawArgs: cell
    /// Account that receives excess TON.
    excesses: address?
    /// Optional post-withdraw forwarding parameters.
    forwardParams: Cell<StonfiEscrowPositionForwardParams>?
}

/// Withdraw a position with an Ed25519 authorization submitted externally.
struct (0x8af982e1) StonfiEscrowPositionExternalWithdraw {
    /// Correlation identifier copied to settlement messages.
    queryId: uint64
    /// Ed25519 signature over `signMessage`.
    signature: bits512
    /// Domain-separated withdrawal authorization.
    signMessage: Cell<StonfiEscrowPositionWithdrawSignMessage>
}

/// Ask the cron-compatible condition program to settle an eligible position.
struct (0x2114702d) StonfiEscrowPositionCronTrigger {
    /// Account that receives the trigger reward.
    rewardAddress: address?
    /// Caller-selected anti-replay or randomization salt.
    salt: uint32
}

/// Notify the configured lock-forward destination that the position was locked.
struct (0x14b8bb09) StonfiEscrowPositionLockSuccess {
    /// Correlation identifier copied from the lock request.
    queryId: uint64
    /// Optional success body configured by the lock request.
    forwardPayload: cell?
}

/// Internal bodies accepted by the escrow position.
type StonfiEscrowPositionIncomingMessage =
    | StonfiEscrowPositionInternalLock
    | StonfiEscrowPositionInternalUnlock
    | StonfiEscrowPositionWithdraw

/// External bodies accepted by the escrow position.
type StonfiEscrowPositionIncomingExternalMessage =
    | StonfiEscrowPositionExternalWithdraw
    | StonfiEscrowPositionCronTrigger

/// Contract-specific result body emitted after a successful lock.
type StonfiEscrowPositionOutgoingMessage = StonfiEscrowPositionLockSuccess

/// Structured result returned by `get_cron_info`.
struct StonfiEscrowPositionGetCronInfoReply {
    /// Next planned condition evaluation time.
    nextCallTime: uint32
    /// Reward paid to the cron trigger caller.
    reward: coins
    /// Contract balance after subtracting reserved amounts.
    balanceMinusAmounts: int64
    /// Repeat interval in seconds.
    repeatEvery: uint32
}

/// Current order state returned by `getOrderData`.
struct StonfiEscrowPositionGetOrderDataReply {
    /// Lifecycle state of the order.
    status: uint8
    /// Quote identifier assigned by the escrow minter.
    quoteId: int
    /// Escrow minter authorized to drive internal state transitions.
    minter: address
    /// Jetton wallet holding the bid asset for this position.
    bidJettonWallet: address
    /// Bid asset amount still held by the position.
    bidJettonAmount: coins
    /// User that supplied the bid asset.
    bidFromUser: address
    /// Account that receives the referral fee.
    refFee: address
    /// Referral fee tier in protocol basis units.
    refFeeTier: uint16
    /// Ask asset amount pending delivery to the user.
    pendingUserReceiveAmount: coins
    /// Jetton wallet from which the ask asset is received.
    askJettonWallet: address
    /// Minter of the ask-side Jetton.
    askJettonMinter: address
    /// Mutable state consumed by the unlock-condition program.
    conditionState: cell
    /// Executable unlock-condition program.
    conditionCode: cell
    /// Optional TON value forwarded after a user unlock.
    userUnlockForwardParams: coins?
    /// Optional success body forwarded after a user unlock.
    userUnlockForwardSuccessPayload: cell?
    /// Whether the user's fill is delivered through an escrow vault.
    userFillToVault: bool
    /// TON value reserved for safe deposit and forwarding.
    safeDepositAndForwardValue: uint64
    /// Account that receives excess TON after settlement.
    excessesReceiver: address
}

/// Return cron scheduling metadata from the embedded condition program.
get fun get_cron_info(): StonfiEscrowPositionGetCronInfoReply {
    throw 0;
}

/// Return the current escrow order and settlement parameters.
get fun getOrderData(): StonfiEscrowPositionGetOrderDataReply {
    throw 0;
}

/// Exit codes exposed by the escrow position runtime.
enum StonfiEscrowPositionErrors {
    /// A signed withdrawal cell has an unexpected schema opcode.
    InvalidSignedPayload = 63
    /// An internal message was sent from an unauthorized account.
    InvalidCaller = 32950
    /// An internal sender belongs to an unsupported workchain.
    WrongWorkchain = 33533
    /// The account balance or inbound value cannot cover settlement gas.
    InsufficientGas = 33565
    /// A supplied asset amount is invalid for the requested transition.
    InvalidAmount = 34643
    /// The stored owner public key is absent for an external withdrawal.
    MissingOwnerPublicKey = 34652
    /// A signed withdrawal authorization has expired.
    SignatureExpired = 34653
    /// The external withdrawal signature is invalid.
    InvalidSignature = 34654
    /// The signed payload targets a different escrow position.
    WrongEscrowPosition = 34655
    /// The resolver address does not match the locked condition.
    WrongResolver = 34657
    /// The requested operation is not valid in the current lifecycle state.
    WrongStatus = 46254
}
