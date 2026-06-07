/// Ton Whales Nominators pool contract for pooled TON staking through an Elector proxy.
contract WhalesPool {
    author: "Ton Whales"
    version: "1.0"
    description: "Whales Nominators pool ABI with storage, staking operations, controller operations, Elector bodies, and public getters."
    storage: WhalesPoolStorage
    incomingMessages: WhalesPoolIncomingMessage
    outgoingMessages: WhalesPoolOutgoingMessage
    forceAbiExport: WhalesPoolExtras | WhalesPoolProxyStateTail
    thrownErrors: WhalesPoolErrors
}

/// Pool-wide accounting stored in a referenced balance cell.
struct WhalesPoolBalance {
    /// Accumulated per-coin profit scaled by the pool precision.
    profitPerCoin: int128
    /// Total member-owned pool balance in nanotons.
    balance: coins
    /// TON amount currently sent to Elector staking.
    balanceSent: coins
    /// TON amount prepared for member withdrawals.
    balanceWithdraw: coins
    /// TON amount pending withdrawal acceptance.
    balancePendingWithdraw: coins
    /// TON amount pending deposit acceptance.
    balancePendingDeposits: coins
}

/// Per-member accounting stored in the nominators dictionary.
struct WhalesPoolMember {
    /// Member profit-per-coin checkpoint.
    profitPerCoin: int128
    /// Accepted member stake balance in nanotons.
    balance: coins
    /// Pending withdrawal amount in nanotons.
    pendingWithdraw: coins
    /// True when the member requested full withdrawal.
    pendingWithdrawAll: bool
    /// Pending deposit amount in nanotons.
    pendingDeposit: coins
    /// Amount prepared for member withdrawal payout.
    memberWithdraw: coins
}

/// Current validator-proxy staking state stored in a referenced cell.
struct WhalesPoolProxyState {
    /// Validation round start timestamp used for the active stake.
    stakeAt: uint32
    /// Raw validation lock end timestamp tracked by the pool.
    stakeUntil: uint32
    /// TON amount currently sent through the proxy to Elector.
    stakeSent: coins
    /// Query id of the active Elector request, or zero when none is pending.
    storedQueryId: uint64
    /// Opcode of the active Elector request, or zero when none is pending.
    storedQueryOp: uint32
    /// Stake amount associated with the active Elector request.
    storedQueryStake: coins
    /// Optional proxy-state tail used by newer pool revisions.
    tail: RemainingBitsAndRefs
}

/// Optional proxy-state tail stored after the active-query fields.
struct WhalesPoolProxyStateTail {
    /// Configured stake-hold duration for the active validation round.
    stakeHeldFor: uint32
    /// True when the validator lock interval was finalized.
    stakeLockFinal: bool
}

/// Pool runtime parameters stored in the root storage compatibility tail.
struct WhalesPoolExtras {
    /// True when member deposit and withdrawal operations are enabled.
    enabled: bool
    /// True when owner upgrade and parameter update operations are enabled.
    updatesEnabled: bool
    /// Minimum accepted member stake in nanotons.
    minStake: coins
    /// Deposit operation fee in nanotons.
    depositFee: coins
    /// Withdrawal operation fee in nanotons.
    withdrawFee: coins
    /// Pool fee share in basis-point style units.
    poolFee: coins
    /// TON amount reserved for user receipts.
    receiptPrice: coins
}

/// Persistent pool state stored in the root data cell.
@overflow1023_policy("suppress")
struct WhalesPoolStorage {
    /// True while validator stake is locked.
    locked: bool
    /// Owner address authorized for owner operations.
    owner: address
    /// Controller address authorized for validator and pending-member operations.
    controller: address
    /// Proxy address used to communicate with Elector.
    proxy: address
    /// Referenced pool-wide balance accounting.
    balance: Cell<WhalesPoolBalance>
    /// Nominator records keyed by basechain address hash; key zero is the owner member.
    nominators: map<uint256, WhalesPoolMember>
    /// Referenced validator-proxy staking state.
    proxyState: Cell<WhalesPoolProxyState>
    /// Optional storage tail carrying runtime parameters in current pool revisions.
    compatibilityTail: RemainingBitsAndRefs
}

/// Text command or text receipt body with opcode zero.
struct (0x00000000) WhalesPoolTextComment {
    /// Text bytes and optional continuation references after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Member deposit request accepted by owner and nominators.
struct (0x7bcd1fef) WhalesPoolStakeDeposit {
    /// Caller-selected query id copied to the deposit response.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
}

/// Member withdrawal request accepted by owner and nominators.
struct (0xda803efd) WhalesPoolStakeWithdraw {
    /// Caller-selected query id copied to the withdrawal response.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Requested withdrawal amount; zero requests the full available member balance.
    amount: coins
}

/// Manual recover command accepted by owner and nominators.
struct (0x654d518e) WhalesPoolStakeRecover {
    /// Caller-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
}

/// Donation command that distributes attached TON as pool profit.
struct (0x47bbe425) WhalesPoolDonate {
    /// Caller-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
}

/// Controller command that sends a new validator stake through the proxy.
struct (0xa2065f2c) WhalesPoolStakeSend {
    /// Controller-selected query id copied to the Elector new-stake request.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// TON stake value sent to Elector.
    stake: coins
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp forwarded to Elector.
    stakeAt: uint32
    /// Elector max-factor value.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Controller command that finalizes the validator lock interval.
struct (0x1596920c) WhalesPoolStakeLockFinalize {
    /// Controller-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
}

/// Controller or owner command that withdraws TON not owned by pool members.
struct (0x251d6a98) WhalesPoolWithdrawUnowned {
    /// Caller-selected query id copied to the unowned-withdraw response.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
}

/// Controller command that accepts pending member deposits.
struct (0x99a811fb) WhalesPoolAcceptStakes {
    /// Controller-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Raw member-address dictionary selector.
    members: cell?
}

/// Controller command that accepts pending member withdrawals.
struct (0xa19fd934) WhalesPoolAcceptWithdraws {
    /// Controller-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Raw member-address dictionary selector.
    members: cell?
}

/// Controller command that forcibly withdraws selected nominators.
struct (0x533ecf5c) WhalesPoolForceKick {
    /// Controller-selected query id copied to force-kick notifications.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Raw member-address dictionary selector.
    members: cell?
}

/// Owner command that replaces the pool code cell.
struct (0xdbfaf817) WhalesPoolUpgrade {
    /// Owner-selected query id copied to the upgrade response.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Replacement TVM code cell.
    code: cell
}

/// Owner command that replaces pool runtime parameters.
struct (0x023cd52c) WhalesPoolUpdate {
    /// Owner-selected query id copied to the update response.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Replacement runtime-parameter cell.
    extras: Cell<WhalesPoolExtras>
}

/// Owner command that replaces the owner or controller address.
struct (0x90eafae1) WhalesPoolChangeAddress {
    /// Owner-selected query id.
    queryId: uint64
    /// Gas limit reserved by the pool operation.
    gasLimit: coins
    /// Address slot id: zero for owner, one for controller.
    addressId: uint8
    /// Replacement address for the selected slot.
    newAddress: address
}

/// Elector confirmation received after a new-stake request.
struct (0xf374484c) WhalesPoolElectorNewStakeConfirmation {
    /// Query id copied from the Elector new-stake request.
    queryId: uint64
    /// Elector confirmation comment field.
    comment: uint32
}

/// Elector failure response received after a new-stake request.
struct (0xee6f454c) WhalesPoolElectorNewStakeError {
    /// Query id copied from the Elector new-stake request.
    queryId: uint64
    /// Elector failure reason code.
    reason: uint32
    /// Remaining Elector response payload.
    tail: RemainingBitsAndRefs
}

/// Elector response received after a recover-stake request.
struct (0xf96f7324) WhalesPoolElectorRecoverStakeResponse {
    /// Query id copied from the Elector recover-stake request.
    queryId: uint64
}

/// Elector new-stake request emitted by the pool proxy flow.
struct (0x4e73744b) WhalesPoolElectorNewStake {
    /// Query id copied from the controller stake-send command.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp forwarded to Elector.
    stakeAt: uint32
    /// Elector max-factor value.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddr: bits256
    /// Validator signature cell, encoded as `^bits512`.
    signature: Cell<bits512>
}

/// Elector recover-stake request emitted by the pool proxy flow.
struct (0x47657424) WhalesPoolElectorRecoverStakeRequest {
    /// Query id copied from the controller recover command.
    queryId: uint64
}

/// Deposit receipt emitted for query-id based deposits.
struct (0xc641e932) WhalesPoolStakeDepositResponse {
    /// Query id copied from the deposit request.
    queryId: uint64
}

/// Delayed-withdrawal receipt emitted when a withdrawal is queued.
struct (0x74bb3427) WhalesPoolStakeWithdrawDelayed {
    /// Query id copied from the withdrawal request.
    queryId: uint64
}

/// Completed-withdrawal receipt emitted when a withdrawal is paid.
struct (0x23d421e1) WhalesPoolStakeWithdrawResponse {
    /// Query id copied from the withdrawal request.
    queryId: uint64
}

/// Donation receipt emitted for query-id based donations.
struct (0xb8837d2c) WhalesPoolDonateResponse {
    /// Query id copied from the donation request.
    queryId: uint64
}

/// Upgrade receipt emitted after a code replacement.
struct (0x532e4077) WhalesPoolUpgradeResponse {
    /// Query id copied from the upgrade request.
    queryId: uint64
}

/// Update receipt emitted after runtime parameters are replaced.
struct (0x3211546a) WhalesPoolUpdateResponse {
    /// Query id copied from the update request.
    queryId: uint64
}

/// Unowned-withdraw receipt emitted to the owner or controller.
struct (0x1d1715bf) WhalesPoolWithdrawUnownedResponse {
    /// Query id copied from the withdraw-unowned request.
    queryId: uint64
}

/// Force-kick notification emitted to a kicked nominator.
struct (0x7ad0b942) WhalesPoolForceKickNotification {
    /// Query id copied from the force-kick request.
    queryId: uint64
}

/// Internal message bodies accepted by the pool dispatcher.
type WhalesPoolIncomingMessage =
    | WhalesPoolTextComment
    | WhalesPoolStakeDeposit
    | WhalesPoolStakeWithdraw
    | WhalesPoolStakeRecover
    | WhalesPoolDonate
    | WhalesPoolStakeSend
    | WhalesPoolStakeLockFinalize
    | WhalesPoolWithdrawUnowned
    | WhalesPoolAcceptStakes
    | WhalesPoolAcceptWithdraws
    | WhalesPoolForceKick
    | WhalesPoolUpgrade
    | WhalesPoolUpdate
    | WhalesPoolChangeAddress
    | WhalesPoolElectorNewStakeConfirmation
    | WhalesPoolElectorNewStakeError
    | WhalesPoolElectorRecoverStakeResponse

/// Internal message bodies emitted by the pool and proxy flow.
type WhalesPoolOutgoingMessage =
    | WhalesPoolTextComment
    | WhalesPoolElectorNewStake
    | WhalesPoolElectorRecoverStakeRequest
    | WhalesPoolStakeDepositResponse
    | WhalesPoolStakeWithdrawDelayed
    | WhalesPoolStakeWithdrawResponse
    | WhalesPoolDonateResponse
    | WhalesPoolUpgradeResponse
    | WhalesPoolUpdateResponse
    | WhalesPoolWithdrawUnownedResponse
    | WhalesPoolForceKickNotification

/// Stack reply returned by `get_pool_status`.
struct WhalesPoolStatusReply {
    /// Total member-owned pool balance in nanotons.
    balance: coins
    /// TON amount currently sent to Elector staking.
    balanceSent: coins
    /// TON amount pending deposit acceptance.
    balancePendingDeposits: coins
    /// TON amount pending withdrawal acceptance.
    balancePendingWithdraw: coins
    /// TON amount prepared for member withdrawals.
    balanceWithdraw: coins
}

/// Stack reply returned by `get_staking_status`.
struct WhalesPoolStakingStatusReply {
    /// Validation round start timestamp used for the active stake.
    stakeAt: uint32
    /// Timestamp after which the active stake can be recovered.
    stakeUntil: uint32
    /// TON amount currently sent through the proxy to Elector.
    stakeSent: coins
    /// True when an Elector request is pending.
    querySent: bool
    /// True when the active stake can be unlocked.
    canUnlock: bool
    /// True while validator stake is locked.
    locked: bool
    /// True when the validator lock interval was finalized.
    stakeLockFinal: bool
}

/// Stack reply returned by `get_params`.
struct WhalesPoolParamsReply {
    /// True when member deposit and withdrawal operations are enabled.
    enabled: bool
    /// True when owner upgrade and parameter update operations are enabled.
    updatesEnabled: bool
    /// Minimum accepted member stake in nanotons.
    minStake: coins
    /// Deposit operation fee in nanotons.
    depositFee: coins
    /// Withdrawal operation fee in nanotons.
    withdrawFee: coins
    /// Pool fee share in basis-point style units.
    poolFee: coins
    /// TON amount reserved for user receipts.
    receiptPrice: coins
}

/// Stack reply returned by `get_member` and `get_member_balance`.
struct WhalesPoolMemberBalanceReply {
    /// Accepted member stake balance in nanotons.
    balance: coins
    /// Pending deposit amount in nanotons.
    pendingDeposit: coins
    /// Pending withdrawal amount in nanotons.
    pendingWithdraw: coins
    /// Amount prepared for member withdrawal payout.
    memberWithdraw: coins
}

/// List entry returned by `get_members`.
struct WhalesPoolMemberListEntry {
    /// Member address.
    member: address
    /// Accepted member stake balance in nanotons.
    balance: coins
    /// Pending deposit amount in nanotons.
    pendingDeposit: coins
    /// Pending withdrawal amount in nanotons.
    pendingWithdraw: coins
    /// Amount prepared for member withdrawal payout.
    memberWithdraw: coins
}

/// Stack reply returned by `supported_interfaces`.
struct WhalesPoolSupportedInterfacesReply {
    /// TEP-89 introspection interface id.
    introspection: uint128
    /// Whales Nominators interface id.
    whalesNominators: uint128
}

/// Source-level exit-code catalog for Whales Nominators pool.
enum WhalesPoolErrors {
    /// Address parsing or address domain check failed.
    InvalidAddress = 70
    /// Message body, value, state, or operation parameter is invalid.
    InvalidMessage = 72
    /// Sender is not authorized for the requested operation.
    AccessDenied = 73
    /// Internal invariant failed.
    InternalError = 74
    /// Deployment branch encountered an already deployed account.
    AlreadyDeployed = 75
    /// Attached TON value is below the required operation fee.
    TooLowValue = 76
    /// Stake amount is outside the accepted range.
    InvalidStakeValue = 77
    /// Text command is not recognized by the dispatcher.
    UnknownTextCommand = 78
}

/// Return the configured proxy address.
get fun get_proxy(): address {
    throw 0;
}

/// Return the configured owner address.
get fun get_owner(): address {
    throw 0;
}

/// Return the configured controller address.
get fun get_controller(): address {
    throw 0;
}

/// Return TON balance not owned by pool members.
get fun get_unowned(): coins {
    throw 0;
}

/// Return pool balance available for staking.
get fun get_available(): coins {
    throw 0;
}

/// Return current validator staking status.
get fun get_staking_status(): WhalesPoolStakingStatusReply {
    throw 0;
}

/// Return pool balance accounting.
get fun get_pool_status(): WhalesPoolStatusReply {
    throw 0;
}

/// Return pool runtime parameters.
get fun get_params(): WhalesPoolParamsReply {
    throw 0;
}

/// Return member balance accounting for an address.
get fun get_member_balance(memberAddress: address): WhalesPoolMemberBalanceReply {
    throw 0;
}

/// Return the raw nominator dictionary.
get fun get_members_raw(): map<uint256, WhalesPoolMember> {
    throw 0;
}

/// Return all member balances as a Lisp list.
get fun get_members(): lisp_list<WhalesPoolMemberListEntry> {
    throw 0;
}

/// Return member balance accounting for an address.
get fun get_member(memberAddress: address): WhalesPoolMemberBalanceReply {
    throw 0;
}

/// Return supported interface identifiers.
get fun supported_interfaces(): WhalesPoolSupportedInterfacesReply {
    throw 0;
}
