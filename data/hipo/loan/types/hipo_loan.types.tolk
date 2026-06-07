/// Hipo Finance per-round Loan contract deployed on masterchain to safeguard validator loans.
contract HipoLoan {
    author: "Hipo Finance"
    version: "1.0"
    description: "Curated interface for Hipo Finance Loan contracts"
    storage: HipoLoanStorage
    incomingMessages: HipoLoanIncomingMessage
    outgoingMessages: HipoLoanOutgoingMessage
    thrownErrors: HipoLoanErrors
}

/// Persistent Loan state stored in the root data cell.
struct HipoLoanStorage {
    /// Elector address used for recovery; `addr_none` before the first successful proxy_new_stake.
    elector: address?
    /// Treasury address authorized to proxy stake and recover commands.
    treasury: address
    /// Borrower address associated with this per-round Loan.
    borrower: address
    /// Validation round start timestamp, in Unix seconds.
    roundSince: uint32
}

/// New-stake payload stored by Treasury inside `HipoLoanProxyNewStake.newStakeMsg`.
struct HipoLoanNewStakeMsg {
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp accepted by Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Treasury command that deploys/updates the Loan and asks it to stake via Elector.
struct (0x089cd4d0) HipoLoanProxyNewStake {
    /// Treasury query id copied to the Elector `new_stake` body.
    queryId: uint64
    /// Referenced Elector stake payload without the `new_stake` opcode or query id.
    newStakeMsg: Cell<HipoLoanNewStakeMsg>
}

/// Treasury command that asks the Loan to recover stake from its saved Elector.
struct (0x407cb243) HipoLoanProxyRecoverStake {
    /// Treasury query id copied to the Elector `recover_stake` body.
    queryId: uint64
}

/// Elector `new_stake` request emitted by the Loan.
struct (0x4e73744b) HipoLoanNewStake {
    /// Query id originally supplied by Treasury.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp accepted by Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Elector failure response for `new_stake`, also used after a bounced `new_stake`.
struct (0xee6f454c) HipoLoanNewStakeError {
    /// Query id copied from the failed Elector request when available.
    queryId: uint64
    /// Elector error reason, or bounce-derived reason when provided.
    reason: uint32
}

/// Elector success response for `new_stake`; Loan intentionally treats it as a no-op.
struct (0xf374484c) HipoLoanNewStakeOk {
    /// Query id copied from the successful Elector request.
    queryId: uint64
    /// Elector comment field defined by the Hipo TL-B schema.
    comment: uint32
}

/// Elector `recover_stake` request emitted by the Loan.
struct (0x47657424) HipoLoanRecoverStake {
    /// Query id originally supplied by Treasury.
    queryId: uint64
}

/// Elector failure response for `recover_stake`, also used after a bounced `recover_stake`.
struct (0xfffffffe) HipoLoanRecoverStakeError {
    /// Query id copied from the failed Elector request when available.
    queryId: uint64
    /// Elector error reason, or bounce-derived reason when provided.
    reason: uint32
}

/// Elector success response for `recover_stake`.
struct (0xf96f7324) HipoLoanRecoverStakeOk {
    /// Query id copied from the successful Elector request.
    queryId: uint64
}

/// Result body emitted by Loan to Treasury after Elector recovery or recovery-like errors.
struct (0x0fca4c86) HipoLoanRecoverStakeResult {
    /// Query id copied from the Elector response when present.
    queryId: uint64
    /// True for `recover_stake_ok`, false for recover/new-stake error paths.
    ok: bool
    /// Borrower address copied from Loan storage.
    borrower: address
    /// Validation round start timestamp copied from Loan storage.
    roundSince: uint32
}

/// Value-only top-up body accepted as a no-op by Loan.
struct (0x5372158c) HipoLoanTopUp {}

/// Internal message bodies accepted by Hipo Loan.
type HipoLoanIncomingMessage =
    | HipoLoanProxyNewStake
    | HipoLoanProxyRecoverStake
    | HipoLoanNewStakeError
    | HipoLoanNewStakeOk
    | HipoLoanRecoverStakeError
    | HipoLoanRecoverStakeOk
    | HipoLoanTopUp

/// Internal message bodies emitted by Hipo Loan.
type HipoLoanOutgoingMessage =
    | HipoLoanNewStake
    | HipoLoanRecoverStake
    | HipoLoanRecoverStakeResult

/// Structured result returned by `get_loan_state`.
struct HipoLoanState {
    /// Elector stack address, or `addr_none` before the first saved stake attempt.
    elector: any_address
    /// Treasury address authorized to control the Loan.
    treasury: address
    /// Borrower address associated with this Loan.
    borrower: address
    /// Validation round start timestamp, in Unix seconds.
    roundSince: uint32
}

/// Loan exit-code catalog proven from `constants.fc` and `loan.fc`.
enum HipoLoanErrors {
    /// Caller is not the authorized Treasury or Elector for a privileged path.
    AccessDenied = 103
    /// Message opcode is unsupported and source is not an Elector address accepted for coin returns.
    InvalidOperation = 107
}

/// Return Elector, Treasury, borrower, and round timestamp from persistent storage.
get fun get_loan_state(): HipoLoanState {
    throw 0;
}
