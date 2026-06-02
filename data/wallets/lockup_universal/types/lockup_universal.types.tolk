/// Universal lockup wallet with immutable destination allowlist and locked/restricted batches.
contract LockupUniversal {
    author: "TON Core"
    version: "1.0"
    description: "Curated universal lockup wallet interface"
    storage: LockupUniversalStorage
    incomingMessages: LockupUniversalIncomingMessage
    incomingExternal: LockupUniversalIncomingExternalMessage
}

/// Persistent universal lockup wallet state.
struct LockupUniversalStorage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Wallet id, also called subwallet id.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
    /// Configuration Ed25519 public key used to authorize locked-fund top-ups.
    configPublicKey: uint256
    /// Raw prefix dictionary of allowlisted destination addresses.
    allowedDestinations: cell?
    /// Total amount of unrestricted locked funds still locked.
    totalLockedValue: coins
    /// Raw dictionary keyed by unlock timestamp with locked-fund amounts.
    locked: cell?
    /// Total amount of restricted funds still locked.
    totalRestrictedValue: coins
    /// Raw dictionary keyed by unlock timestamp with restricted-fund amounts.
    restricted: cell?
}

/// Signed internal top-up command used by the lockup sender to add locked or restricted funds.
struct (0x82eaf9c4) LockupUniversalRestrictedTransfer {
    /// Ed25519 signature by storage.configPublicKey over command, onlyRestrict, and timestamp.
    signature: bits512
    /// Command id expected to be `0x373aa9f4`.
    command: uint32
    /// True to add funds to the restricted bucket; false to add funds to the locked bucket.
    onlyRestrict: bool
    /// Unix timestamp at which the attached amount is unlocked.
    timestamp: uint32
}

/// External-in request authenticated by Ed25519 signature over the unsigned trailing payload.
struct LockupUniversalSignedExternal {
    /// Ed25519 signature over subwalletId, validUntil, seqno, and outgoing-message stream.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw stream of zero or more `mode:uint8` plus `^MessageRelaxed` pairs.
    messages: RemainingBitsAndRefs
}

/// Internal message body accepted by universal lockup wallet.
type LockupUniversalIncomingMessage = LockupUniversalRestrictedTransfer

/// External-in message body accepted by universal lockup wallet.
type LockupUniversalIncomingExternalMessage = LockupUniversalSignedExternal

/// Balances returned by `get_balances` and `get_balances_at`.
struct LockupUniversalBalances {
    /// Current account Toncoin balance.
    tonBalance: coins
    /// Still-locked restricted amount.
    totalRestrictedValue: coins
    /// Still-locked unrestricted amount.
    totalLockedValue: coins
}

/// Universal lockup exit-code catalog from source.
enum Errors {
    /// External request Ed25519 signature verification failed.
    WrongSignature = 31
    /// Internal restricted-transfer config signature verification failed.
    WrongConfigSignature = 32
    /// Internal restricted-transfer message carries less than 1 TON.
    ValueIsTooSmall = 33
    /// External request seqno does not match storage.seqno.
    WrongSeqno = 34
    /// External request wallet id does not match storage.subwalletId.
    WrongSubwalletId = 35
    /// External request validUntil is not greater than the current block time.
    ReplayProtection = 36
    /// Internal message opcode is not recognized.
    UnknownOp = 40
    /// Internal restricted-transfer command is not recognized.
    UnknownCmd = 41
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw Errors.WrongSignature;
    assert (true) throw Errors.WrongConfigSignature;
    assert (true) throw Errors.ValueIsTooSmall;
    assert (true) throw Errors.WrongSeqno;
    assert (true) throw Errors.WrongSubwalletId;
    assert (true) throw Errors.ReplayProtection;
    assert (true) throw Errors.UnknownOp;
    assert (true) throw Errors.UnknownCmd;
    return 0;
}

/// Return the stored wallet id.
get fun wallet_id(): uint32 {
    return 0;
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    return 0;
}

/// Return account, restricted, and locked balances after unlocking batches up to `time`.
get fun get_balances_at(time: int): LockupUniversalBalances {
    return {
        tonBalance: 0,
        totalRestrictedValue: 0,
        totalLockedValue: 0,
    };
}

/// Return current account, restricted, and locked balances.
get fun get_balances(): LockupUniversalBalances {
    return {
        tonBalance: 0,
        totalRestrictedValue: 0,
        totalLockedValue: 0,
    };
}

/// Return whether a destination address matches the immutable allowlist prefix dictionary.
get fun check_destination(destination: address): bool {
    return false;
}
