/// STON.fi Escrow Factory that creates deterministic positions and vaults and routes escrow assets.
contract StonfiEscrowFactory {
    author: "STON.fi"
    description: "STON.fi Escrow Factory derives Position and Vault accounts, routes locks, unlocks, deposits, refunds, and protocol administration."
    storage: StonfiEscrowFactoryStorage
    incomingMessages: StonfiEscrowFactoryIncomingMessage
    outgoingMessages: StonfiEscrowFactoryOutgoingMessage
    forceAbiExport: StonfiEscrowFactoryLockPayload
        | StonfiEscrowFactoryUnlockPayload
        | StonfiEscrowFactoryDepositVaultPayload
        | StonfiEscrowFactoryForwardParams
        | StonfiEscrowFactoryLockForwardParams
        | StonfiEscrowFactoryBilateralLockArgs
        | StonfiEscrowFactoryBilateralUnlockArgs
        | StonfiEscrowFactoryEscrowData
        | StonfiEscrowFactoryVersion
    thrownErrors: StonfiEscrowFactoryErrors
}

/// Complete persistent state of the initialized Escrow Factory.
struct StonfiEscrowFactoryStorage {
    /// Global protocol identifier included in derived contract state.
    globalId: uint64
    /// Protocol account authorized to administer the Factory.
    protocol: address
    /// Pending protocol owner, or none when no ownership transfer is active.
    nextProtocol: address?
    /// Protocol fee tier in basis points.
    protocolTier: uint16
    /// Code installed into deterministic Escrow Position accounts.
    itemCode: cell
    /// Code installed into deterministic Escrow Vault accounts.
    vaultCode: cell
}

/// GRAM value and success/rejection bodies forwarded by an escrow action.
struct StonfiEscrowFactoryForwardParams {
    /// GRAM value attached to the forwarded message.
    value: coins
    /// Optional body used when the action succeeds.
    successPayload: cell?
    /// Optional body used when the action is rejected.
    rejectPayload: cell?
}

/// Optional destination and forwarding parameters used after a lock.
struct StonfiEscrowFactoryLockForwardParams {
    /// Destination of the lock result notification.
    destination: address?
    /// Value and payloads for the result notification.
    forwardParams: StonfiEscrowFactoryForwardParams
}

/// Packed Dutch-auction segments interpreted by the unlock condition.
struct StonfiEscrowFactoryDutchSegments {
    /// Number of encoded segments.
    count: uint4
    /// Packed segment data retained for the condition program.
    segments: RemainingBitsAndRefs
}

/// Condition arguments supplied when a position is locked.
struct StonfiEscrowFactoryBilateralLockArgs {
    /// Optional resolver allowed to satisfy the bilateral condition.
    resolver: address?
    /// Resolver timeout measured from the lock time.
    resolverTimeoutDelta: uint64
    /// Ask amount expected from the resolver.
    resolverAskAmount: coins
    /// Optional resolver Ed25519 public key.
    resolverPublicKey: uint256?
    /// Dutch-auction segments used by the condition program.
    dutchSegments: Cell<StonfiEscrowFactoryDutchSegments>
}

/// Resolver authorization data signed for an unlock.
struct StonfiEscrowFactoryBilateralSignedMessage {
    /// Unix timestamp after which the authorization is invalid.
    expirationTime: uint64
    /// Resolver authorized by the signature.
    resolver: address?
}

/// Signature and referenced resolver authorization.
struct StonfiEscrowFactoryBilateralSignPayload {
    /// Ed25519 signature over the referenced authorization cell.
    signature: bits512
    /// Resolver authorization covered by the signature.
    message: Cell<StonfiEscrowFactoryBilateralSignedMessage>
}

/// Bilateral-condition arguments supplied during an unlock.
struct StonfiEscrowFactoryBilateralUnlockArgs {
    /// Minimum amount the user accepts from the unlock.
    minOut: coins
    /// Refund amount the condition may ignore.
    ignoreRefundAmount: coins
    /// Optional signed resolver authorization.
    signed: StonfiEscrowFactoryBilateralSignPayload?
}

/// Bid-side payment information supplied by an escrow participant.
struct StonfiEscrowFactoryBidPaymentData {
    /// Whether the bid asset is sourced from an Escrow Vault.
    usingVault: bool
    /// Optional recipient of the bid-side settlement.
    recipient: address?
    /// Optional bid-side Jetton wallet.
    bidJettonWallet: address?
    /// Bid asset amount in basic token units.
    amount: coins
    /// Optional forwarding parameters for the bid-side payment.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// Ask-side refund information supplied during transfer initialization.
struct StonfiEscrowFactoryAskRefundData {
    /// Optional account that receives refunded ask assets.
    refundTo: address?
    /// Whether the refund is routed through an Escrow Vault.
    usingVault: bool
    /// Ask asset amount to refund in basic token units.
    amount: coins
}

/// User settlement information supplied during transfer initialization.
struct StonfiEscrowFactoryUserPaymentData {
    /// Optional user associated with the settlement.
    user: address?
    /// Optional Jetton wallet that receives the user's ask asset.
    userReceiveJettonWallet: address?
    /// Ask asset amount delivered to the user.
    userReceiveAmount: coins
    /// Whether the user deposit is routed through an Escrow Vault.
    userDepositViaVault: bool
    /// Optional forwarding parameters for the user payment.
    userForwardParams: Cell<StonfiEscrowFactoryForwardParams>?
    /// Optional account that receives excess GRAM.
    userExcesses: address?
    /// GRAM value reserved for safe deposit and forwarding.
    userSafeDepositAndForwardValue: uint64
}

/// Additional routing information referenced by a refund request.
@overflow1023_policy("suppress")
struct StonfiEscrowFactoryRefundRequestExtraFields {
    /// Optional Jetton wallet from which assets are refunded.
    jettonWallet: address?
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Nanograms forwarded with a Jetton transfer notification.
    forwardTonAmount: coins
    /// Optional Jetton forward payload.
    forwardPayload: cell?
    /// Optional destination of a lock rejection notification.
    lockRejectDestination: any_address?
}

/// Owner, refund, and ask-minter addresses shared by lock metadata.
struct StonfiEscrowFactoryLockMetadataMore {
    /// Optional user that owns the escrow order.
    orderOwner: address?
    /// Optional account that receives rejected or unused assets.
    refundTo: address?
    /// Optional minter of the ask-side Jetton.
    askJettonMinter: address?
}

/// Ask-wallet and owner-key fields nested in an internal lock request.
struct StonfiEscrowFactoryInternalLockNested {
    /// Optional Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
}

/// Position metadata referenced by a direct internal lock request.
struct StonfiEscrowFactoryInternalLockExtra {
    /// Quote identifier assigned to the derived position.
    quoteId: uint256
    /// Optional account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis points.
    refFeeTier: uint16
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// GRAM value reserved for safe deposit and forwarding.
    safeDepositAndForwardValue: coins
    /// Whether rejected bid assets are refunded through a Vault.
    refundToVault: bool
    /// Whether the user's fill is delivered through a Vault.
    userFillToVault: bool
    /// Referenced owner, refund, and ask-minter addresses.
    more: Cell<StonfiEscrowFactoryLockMetadataMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowFactoryForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowFactoryLockForwardParams>?
    /// Referenced ask-wallet and owner-key fields.
    nested: Cell<StonfiEscrowFactoryInternalLockNested>
}

/// Position and settlement metadata referenced by a direct internal unlock.
struct StonfiEscrowFactoryUnlockAdditionalData {
    /// Quote identifier of the derived position.
    quoteId: uint256
    /// Whether the user's fill is delivered through a Vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a Vault.
    refundToVault: bool
    /// Optional recipient of the unlocked bid asset.
    recipient: address?
    /// Optional recipient of refunded ask assets.
    refundTo: address?
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowFactoryBilateralUnlockArgs>
    /// Optional post-unlock forwarding parameters.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// Owner and ask-minter addresses nested in a Jetton lock payload.
struct StonfiEscrowFactoryLockPayloadMore {
    /// Optional user that owns the escrow order.
    orderOwner: address?
    /// Optional minter of the ask-side Jetton.
    askJettonMinter: address?
}

/// Referenced metadata carried by a Jetton lock payload.
struct StonfiEscrowFactoryLockPayloadExtra {
    /// Optional Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Optional account that receives rejected or unused assets.
    refundTo: address?
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
    /// Referenced owner and ask-minter addresses.
    more: Cell<StonfiEscrowFactoryLockPayloadMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowFactoryForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowFactoryLockForwardParams>?
}

/// Recipient and Vault-routing flags carried by a Jetton unlock payload.
struct StonfiEscrowFactoryUnlockPayloadExtra {
    /// Optional recipient of the unlocked bid asset.
    recipient: address?
    /// Optional recipient of refunded ask assets.
    refundTo: address?
    /// Whether the user's fill is delivered through a Vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a Vault.
    refundToVault: bool
}

/// Lock a position using Jettons delivered through a TEP-74 notification.
struct (0x3e246684) StonfiEscrowFactoryLockPayload {
    /// Quote identifier assigned to the derived position.
    quoteId: uint256
    /// Whether rejected bid assets are refunded through a Vault.
    refundToVault: bool
    /// Optional account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis points.
    refFeeTier: uint16
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// GRAM value reserved as the safe deposit.
    tonSafeDeposit: coins
    /// Whether the user's fill is delivered through a Vault.
    userFillToVault: bool
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowFactoryBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
    /// Referenced ask-wallet, owner, and forwarding metadata.
    extraFields: Cell<StonfiEscrowFactoryLockPayloadExtra>
}

/// Unlock a position using Jettons delivered through a TEP-74 notification.
struct (0x6a58f85c) StonfiEscrowFactoryUnlockPayload {
    /// Quote identifier of the derived position.
    quoteId: uint256
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Referenced recipient and Vault-routing flags.
    extraFields: Cell<StonfiEscrowFactoryUnlockPayloadExtra>
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowFactoryBilateralUnlockArgs>
    /// Optional post-unlock forwarding parameters.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// Deposit notified Jettons into the sender's deterministic Escrow Vault.
struct (0x702b4dc8) StonfiEscrowFactoryDepositVaultPayload {
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Optional forwarding parameters for the Vault deposit.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// TEP-74 notification received from a Jetton wallet with a nested Escrow payload.
struct (0x7362d09c) StonfiEscrowFactoryJettonTransferNotification {
    /// Query identifier copied from the Jetton transfer.
    queryId: uint64
    /// Jetton amount received in basic token units.
    jettonAmount: coins
    /// Previous owner of the transferred Jettons.
    fromAddress: address
    /// Raw TEP-74 `Either Cell ^Cell` tail containing an Escrow payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Initialize a multi-party escrow transfer and route each payment leg.
struct (0x4716dd16) StonfiEscrowFactoryInitTransfer {
    /// Correlation identifier copied to emitted messages.
    queryId: uint64
    /// Quote identifier assigned to the transfer.
    quoteId: uint256
    /// Transfer mode interpreted by the Factory routing logic.
    transferType: uint32
    /// Optional account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis points.
    refFeeTier: uint16
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Referenced bid-side payment information.
    bidPaymentData: Cell<StonfiEscrowFactoryBidPaymentData>
    /// Referenced ask-side refund information.
    askRefundData: Cell<StonfiEscrowFactoryAskRefundData>
    /// Referenced user settlement information.
    userPaymentData: Cell<StonfiEscrowFactoryUserPaymentData>
}

/// Refund assets after a Position reports a failed operation.
struct (0xd714500d) StonfiEscrowFactoryRefundRequest {
    /// Correlation identifier copied to refund messages.
    queryId: uint64
    /// Quote identifier of the reporting Position.
    quoteId: uint256
    /// Asset amount to refund in basic token units.
    amount: coins
    /// Whether the refund is routed through a Vault.
    useVault: bool
    /// Optional direct recipient of refunded assets.
    recipient: address?
    /// Exit code reported by the failed operation.
    exitCode: uint32
    /// Opcode of the operation that failed.
    previousMessage: uint32
    /// Referenced wallet, excess, forward, and rejection routing data.
    extraFields: Cell<StonfiEscrowFactoryRefundRequestExtraFields>
}

/// Lock a deterministic Position through a trusted internal sender.
struct (0x65cb4855) StonfiEscrowFactoryInternalLock {
    /// Correlation identifier copied to the Position request.
    queryId: uint64
    /// Optional owner of the escrow order.
    owner: address?
    /// Optional bid-side Jetton wallet.
    jettonWallet: address?
    /// Bid asset amount in basic token units.
    amount: coins
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowFactoryBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
    /// Referenced quote, routing, owner, and forwarding metadata.
    additionalData: Cell<StonfiEscrowFactoryInternalLockExtra>
}

/// Unlock a deterministic Position through a trusted internal sender.
struct (0x30fe22ab) StonfiEscrowFactoryInternalUnlock {
    /// Correlation identifier copied to the Position request.
    queryId: uint64
    /// Optional owner associated with the unlock.
    owner: address?
    /// Optional Jetton wallet that supplied the ask asset.
    jettonWallet: address?
    /// Ask asset amount supplied in basic token units.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Referenced quote, recipient, condition, and forwarding metadata.
    additionalData: Cell<StonfiEscrowFactoryUnlockAdditionalData>
}

/// Withdraw accumulated Jettons from a deterministic Vault.
struct (0x2c3b4692) StonfiEscrowFactoryInternalWithdrawTokens {
    /// Correlation identifier copied to the Jetton transfer.
    queryId: uint64
    /// Optional Jetton wallet from which assets are withdrawn.
    jettonWallet: address?
    /// Collected fee amount withdrawn in basic token units.
    collectedFees: coins
    /// Optional owner that receives the withdrawn assets.
    owner: address?
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Optional forwarding parameters for the Jetton transfer.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// Start a two-step transfer of protocol ownership.
struct (0x5df8fa35) StonfiEscrowFactoryGiveProtocolOwnership {
    /// Correlation identifier copied to the acknowledgement.
    queryId: uint64
    /// Proposed protocol owner.
    newProtocolAddress: address?
    /// Optional account that receives excess GRAM.
    excesses: address?
}

/// Change the protocol fee tier.
struct (0xde34aedc) StonfiEscrowFactoryUpdateProtocolTier {
    /// Correlation identifier copied to the acknowledgement.
    queryId: uint64
    /// New protocol fee tier in basis points.
    newTier: uint16
    /// Optional account that receives excess GRAM.
    excesses: address?
}

/// Accept a pending transfer of protocol ownership.
struct (0x88124614) StonfiEscrowFactoryTakeProtocolOwnership {
    /// Correlation identifier copied to the acknowledgement.
    queryId: uint64
    /// Optional account that receives excess GRAM.
    excesses: address?
}

/// Cancel the pending protocol owner.
struct (0x07f886e6) StonfiEscrowFactoryCancelNextProtocolOwner {
    /// Correlation identifier copied to the acknowledgement.
    queryId: uint64
    /// Optional account that receives excess GRAM.
    excesses: address?
}

/// Reserve the Factory storage balance and return excess GRAM.
struct (0xfe16529e) StonfiEscrowFactoryResetGas {
    /// Correlation identifier copied to the acknowledgement.
    queryId: uint64
    /// Optional recipient of excess GRAM; none selects the sender.
    recipient: address?
}

/// Additional order fields sent to a derived Position during a lock.
struct StonfiEscrowFactoryPositionLockMetadataMore {
    /// Optional minter of the ask-side Jetton.
    askJettonMinter: address?
    /// Optional user that owns the order.
    orderOwner: address?
    /// Optional account that receives rejected or unused assets.
    refundTo: address?
}

/// Order and forwarding metadata sent to a derived Position during a lock.
struct StonfiEscrowFactoryPositionLockMetadata {
    /// Optional Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Optional account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis points.
    refFeeTier: uint16
    /// GRAM value reserved for safe deposit and forwarding.
    safeDepositAndForwardValue: coins
    /// Whether the user's fill is delivered through a Vault.
    userFillToVault: bool
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
    /// Referenced ask-minter, owner, and refund addresses.
    more: Cell<StonfiEscrowFactoryPositionLockMetadataMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowFactoryForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowFactoryLockForwardParams>?
}

/// Recipient addresses sent to a derived Position during an unlock.
struct StonfiEscrowFactoryPositionUnlockExtra {
    /// Optional recipient of the unlocked bid asset.
    recipient: address?
    /// Optional recipient of refunded ask assets.
    refundTo: address?
    /// Optional account that receives excess GRAM.
    excesses: address?
}

/// Lock request emitted to a deterministic Escrow Position.
struct (0x7ab06181) StonfiEscrowFactoryPositionInternalLock {
    /// Correlation identifier copied from the Factory request.
    queryId: uint64
    /// Optional bid-side Jetton wallet assigned to the Position.
    tokenAddress: address?
    /// Bid asset amount deposited into the Position.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Whether rejected bid assets are refunded through a Vault.
    refundToVault: bool
    /// Referenced order and forwarding metadata.
    additionalField: Cell<StonfiEscrowFactoryPositionLockMetadata>
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowFactoryBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
}

/// Unlock request emitted to a deterministic Escrow Position.
struct (0x696fa2d8) StonfiEscrowFactoryPositionInternalUnlock {
    /// Correlation identifier copied from the Factory request.
    queryId: uint64
    /// Whether the user's fill is delivered through a Vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a Vault.
    refundToVault: bool
    /// Optional resolver responsible for the ask-side fill.
    resolver: address?
    /// Optional resolver Jetton wallet that supplied the ask asset.
    resolverSentJettonWallet: address?
    /// Ask asset amount supplied by the resolver.
    resolverSentAmount: coins
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowFactoryBilateralUnlockArgs>
    /// Referenced recipient, refund, and excess addresses.
    extraFields: Cell<StonfiEscrowFactoryPositionUnlockExtra>
    /// Optional post-unlock forwarding parameters.
    forwardParams: Cell<StonfiEscrowFactoryForwardParams>?
}

/// Deposit request emitted to a deterministic Escrow Vault.
struct (0x555edf4b) StonfiEscrowFactoryVaultDepositTokens {
    /// Correlation identifier copied from the Factory request.
    queryId: uint64
    /// Jetton amount deposited in basic token units.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Nanograms forwarded by the Vault after the deposit.
    forwardTonAmount: coins
    /// Optional body forwarded by the Vault after the deposit.
    forwardPayload: cell?
}

/// Notify a configured destination that an attempted lock was rejected.
struct (0xac8a7373) StonfiEscrowFactoryLockRejectNotification {
    /// Correlation identifier copied from the rejected request.
    queryId: uint64
    /// Optional rejection body configured by the request.
    forwardPayload: cell?
}

/// TEP-74 Jetton transfer emitted for withdrawals and refunds.
struct (0x0f8a7ea5) StonfiEscrowFactoryJettonTransfer {
    /// Correlation identifier copied from the Factory request.
    queryId: uint64
    /// Jetton amount transferred in basic token units.
    amount: coins
    /// Owner account that receives the Jettons.
    destination: address
    /// Account that receives excess GRAM from the Jetton wallet.
    responseDestination: address
    /// Optional custom payload attached to the transfer.
    customPayload: cell?
    /// Nanograms forwarded with the destination notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value acknowledgement emitted after an admin request.
struct (0xd53276db) StonfiEscrowFactoryExcesses {
    /// Correlation identifier copied from the admin request.
    queryId: uint64
}

/// Internal bodies accepted by the Escrow Factory.
type StonfiEscrowFactoryIncomingMessage =
    | StonfiEscrowFactoryJettonTransferNotification
    | StonfiEscrowFactoryInitTransfer
    | StonfiEscrowFactoryRefundRequest
    | StonfiEscrowFactoryInternalLock
    | StonfiEscrowFactoryInternalUnlock
    | StonfiEscrowFactoryInternalWithdrawTokens
    | StonfiEscrowFactoryGiveProtocolOwnership
    | StonfiEscrowFactoryUpdateProtocolTier
    | StonfiEscrowFactoryTakeProtocolOwnership
    | StonfiEscrowFactoryCancelNextProtocolOwner
    | StonfiEscrowFactoryResetGas

/// Proven body families emitted by the Escrow Factory.
type StonfiEscrowFactoryOutgoingMessage =
    | StonfiEscrowFactoryPositionInternalLock
    | StonfiEscrowFactoryPositionInternalUnlock
    | StonfiEscrowFactoryVaultDepositTokens
    | StonfiEscrowFactoryLockRejectNotification
    | StonfiEscrowFactoryJettonTransfer
    | StonfiEscrowFactoryExcesses

/// Escrow configuration returned by `getEscrowData`.
struct StonfiEscrowFactoryEscrowData {
    /// Global protocol identifier included in derived contract state.
    globalId: uint64
    /// Protocol account authorized to administer the Factory.
    protocol: address
    /// Protocol fee tier in basis points.
    protocolTier: uint16
    /// Code installed into deterministic Escrow Position accounts.
    itemCode: cell
    /// Code installed into deterministic Escrow Vault accounts.
    vaultCode: cell
}

/// Semantic version returned by `getVersion`.
struct StonfiEscrowFactoryVersion {
    /// Major version number.
    major: uint8
    /// Minor version number.
    minor: uint8
    /// Development or prerelease label.
    development: string
}

/// Return the deterministic Position address for a quote identifier.
get fun getItemAddress(quoteId: int): address {
    throw 0;
}

/// Return the deterministic Vault address for a Jetton wallet and owner.
get fun getVaultAddress(jettonWallet: address, owner: address): address {
    throw 0;
}

/// Return the active protocol configuration and child-contract code cells.
get fun getEscrowData(): StonfiEscrowFactoryEscrowData {
    throw 0;
}

/// Return the deployed Escrow Factory semantic version.
get fun getVersion(): StonfiEscrowFactoryVersion {
    throw 0;
}

/// Exit codes exposed by the Escrow Factory runtime.
enum StonfiEscrowFactoryErrors {
    /// The receiver was invoked through an unsupported entry path.
    InvalidCall = 5190
    /// A protocol or referral tier is outside the supported range.
    InvalidTier = 11629
    /// An internal message was sent from an unauthorized account.
    InvalidCaller = 32950
    /// A supplied account belongs to an unsupported workchain.
    WrongWorkchain = 33533
    /// The inbound value cannot cover required forwarding and deployment costs.
    InsufficientGas = 33565
    /// A supplied Jetton amount is zero or otherwise invalid.
    InvalidAmount = 34643
    /// The supplied GRAM safe deposit is below the required minimum.
    InsufficientSafeDeposit = 34650
    /// A configured forward value is below the required minimum.
    InsufficientForwardValue = 34651
    /// No pending protocol owner exists for the requested transition.
    MissingPendingProtocolOwner = 34656
    /// A TEP-74 notification contains an unsupported or malformed Escrow payload.
    InvalidTransferNotificationPayload = 34658
}
