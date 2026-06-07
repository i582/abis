/// Old TON lockup vesting wallet with V3-style external messages and linear unlock schedule.
contract LockupVesting {
    author: "TON Core"
    version: "1.0"
    description: "Curated old lockup vesting wallet interface"
    storage: LockupVestingStorage
    incomingExternal: LockupVestingIncomingExternalMessage
    thrownErrors: Errors
}

/// Persistent old lockup vesting wallet state.
struct LockupVestingStorage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Wallet id, also called subwallet id.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
    /// Unix timestamp from which vesting schedule starts.
    startTime: uint64
    /// Total vesting duration in seconds.
    totalDuration: uint32
    /// Step duration used to unlock equal vesting portions.
    unlockPeriod: uint32
    /// Initial cliff duration in seconds during which all vesting amount stays locked.
    cliffDuration: uint32
    /// Total amount subject to vesting.
    totalAmount: coins
    /// True when locked funds may be sent to Elector and Config system contracts.
    allowElector: bool
}

/// External-in request authenticated by Ed25519 signature over the unsigned trailing payload.
struct LockupVestingSignedExternal {
    /// Ed25519 signature over subwalletId, validUntil, seqno, and optional outgoing-message tail.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw tail after seqno: empty or exactly one `mode:uint8` plus one message ref; mode must be 3.
    outgoing: RemainingBitsAndRefs
}

/// External-in message body accepted by old lockup vesting wallet.
type LockupVestingIncomingExternalMessage = LockupVestingSignedExternal

/// Parameters returned by `get_lockup_data`.
struct GetLockupDataReply {
    /// Unix timestamp from which vesting schedule starts.
    startTime: uint64
    /// Total vesting duration in seconds.
    totalDuration: uint32
    /// Step duration used to unlock equal vesting portions.
    unlockPeriod: uint32
    /// Initial cliff duration in seconds.
    cliffDuration: uint32
    /// Total amount subject to vesting.
    totalAmount: coins
    /// True when Elector and Config destinations bypass the vesting reserve.
    allowElector: bool
}

/// Old lockup vesting exit-code catalog from source.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Ed25519 signature verification failed.
    InvalidSignature = 35
    /// Request validUntil is not greater than the current block time.
    ExpiredMessage = 36
    /// External request contains neither zero nor one outgoing message refs.
    InvalidRefsCount = 37
    /// Outgoing message send mode is not exactly 3.
    InvalidSendMode = 38
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    throw 0;
}

/// Return the amount locked at the supplied Unix timestamp.
get fun get_locked_amount(atTime: int): coins {
    throw 0;
}

/// Return lockup vesting schedule parameters.
get fun get_lockup_data(): GetLockupDataReply {
    throw 0;
}
