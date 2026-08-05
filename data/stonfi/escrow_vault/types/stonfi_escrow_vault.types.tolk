/// STON.fi Escrow Vault that holds one owner's Jetton balance and routes escrow operations through the minter.
contract StonfiEscrowVault {
    author: "STON.fi"
    description: "STON.fi Escrow Vault stores an owner's Jettons and routes lock, unlock, withdrawal, and deposit flows through the Escrow Factory."
    storage: StonfiEscrowVaultStorage
    incomingMessages: StonfiEscrowVaultIncomingMessage
    outgoingMessages: StonfiEscrowVaultOutgoingMessage
    forceAbiExport: StonfiEscrowVaultForwardParams
        | StonfiEscrowVaultLockForwardParams
        | StonfiEscrowVaultBilateralLockArgs
        | StonfiEscrowVaultBilateralUnlockArgs
        | StonfiEscrowVaultData
    thrownErrors: StonfiEscrowVaultErrors
}

/// Complete persistent state of an initialized Escrow Vault.
struct StonfiEscrowVaultStorage {
    /// Escrow minter authorized to mutate the Vault balance and route settlement.
    minter: address
    /// Jetton wallet that holds the owner's escrowed asset.
    jettonWallet: address
    /// Jetton amount currently credited to the owner in basic token units.
    balance: coins
    /// User account that owns this Vault.
    owner: address
}

/// GRAM value and success/rejection bodies forwarded by an escrow action.
struct StonfiEscrowVaultForwardParams {
    /// GRAM value attached to the forwarded message.
    value: coins
    /// Optional body used when the action succeeds.
    successPayload: cell?
    /// Optional body used when the action is rejected.
    rejectPayload: cell?
}

/// Optional destination and forwarding parameters used after a lock.
struct StonfiEscrowVaultLockForwardParams {
    /// Destination of the lock result notification.
    destination: address?
    /// Value and payloads for the result notification.
    forwardParams: StonfiEscrowVaultForwardParams
}

/// Packed Dutch-auction segments interpreted by the unlock condition.
struct StonfiEscrowVaultDutchSegments {
    /// Number of encoded segments.
    count: uint4
    /// Packed segment data retained for the condition program.
    segments: RemainingBitsAndRefs
}

/// Condition arguments supplied when assets are locked from the Vault.
struct StonfiEscrowVaultBilateralLockArgs {
    /// Optional resolver allowed to satisfy the bilateral condition.
    resolver: address?
    /// Resolver timeout measured from the lock time.
    resolverTimeoutDelta: uint64
    /// Ask amount expected from the resolver.
    resolverAskAmount: coins
    /// Optional resolver Ed25519 public key.
    resolverPublicKey: uint256?
    /// Dutch-auction segments used by the condition program.
    dutchSegments: Cell<StonfiEscrowVaultDutchSegments>
}

/// Resolver authorization data signed for an unlock.
struct StonfiEscrowVaultBilateralSignedMessage {
    /// Unix timestamp after which the authorization is invalid.
    expirationTime: uint64
    /// Resolver authorized by the signature.
    resolver: address?
}

/// Signature and referenced resolver authorization.
struct StonfiEscrowVaultBilateralSignPayload {
    /// Ed25519 signature over the referenced authorization cell.
    signature: bits512
    /// Resolver authorization covered by the signature.
    message: Cell<StonfiEscrowVaultBilateralSignedMessage>
}

/// Bilateral-condition arguments supplied during an unlock.
struct StonfiEscrowVaultBilateralUnlockArgs {
    /// Minimum amount the user accepts from the unlock.
    minOut: coins
    /// Refund amount the condition may ignore.
    ignoreRefundAmount: coins
    /// Optional signed resolver authorization.
    signed: StonfiEscrowVaultBilateralSignPayload?
}

/// Owner, refund, and ask-minter addresses referenced by a Vault lock.
struct StonfiEscrowVaultLockAdditionalDataMore {
    /// Optional user that owns the resulting escrow order.
    orderOwner: address?
    /// Optional account that receives rejected or unused assets.
    refundTo: address?
    /// Optional minter of the ask-side Jetton.
    askJettonMinter: address?
}

/// Settlement and forwarding metadata supplied with a Vault lock.
struct StonfiEscrowVaultLockAdditionalData {
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// GRAM amount reserved as the order's safe deposit.
    tonSafeDeposit: coins
    /// Whether the user's fill is returned through an Escrow Vault.
    userFillToVault: bool
    /// Optional Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
    /// Referenced owner, refund, and ask-minter addresses.
    more: Cell<StonfiEscrowVaultLockAdditionalDataMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowVaultForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowVaultLockForwardParams>?
}

/// Ask-wallet and owner-key fields nested in a minter lock request.
struct StonfiEscrowVaultInternalLockNested {
    /// Optional Jetton wallet from which the ask asset is received.
    askJettonWallet: address?
    /// Optional Ed25519 key authorized to sign external withdrawals.
    ownerPublicKey: uint256?
}

/// Position and settlement metadata forwarded to the Escrow minter during a lock.
struct StonfiEscrowVaultInternalLockExtra {
    /// Quote identifier assigned to the resulting position.
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
    more: Cell<StonfiEscrowVaultLockAdditionalDataMore>
    /// Optional parameters used after a user unlock.
    userUnlockForwardParams: Cell<StonfiEscrowVaultForwardParams>?
    /// Optional destination and payloads used after the lock.
    lockForwardParams: Cell<StonfiEscrowVaultLockForwardParams>?
    /// Referenced ask-wallet and owner-key fields.
    nested: Cell<StonfiEscrowVaultInternalLockNested>
}

/// Recipient and refund addresses carried by a Vault unlock request.
struct StonfiEscrowVaultUnlockExtraFields {
    /// Optional recipient of the unlocked bid asset.
    recipient: address?
    /// Optional account that receives refunded ask assets.
    refundTo: address?
}

/// Position and settlement metadata forwarded to the Escrow minter during an unlock.
struct StonfiEscrowVaultUnlockAdditionalData {
    /// Quote identifier of the affected escrow position.
    quoteId: uint256
    /// Whether the user's fill is delivered through a Vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a Vault.
    refundToVault: bool
    /// Optional recipient of the unlocked bid asset.
    recipient: address?
    /// Optional account that receives refunded ask assets.
    refundTo: address?
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowVaultBilateralUnlockArgs>
    /// Optional post-unlock forwarding parameters.
    forwardParams: Cell<StonfiEscrowVaultForwardParams>?
}

/// Lock part of the Vault balance into a new escrow position.
struct (0x24864ed4) StonfiEscrowVaultLock {
    /// Correlation identifier copied to minter messages.
    queryId: uint64
    /// Jetton amount removed from the Vault balance.
    amount: coins
    /// Quote identifier assigned to the resulting position.
    quoteId: uint256
    /// Whether rejected bid assets are refunded through a Vault.
    refundToVault: bool
    /// Optional account that receives the referral fee.
    refFee: address?
    /// Referral fee tier in protocol basis points.
    refFeeTier: uint16
    /// Referenced order, settlement, and forwarding metadata.
    additionalData: Cell<StonfiEscrowVaultLockAdditionalData>
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowVaultBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
}

/// Apply an ask-side fill and unlock assets through the Vault.
struct (0x4bd679ff) StonfiEscrowVaultUnlock {
    /// Correlation identifier copied to minter messages.
    queryId: uint64
    /// Jetton amount removed from the Vault balance.
    amount: coins
    /// Quote identifier of the affected position.
    quoteId: uint256
    /// Whether the user's fill is delivered through a Vault.
    fillToVault: bool
    /// Whether refunded assets are delivered through a Vault.
    refundToVault: bool
    /// Referenced condition-specific unlock arguments.
    unlockArgs: Cell<StonfiEscrowVaultBilateralUnlockArgs>
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Referenced recipient and refund addresses.
    extraFields: Cell<StonfiEscrowVaultUnlockExtraFields>
    /// Optional post-unlock forwarding parameters.
    unlockForwardParams: Cell<StonfiEscrowVaultForwardParams>?
}

/// Withdraw part of the Vault balance through its configured Jetton wallet.
struct (0x5809e482) StonfiEscrowVaultWithdrawTokens {
    /// Correlation identifier copied to the minter withdrawal request.
    queryId: uint64
    /// Jetton amount removed from the Vault balance.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Optional forwarding parameters for the withdrawal.
    withdrawForwardParams: Cell<StonfiEscrowVaultForwardParams>?
}

/// Credit Jettons to the Vault and optionally notify its owner.
struct (0x555edf4b) StonfiEscrowVaultDepositTokens {
    /// Correlation identifier copied to the notification or excess acknowledgement.
    queryId: uint64
    /// Jetton amount added to the Vault balance.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Nanograms forwarded to the owner notification.
    forwardTonAmount: coins
    /// Optional body forwarded to the owner notification.
    forwardPayload: cell?
}

/// Lock request emitted to the Escrow minter after debiting the Vault balance.
struct (0x65cb4855) StonfiEscrowVaultMinterInternalLock {
    /// Correlation identifier copied from the Vault lock request.
    queryId: uint64
    /// Vault owner whose assets are being locked.
    owner: address?
    /// Jetton wallet that holds the locked asset.
    jettonWallet: address?
    /// Jetton amount locked in basic token units.
    amount: coins
    /// Referenced bilateral-condition parameters.
    lockArgs: Cell<StonfiEscrowVaultBilateralLockArgs>
    /// Executable unlock-condition program.
    unlockCondition: cell
    /// Referenced quote and settlement metadata.
    additionalData: Cell<StonfiEscrowVaultInternalLockExtra>
}

/// Unlock request emitted to the Escrow minter after debiting the Vault balance.
struct (0x30fe22ab) StonfiEscrowVaultMinterInternalUnlock {
    /// Correlation identifier copied from the Vault unlock request.
    queryId: uint64
    /// Vault owner whose assets are being unlocked.
    owner: address?
    /// Jetton wallet that holds the unlocked asset.
    jettonWallet: address?
    /// Jetton amount unlocked in basic token units.
    amount: coins
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Referenced quote, routing, and forwarding metadata.
    additionalData: Cell<StonfiEscrowVaultUnlockAdditionalData>
}

/// Withdrawal request emitted to the Escrow minter after debiting the Vault balance.
struct (0x2c3b4692) StonfiEscrowVaultMinterInternalWithdrawTokens {
    /// Correlation identifier copied from the Vault withdrawal request.
    queryId: uint64
    /// Jetton wallet from which assets are withdrawn.
    jettonWallet: address?
    /// Jetton amount withdrawn in basic token units.
    collectedFees: coins
    /// Vault owner whose assets are withdrawn.
    owner: address?
    /// Optional account that receives excess GRAM.
    excesses: address?
    /// Optional forwarding parameters for the withdrawal.
    forwardParams: Cell<StonfiEscrowVaultForwardParams>?
}

/// Notify the Vault owner that Jettons were credited.
struct (0x44aceac4) StonfiEscrowVaultDepositNotification {
    /// Correlation identifier copied from the deposit request.
    queryId: uint64
    /// Jetton amount credited in basic token units.
    amount: coins
    /// Raw TL-B `Either Cell ^Cell` forward payload, including its selector bit.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value acknowledgement emitted after a deposit.
struct (0xd53276db) StonfiEscrowVaultExcesses {
    /// Correlation identifier copied from the deposit request.
    queryId: uint64
}

/// Internal bodies accepted by the Escrow Vault.
type StonfiEscrowVaultIncomingMessage =
    | StonfiEscrowVaultLock
    | StonfiEscrowVaultUnlock
    | StonfiEscrowVaultWithdrawTokens
    | StonfiEscrowVaultDepositTokens

/// Proven body families emitted by the Escrow Vault.
type StonfiEscrowVaultOutgoingMessage =
    | StonfiEscrowVaultMinterInternalLock
    | StonfiEscrowVaultMinterInternalUnlock
    | StonfiEscrowVaultMinterInternalWithdrawTokens
    | StonfiEscrowVaultDepositNotification
    | StonfiEscrowVaultExcesses

/// Vault state returned by `getVaultData`.
struct StonfiEscrowVaultData {
    /// Escrow minter authorized to mutate the Vault balance and route settlement.
    minter: address
    /// Jetton wallet that holds the owner's escrowed asset.
    jettonWallet: address
    /// Jetton amount currently credited to the owner in basic token units.
    balance: coins
    /// User account that owns this Vault.
    owner: address
}

/// Return the Vault minter, Jetton wallet, credited balance, and owner.
get fun getVaultData(): StonfiEscrowVaultData {
    throw 0;
}

/// Exit codes exposed by the Escrow Vault runtime.
enum StonfiEscrowVaultErrors {
    /// A protocol or referral tier is outside the supported range.
    InvalidTier = 11629
    /// An internal message was sent from an unauthorized account.
    InvalidCaller = 32950
    /// A supplied account belongs to an unsupported workchain.
    WrongWorkchain = 33533
    /// The inbound value cannot cover required forwarding costs.
    InsufficientGas = 33565
    /// The requested Jetton amount is zero or exceeds the credited balance.
    InvalidAmount = 34643
    /// The supplied GRAM safe deposit is below the required minimum.
    InsufficientSafeDeposit = 34650
    /// A configured forward value is below the required minimum.
    InsufficientForwardValue = 34651
    /// A non-empty body uses an unsupported opcode.
    UnsupportedMessage = 65535
}
