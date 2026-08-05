/// Ton Whales liquid-staking pool and wsTON Jetton master interface.
contract WhalesLiquidStaking {
    author: "Ton Whales"
    version: "b6e75696"
    description: "Ton Whales liquid-staking pool accounting and wsTON exchange-rate interface."
    storage: WhalesLiquidStakingStorage
    incomingMessages: WhalesLiquidStakingIncomingMessage
    outgoingMessages: WhalesLiquidStakingOutgoingMessage
    forceAbiExport: WhalesLiquidStakingForceExport
    thrownErrors: WhalesLiquidStakingErrors
}

/// Pool GRAM balances stored in their runtime accounting cell.
struct WhalesLiquidStakingBalances {
    /// Total pool-owned GRAM balance in nanograms.
    balance: coins
    /// GRAM currently sent to validator proxies in nanograms.
    balanceSent: coins
    /// GRAM reserved for completed withdrawal payouts in nanograms.
    balanceWithdraw: coins
    /// GRAM pending withdrawal processing in nanograms.
    balancePendingWithdraw: coins
}

/// Embedded wsTON Jetton-minter state.
struct WhalesLiquidStakingMinter {
    /// Total wsTON supply in token nanounits.
    totalSupply: coins
    /// TEP-64 wsTON metadata content.
    content: cell
    /// Code used to derive wsTON Jetton wallets.
    walletCode: cell
}

/// Validator-proxy state stored as a one-bit-keyed dictionary value.
struct WhalesLiquidStakingProxyState {
    /// Validation round start timestamp.
    stakeAt: uint32
    /// Raw end timestamp of the validation lock.
    stakeUntil: uint32
    /// GRAM sent through this proxy to Elector in nanograms.
    stakeSent: coins
    /// Active Elector request query id, or zero when no request is pending.
    storedQueryId: uint64
    /// Active Elector request opcode, or zero when no request is pending.
    storedQueryOp: uint32
    /// GRAM associated with the active Elector request in nanograms.
    storedQueryStake: coins
    /// Optional fields appended by later proxy-state revisions.
    tail: RemainingBitsAndRefs
}

/// Optional fields appended after the base proxy-state fields.
struct WhalesLiquidStakingProxyStateTail {
    /// Configured duration of the validator stake hold.
    stakeHeldFor: uint32
    /// True after the validator lock interval is finalized.
    stakeLockFinal: bool
}

/// Pool proxy registry and validator-proxy state dictionary.
struct WhalesLiquidStakingProxies {
    /// Storage revision tag for the proxy registry.
    revision: uint8
    /// Address of validator proxy slot zero.
    proxyZero: address
    /// Address of validator proxy slot one.
    proxyOne: address
    /// Validator-proxy states keyed by slot number zero or one.
    proxies: map<uint1, WhalesLiquidStakingProxyState>
}

/// Runtime operation parameters stored in the trailing parameter cell.
struct WhalesLiquidStakingParams {
    /// True when public deposit and withdrawal operations are enabled.
    enabled: bool
    /// True when owner-controlled parameter and code updates are enabled.
    updatesEnabled: bool
    /// Minimum accepted deposit in nanograms.
    minStake: coins
    /// Deposit processing fee in nanograms.
    depositFee: coins
    /// Withdrawal processing fee in nanograms.
    withdrawFee: coins
    /// Pool fee measured in protocol fee units.
    poolFee: coins
    /// GRAM reserved for an operation receipt in nanograms.
    receiptPrice: coins
}

/// Persistent Whales liquid-staking pool and wsTON-minter state.
struct WhalesLiquidStakingStorage {
    /// Pool owner and wsTON Jetton administrator.
    owner: address
    /// Pool controller address.
    controller: address
    /// Start timestamp of the last processed election.
    lastElectionId: uint32
    /// Current pool accounting round id.
    roundId: uint32
    /// Previous-round per-coin profit accumulator.
    previousRoundProfitPerCoin: coins
    /// Referenced pool GRAM balances.
    balances: Cell<WhalesLiquidStakingBalances>
    /// Referenced wsTON Jetton-minter state.
    minter: Cell<WhalesLiquidStakingMinter>
    /// Referenced validator-proxy registry.
    proxyRegistry: Cell<WhalesLiquidStakingProxies>
    /// Optional trailing reference containing `WhalesLiquidStakingParams`.
    paramsTail: RemainingBitsAndRefs
}

/// Opcode-zero text command accepted by the public and owner dispatchers.
struct (0x00000000) WhalesLiquidStakingTextCommand {
    /// UTF-8 command and command-specific arguments after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Public GRAM deposit that mints wsTON to a selected owner.
struct (0x7bcd1fef) WhalesLiquidStakingDeposit {
    /// Caller-selected identifier copied to the wsTON internal transfer.
    queryId: uint64
    /// GRAM principal credited to the pool in nanograms.
    amount: coins
    /// Owner whose deterministic wsTON wallet receives the minted tokens.
    responseAddress: address?
    /// Nanograms forwarded by the receiving wsTON wallet.
    forwardTonAmount: coins
    /// Raw optional notification payload forwarded to the wsTON owner.
    forwardPayload: RemainingBitsAndRefs
}

/// Public wsTON withdrawal request sent to the caller's deterministic wallet.
struct (0xda803efd) WhalesLiquidStakingWithdraw {
    /// Caller-selected identifier copied to the wsTON burn request.
    queryId: uint64
    /// wsTON amount to burn in token nanounits.
    jettonAmount: coins
    /// Address that receives withdrawal receipts and the final GRAM payout.
    responseAddress: address?
}

/// Public request to collect GRAM prepared for an earlier withdrawal round.
struct (0x4a10e022) WhalesLiquidStakingCollect {
    /// Caller-selected identifier copied to the wallet debt request.
    queryId: uint64
    /// Address that receives a delayed or completed withdrawal receipt.
    responseAddress: address?
}

/// Completion callback sent by a wsTON wallet after it resolves withdrawal debt.
struct (0x9797f0fb) WhalesLiquidStakingWalletWithdrawal {
    /// Wallet-selected identifier copied to the pool receipt.
    queryId: uint64
    /// GRAM amount released by the wallet in nanograms.
    amount: coins
    /// Pool round whose debt was resolved.
    roundId: uint32
    /// Address that receives the released GRAM.
    responseAddress: address
}

/// TEP-74 burn notification sent by the deterministic wsTON wallet.
struct (0x7bdd97de) WhalesLiquidStakingBurnNotification {
    /// Query identifier copied from the wsTON burn request.
    queryId: uint64
    /// Burned wsTON amount in token nanounits.
    jettonAmount: coins
    /// Owner address used to authenticate the notifying wallet.
    ownerAddress: address
    /// Address recorded for the later GRAM withdrawal payout.
    responseAddress: address
}

/// TEP-89 request for a deterministic wsTON wallet address.
struct (0x2c76b973) WhalesLiquidStakingProvideWalletAddress {
    /// Caller-selected identifier copied to the wallet-address response.
    queryId: uint64
    /// Owner whose deterministic wsTON wallet is requested.
    ownerAddress: address
    /// True when the response must include the owner address by reference.
    includeOwnerAddress: bool
}

/// Request for current pool GRAM and wsTON supplies.
struct (0xad83913f) WhalesLiquidStakingProvideCurrentQuote {
    /// Caller-selected identifier copied to the quote response.
    queryId: uint64
    /// Optional payload returned unchanged in the quote response.
    customPayload: cell?
}

/// Controller command that sends validator stake through one proxy slot.
struct (0xa2065f2c) WhalesLiquidStakingStakeSend {
    /// Controller-selected identifier copied to the Elector request.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Validator proxy slot: false for zero, true for one.
    proxyId: bool
    /// GRAM stake value sent to Elector.
    stake: coins
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp forwarded to Elector.
    stakeAt: uint32
    /// Elector maximum-factor value.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddress: bits256
    /// Validator signature encoded by reference.
    signature: Cell<bits512>
}

/// Controller or owner command that starts Elector stake recovery.
struct (0x654d518e) WhalesLiquidStakingStakeRecover {
    /// Authorized sender's identifier copied to the recover request.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Validator proxy slot: false for zero, true for one.
    proxyId: bool
}

/// Controller command that finalizes a selected proxy's validator lock.
struct (0x1596920c) WhalesLiquidStakingStakeLockFinalize {
    /// Controller-selected request identifier.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Validator proxy slot: false for zero, true for one.
    proxyId: bool
}

/// Controller or owner command that withdraws GRAM not owned by wsTON holders.
struct (0x251d6a98) WhalesLiquidStakingWithdrawUnowned {
    /// Authorized sender's identifier copied to the response.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
}

/// Owner initialization marker accepted as a no-op after value and gas checks.
struct (0x0822d8ae) WhalesLiquidStakingDeploy {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
}

/// Owner command that replaces the pool code cell.
struct (0xdbfaf817) WhalesLiquidStakingUpgrade {
    /// Owner-selected identifier copied to the upgrade receipt.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Referenced replacement TVM code cell.
    code: cell
}

/// Owner command that replaces runtime operation parameters.
struct (0x023cd52c) WhalesLiquidStakingUpdateParams {
    /// Owner-selected identifier copied to the update receipt.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Referenced replacement runtime parameters.
    params: Cell<WhalesLiquidStakingParams>
}

/// Owner command that distributes attached GRAM as pool profit.
struct (0x47bbe425) WhalesLiquidStakingAirdrop {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
}

/// Owner command that replaces the owner or controller address.
struct (0x90eafae1) WhalesLiquidStakingChangeAddress {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Address slot: zero for owner, one for controller.
    addressId: uint8
    /// Replacement address for the selected slot.
    newAddress: address
}

/// Owner command that replaces wsTON metadata content.
struct (0xa2481e8e) WhalesLiquidStakingSetContent {
    /// Owner-selected request identifier.
    queryId: uint64
    /// Gas budget imposed before processing the command.
    gasLimit: coins
    /// Referenced replacement TEP-64 metadata content.
    content: cell
}

/// Elector confirmation received after a new-stake request.
struct (0xf374484c) WhalesLiquidStakingElectorNewStakeConfirmation {
    /// Identifier copied from the Elector new-stake request.
    queryId: uint64
    /// Elector confirmation comment field.
    comment: uint32
}

/// Elector failure response received after a new-stake request.
struct (0xee6f454c) WhalesLiquidStakingElectorNewStakeError {
    /// Identifier copied from the Elector new-stake request.
    queryId: uint64
    /// Elector failure reason code.
    reason: uint32
    /// Remaining Elector response payload.
    tail: RemainingBitsAndRefs
}

/// Elector response received after a recover-stake request.
struct (0xf96f7324) WhalesLiquidStakingElectorRecoverStakeResponse {
    /// Identifier copied from the Elector recover request.
    queryId: uint64
}

/// Unambiguous internal message bodies accepted by the pool dispatcher.
type WhalesLiquidStakingIncomingMessage =
    | WhalesLiquidStakingTextCommand
    | WhalesLiquidStakingDeposit
    | WhalesLiquidStakingWithdraw
    | WhalesLiquidStakingCollect
    | WhalesLiquidStakingWalletWithdrawal
    | WhalesLiquidStakingBurnNotification
    | WhalesLiquidStakingProvideWalletAddress
    | WhalesLiquidStakingProvideCurrentQuote
    | WhalesLiquidStakingStakeSend
    | WhalesLiquidStakingStakeRecover
    | WhalesLiquidStakingStakeLockFinalize
    | WhalesLiquidStakingWithdrawUnowned
    | WhalesLiquidStakingDeploy
    | WhalesLiquidStakingUpgrade
    | WhalesLiquidStakingUpdateParams
    | WhalesLiquidStakingAirdrop
    | WhalesLiquidStakingChangeAddress
    | WhalesLiquidStakingSetContent
    | WhalesLiquidStakingElectorNewStakeConfirmation
    | WhalesLiquidStakingElectorNewStakeError
    | WhalesLiquidStakingElectorRecoverStakeResponse

/// wsTON wallet internal transfer emitted after a deposit or accounting reward.
struct (0x178d4519) WhalesLiquidStakingInternalTransfer {
    /// Identifier copied from the triggering deposit or internal accounting action.
    queryId: uint64
    /// Newly minted wsTON amount in token nanounits.
    jettonAmount: coins
    /// Pool address reported as the transfer source.
    from: address
    /// Address that receives excess GRAM, or `addr_none` for accounting mints.
    responseAddress: address?
    /// Nanograms forwarded to the receiving owner.
    forwardTonAmount: coins
    /// Optional raw forward payload; exact no-payload branches leave this tail empty.
    forwardPayload: RemainingBitsAndRefs
}

/// Elector new-stake request emitted through a selected proxy.
struct (0x4e73744b) WhalesLiquidStakingElectorNewStake {
    /// Identifier copied from the controller stake-send command.
    queryId: uint64
    /// Validator public key forwarded to Elector.
    validatorPubkey: bits256
    /// Validation round start timestamp forwarded to Elector.
    stakeAt: uint32
    /// Elector maximum-factor value.
    maxFactor: uint32
    /// Validator ADNL address forwarded to Elector.
    adnlAddress: bits256
    /// Validator signature encoded by reference.
    signature: Cell<bits512>
}

/// Elector recover-stake request emitted through a selected proxy.
struct (0x47657424) WhalesLiquidStakingElectorRecoverStakeRequest {
    /// Identifier of the active Elector query.
    queryId: uint64
}

/// wsTON burn request sent to the caller's deterministic wallet.
struct (0x595f07bc) WhalesLiquidStakingJettonBurn {
    /// Identifier copied from the withdrawal request.
    queryId: uint64
    /// wsTON amount to burn in token nanounits.
    jettonAmount: coins
    /// Address that receives the burn notification and final GRAM payout.
    responseAddress: address?
}

/// Request for withdrawal debt held by a wsTON wallet for a pool round.
struct (0x9006210c) WhalesLiquidStakingProvideDebt {
    /// Identifier copied from the collect request.
    queryId: uint64
    /// Pool round whose withdrawal debt is requested.
    roundId: uint32
}

/// Pool acknowledgement that records GRAM debt after a wsTON burn.
struct (0x2334e467) WhalesLiquidStakingBurnResponse {
    /// Identifier copied from the burn notification.
    queryId: uint64
    /// Pool round in which the withdrawal was recorded.
    roundId: uint32
    /// GRAM amount assigned to the withdrawal in nanograms.
    withdrawalAmount: coins
    /// Address that receives the later GRAM payout.
    responseAddress: address
}

/// Delayed-withdrawal receipt emitted when GRAM is not ready for collection.
struct (0x74bb3427) WhalesLiquidStakingWithdrawalDelayed {
    /// Identifier copied from the withdrawal or collect request.
    queryId: uint64
}

/// Completed-withdrawal receipt emitted with the released GRAM.
struct (0x23d421e1) WhalesLiquidStakingWithdrawalCompleted {
    /// Identifier copied from the wallet callback.
    queryId: uint64
}

/// TEP-89 wallet-address response emitted to a requester.
struct (0xd1735400) WhalesLiquidStakingTakeWalletAddress {
    /// Identifier copied from the discovery request.
    queryId: uint64
    /// Deterministic wsTON wallet address, or `addr_none` outside workchain zero.
    walletAddress: address?
    /// Optional referenced owner address when requested by the caller.
    ownerAddress: Cell<address>?
}

/// Current GRAM and wsTON supply quote emitted to a requester.
struct (0x0a420458) WhalesLiquidStakingTakeCurrentQuote {
    /// Identifier copied from the quote request.
    queryId: uint64
    /// GRAM available to back wsTON, encoded as an unsigned 128-bit integer.
    tonTotalSupply: uint128
    /// Current wsTON supply encoded as an unsigned 128-bit integer.
    jettonTotalSupply: uint128
    /// Optional payload copied from the request.
    customPayload: cell?
}

/// Upgrade receipt emitted to the owner after code replacement.
struct (0x532e4077) WhalesLiquidStakingUpgradeResponse {
    /// Identifier copied from the upgrade request.
    queryId: uint64
}

/// Parameter-update receipt emitted to the owner.
struct (0x3211546a) WhalesLiquidStakingUpdateParamsResponse {
    /// Identifier copied from the update request.
    queryId: uint64
}

/// Unowned-withdrawal receipt emitted to the owner or controller.
struct (0x1d1715bf) WhalesLiquidStakingWithdrawUnownedResponse {
    /// Identifier copied from the withdrawal request.
    queryId: uint64
}

/// Internal body-bearing messages emitted by pool send sites.
type WhalesLiquidStakingOutgoingMessage =
    | WhalesLiquidStakingInternalTransfer
    | WhalesLiquidStakingElectorNewStake
    | WhalesLiquidStakingElectorRecoverStakeRequest
    | WhalesLiquidStakingJettonBurn
    | WhalesLiquidStakingProvideDebt
    | WhalesLiquidStakingBurnResponse
    | WhalesLiquidStakingWithdrawalDelayed
    | WhalesLiquidStakingWithdrawalCompleted
    | WhalesLiquidStakingTakeWalletAddress
    | WhalesLiquidStakingTakeCurrentQuote
    | WhalesLiquidStakingUpgradeResponse
    | WhalesLiquidStakingUpdateParamsResponse
    | WhalesLiquidStakingWithdrawUnownedResponse

/// Owner deposit variant, whose dispatcher consumes a gas limit before public fields.
struct (0x7bcd1fef) WhalesLiquidStakingOwnerDeposit {
    queryId: uint64
    gasLimit: coins
    amount: coins
    responseAddress: address?
    forwardTonAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

/// Owner withdrawal variant, whose dispatcher consumes a gas limit before public fields.
struct (0xda803efd) WhalesLiquidStakingOwnerWithdraw {
    queryId: uint64
    gasLimit: coins
    jettonAmount: coins
    responseAddress: address?
}

/// Owner collection variant, whose dispatcher consumes a gas limit before public fields.
struct (0x4a10e022) WhalesLiquidStakingOwnerCollect {
    queryId: uint64
    gasLimit: coins
    responseAddress: address?
}

/// ABI declarations exported outside opcode unions because sender-specific owner variants
/// intentionally share their public message opcodes.
type WhalesLiquidStakingForceExport =
    | WhalesLiquidStakingParams
    | WhalesLiquidStakingProxyStateTail
    | WhalesLiquidStakingOwnerDeposit
    | WhalesLiquidStakingOwnerWithdraw
    | WhalesLiquidStakingOwnerCollect

/// Configured validator proxy addresses returned by `get_proxies`.
struct WhalesLiquidStakingProxiesReply {
    /// Validator proxy slot zero.
    proxyZero: address
    /// Validator proxy slot one.
    proxyOne: address
}

/// Standard TEP-74 Jetton master data returned by `get_jetton_data`.
struct WhalesLiquidStakingJettonDataReply {
    /// Total issued wsTON supply in token nanounits.
    totalSupply: int
    /// True because deposits and accounting rewards may mint wsTON.
    mintable: bool
    /// Pool owner acting as the wsTON Jetton administrator.
    adminAddress: address
    /// TEP-64 wsTON metadata content.
    jettonContent: cell
    /// Code used to derive deterministic wsTON wallets.
    jettonWalletCode: cell
}

/// Current deposit and withdrawal exchange rates.
struct WhalesLiquidStakingRatesReply {
    /// Projected wsTON minted per one GRAM deposit, scaled by `1e9`.
    depositRate: int
    /// GRAM returned per one wsTON withdrawal, scaled by `1e9`.
    withdrawRate: int
}

/// Supported TEP-89 interface identifiers.
struct WhalesLiquidStakingSupportedInterfacesReply {
    /// TEP-89 introspection interface identifier.
    introspection: uint128
    /// Discoverable Jetton master interface identifier.
    discoverableJettonMaster: uint128
}

/// Runtime operation parameters returned by `get_params`.
struct WhalesLiquidStakingParamsReply {
    /// True when public deposits and withdrawals are enabled.
    enabled: bool
    /// True when owner parameter and code updates are enabled.
    updatesEnabled: bool
    /// Minimum accepted deposit in nanograms.
    minStake: coins
    /// Deposit processing fee in nanograms.
    depositFee: coins
    /// Withdrawal processing fee in nanograms.
    withdrawFee: coins
    /// Pool fee measured in protocol fee units.
    poolFee: coins
    /// GRAM reserved for an operation receipt in nanograms.
    receiptPrice: coins
}

/// Validator-proxy status returned by `get_staking_status`.
struct WhalesLiquidStakingStatusReply {
    /// Validation round start timestamp.
    stakeAt: uint32
    /// Timestamp after which the active stake can be recovered.
    stakeUntil: uint32
    /// GRAM sent through the selected proxy in nanograms.
    stakeSent: coins
    /// True while an Elector query is pending.
    querySent: bool
    /// True when the active stake can be unlocked at the current time.
    canUnlock: bool
    /// True after the validator lock interval was finalized.
    stakeLockFinal: bool
}

/// Exit codes proven by explicit throw sites in the exact deployed code.
enum WhalesLiquidStakingErrors {
    /// An address failed workchain or deterministic-address validation.
    InvalidAddress = 70
    /// Message body, query, state transition, or operation parameter is invalid.
    InvalidMessage = 72
    /// Sender is not authorized or public staking is disabled.
    AccessDenied = 73
    /// Burn notification did not originate from the deterministic wsTON wallet.
    InvalidBurnNotificationSender = 74
    /// Wallet discovery request did not attach enough value for its response.
    WalletDiscoveryValueTooLow = 75
    /// Attached GRAM value is below the required operation budget.
    TooLowValue = 76
    /// Requested validator stake is larger than the available pool balance.
    InvalidStakeValue = 77
    /// Opcode-zero text command is not recognized.
    UnknownTextCommand = 78
    /// Wallet withdrawal callback exceeds the pool's prepared GRAM balance.
    InvalidWithdrawalAmount = 79
    /// A deterministic address was requested outside workchain zero.
    InvalidWorkchain = 333
    /// Message opcode is not supported by the public dispatcher.
    UnsupportedOperation = 65535
}

/// Complete stack reply returned by `get_pool_status`.
struct WhalesLiquidStakingPoolStatusReply {
    /// Projected wsTON minted per one GRAM deposit, scaled by `1e9`.
    depositRate: int
    /// GRAM returned per one wsTON withdrawal, scaled by `1e9`.
    withdrawRate: int
    /// Current pool accounting round id.
    roundId: int
    /// True when public deposit and withdrawal operations are enabled.
    enabled: bool
    /// True when owner-controlled parameter and code updates are enabled.
    updatesEnabled: bool
    /// Minimum accepted deposit in nanograms.
    minStake: int
    /// Deposit processing fee in nanograms.
    depositFee: int
    /// Withdrawal processing fee in nanograms.
    withdrawFee: int
    /// GRAM reserved for an operation receipt in nanograms.
    receiptPrice: int
    /// Pool fee measured in protocol fee units.
    poolFee: int
    /// Total wsTON supply in token nanounits.
    minterTotalSupply: int
    /// Total pool-owned GRAM balance in nanograms.
    balance: int
    /// GRAM currently sent to validator proxies in nanograms.
    balanceSent: int
    /// GRAM pending withdrawal processing in nanograms.
    balancePendingWithdraw: int
    /// GRAM reserved for completed withdrawal payouts in nanograms.
    balanceWithdraw: int
}

/// Return configured validator proxy addresses.
get fun get_proxies(): WhalesLiquidStakingProxiesReply {
    throw 0;
}

/// Return the pool owner and wsTON administrator.
get fun get_owner(): address {
    throw 0;
}

/// Return pool GRAM currently available for validator staking.
get fun get_available(): coins {
    throw 0;
}

/// Return GRAM held by the account but not owned by wsTON holders.
get fun get_unowned(): coins {
    throw 0;
}

/// Return the deterministic wsTON wallet for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Convert a wsTON amount into its current GRAM backing value.
get fun get_ton_balance(jettonAmount: coins): coins {
    throw 0;
}

/// Return standard wsTON Jetton master data.
get fun get_jetton_data(): WhalesLiquidStakingJettonDataReply {
    throw 0;
}

/// Return current wsTON deposit and withdrawal exchange rates.
get fun get_rates(): WhalesLiquidStakingRatesReply {
    throw 0;
}

/// Return supported TEP-89 interface identifiers.
get fun supported_interfaces(): WhalesLiquidStakingSupportedInterfacesReply {
    throw 0;
}

/// Return runtime operation parameters.
get fun get_params(): WhalesLiquidStakingParamsReply {
    throw 0;
}

/// Return the configured pool controller.
get fun get_controller(): address {
    throw 0;
}

/// Return wsTON exchange rates, round parameters, fees, supply, and pool balances.
get fun get_pool_status(): WhalesLiquidStakingPoolStatusReply {
    throw 0;
}

/// Return validator state for proxy slot zero or one.
get fun get_staking_status(proxyId: int): WhalesLiquidStakingStatusReply {
    throw 0;
}
