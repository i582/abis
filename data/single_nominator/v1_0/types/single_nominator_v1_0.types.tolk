/// Single Nominator Pool contract for one owner and one validator wallet.
contract SingleNominatorV10 {
    author: "Orbs Network"
    version: "1.0"
    description: "Single Nominator Pool v1.0 ABI for owner commands, validator Elector commands, storage, and pool-compatible getters"
    storage: SingleNominatorV10Storage
    incomingMessages: SingleNominatorV10IncomingMessage
    outgoingMessages: SingleNominatorV10OutgoingMessage
    thrownErrors: SingleNominatorV10Errors
}

/// Persistent Single Nominator state stored in the root data cell.
struct SingleNominatorV10Storage {
    /// Owner wallet authorized to withdraw funds, change validator, relay raw messages, and upgrade code.
    ownerAddress: address
    /// Validator wallet authorized to request new stake and stake recovery.
    validatorAddress: address
}

/// Owner command that withdraws TON to the owner wallet.
struct (0x00001000) SingleNominatorV10Withdraw {
    /// Owner-selected query id.
    queryId: uint64
    /// Requested withdrawal amount in nanotons.
    amount: coins
}

/// Owner command that replaces the validator wallet address.
struct (0x00001001) SingleNominatorV10ChangeValidatorAddress {
    /// Owner-selected query id.
    queryId: uint64
    /// New validator wallet address.
    newValidatorAddress: address
}

/// Owner command that sends an arbitrary raw message from the pool contract.
struct (0x00007702) SingleNominatorV10SendRawMsg {
    /// Owner-selected query id.
    queryId: uint64
    /// TVM send mode passed to `send_raw_message`.
    mode: uint8
    /// Raw outbound message cell.
    msg: cell
}

/// Owner command that replaces the contract code cell.
struct (0x00009903) SingleNominatorV10Upgrade {
    /// Owner-selected query id.
    queryId: uint64
    /// Replacement code cell.
    code: cell
}

/// Validator command that asks the pool to forward a new stake request to Elector.
struct (0x4e73744b) SingleNominatorV10NewStake {
    /// Validator-selected non-zero query id copied into the Elector request.
    queryId: uint64
    /// Stake amount forwarded as the Elector message value.
    stake: coins
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp forwarded to Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Validator command that asks the pool to forward a recover-stake request to Elector.
struct (0x47657424) SingleNominatorV10RecoverStake {
    /// Validator-selected query id copied into the Elector request.
    queryId: uint64
}

/// Elector confirmation body received after a forwarded new-stake request.
struct (0xf374484c) SingleNominatorV10NewStakeConfirmation {
    /// Query id copied from the Elector new-stake request.
    queryId: uint64
    /// Elector confirmation comment field.
    comment: uint32
}

/// Elector response body received after a forwarded recover-stake request.
struct (0xf96f7324) SingleNominatorV10RecoverStakeResponse {
    /// Query id copied from the Elector recover-stake request.
    queryId: uint64
}

/// Elector new-stake body emitted by the pool, without the validator-only stake amount field.
struct (0x4e73744b) SingleNominatorV10ElectorNewStake {
    /// Query id copied from the validator command.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Election round timestamp forwarded to Elector.
    stakeAt: uint32
    /// Validator max-factor forwarded to Elector.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Elector recover-stake body emitted by the pool.
struct (0x47657424) SingleNominatorV10ElectorRecoverStake {
    /// Query id copied from the validator command.
    queryId: uint64
}

/// Internal message bodies accepted by Single Nominator v1.0.
type SingleNominatorV10IncomingMessage =
    | SingleNominatorV10Withdraw
    | SingleNominatorV10ChangeValidatorAddress
    | SingleNominatorV10SendRawMsg
    | SingleNominatorV10Upgrade
    | SingleNominatorV10NewStake
    | SingleNominatorV10RecoverStake
    | SingleNominatorV10NewStakeConfirmation
    | SingleNominatorV10RecoverStakeResponse

/// Internal message bodies emitted by Single Nominator v1.0.
type SingleNominatorV10OutgoingMessage =
    | SingleNominatorV10ElectorNewStake
    | SingleNominatorV10ElectorRecoverStake

/// Structured result returned by `get_roles`.
struct SingleNominatorV10Roles {
    /// Owner wallet address stored in contract data.
    ownerAddress: address
    /// Validator wallet address stored in contract data.
    validatorAddress: address
}

/// Empty config-proposal voting entry list item.
struct SingleNominatorV10ConfigProposalVoting {}

/// Nominator-pool-compatible result returned by `get_pool_data`.
struct SingleNominatorV10PoolDataReply {
    /// Pool state value exposed to MyTonCtrl.
    state: int8
    /// Number of nominators exposed through the pool interface.
    nominatorsCount: uint32
    /// Stake amount recorded as sent to Elector.
    stakeAmountSent: int64
    /// Validator amount tracked by the pool interface.
    validatorAmount: int64
    /// Validator address field in the pool config tuple.
    validatorAddress: uint256
    /// Validator reward share field in the pool config tuple.
    validatorRewardShare: uint32
    /// Maximum nominators count field in the pool config tuple.
    maxNominatorsCount: uint32
    /// Minimum validator stake field in the pool config tuple.
    minValidatorStake: int64
    /// Minimum nominator stake field in the pool config tuple.
    minNominatorStake: int64
    /// Raw nominators dictionary cell returned by the pool interface.
    nominators: cell?
    /// Raw withdraw-requests dictionary cell returned by the pool interface.
    withdrawRequests: cell?
    /// Election round timestamp recorded by the pool interface.
    stakeAt: uint32
    /// Saved validator-set hash recorded by the pool interface.
    savedValidatorSetHash: uint256
    /// Validator-set changes count exposed to MyTonCtrl.
    validatorSetChangesCount: uint32
    /// Validator-set change timestamp exposed to MyTonCtrl.
    validatorSetChangeTime: uint32
    /// Stake hold duration exposed to MyTonCtrl.
    stakeHeldFor: uint32
    /// Config proposal votings returned by the pool interface.
    configProposalVotings: lisp_list<SingleNominatorV10ConfigProposalVoting>
}

/// Single Nominator v1.0 exit-code catalog.
enum SingleNominatorV10Errors {
    /// Pool contract is not deployed on the masterchain for a new-stake request.
    WrongNominatorWorkchain = 8192
    /// New-stake query id is zero.
    WrongQueryId = 8193
    /// Upgrade command does not carry a replacement code cell.
    WrongSetCode = 8194
    /// Validator wallet is not on the masterchain for a new-stake request.
    WrongValidatorWorkchain = 8195
    /// Requested stake or withdrawal amount exceeds the available balance.
    InsufficientBalance = 8196
    /// Validator did not attach the minimum Elector forwarding fee.
    InsufficientElectorFee = 8197
}

/// Return owner and validator role addresses.
get fun get_roles(): SingleNominatorV10Roles {
    throw 0;
}

/// Return the nominator-pool-compatible state tuple used by validator tooling.
get fun get_pool_data(): SingleNominatorV10PoolDataReply {
    throw 0;
}
