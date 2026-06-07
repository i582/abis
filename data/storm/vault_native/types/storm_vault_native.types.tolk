/// Storm Trade native vault interface.
contract StormVaultNative {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade native vault for TON deposits, direct callbacks, withdrawals, staking, and public getters."
    storage: StormVaultNativeStorage
    incomingMessages: StormVaultNativeIncomingMessage
    outgoingMessages: StormVaultNativeOutgoingMessage
}

/// Runtime vault storage with optional trailing pause state.
struct StormVaultNativeStorage {
    /// Vault Jetton wallet or native-account companion address stored in slot 0.
    jettonWallet: address
    /// Accounting rate used by LP mint/burn logic.
    rate: uint64
    /// Total LP supply tracked by the vault.
    totalSupply: coins
    /// Free vault balance available for positions/withdrawals.
    freeBalance: coins
    /// Balance locked by open positions.
    lockedBalance: coins
    /// Buffer balance stored as uint64 and exposed by get_buffer_data.
    bufferBalance: uint64
    /// Balance accrued for stakers.
    stakersBalance: coins
    /// Balance accrued for executors.
    executorsBalance: coins
    /// Protocol addresses keyed by four-bit protocol slot.
    protocolAddresses: map<uint4, address>
    /// Referenced buffer rates cell.
    bufferRates: Cell<StormVaultNativeBufferRates>
    /// Asset decimals used for precision scaling.
    decimals: uint4
    /// Optional trailing compatibility bit; parse manually as v3_paused when present.
    tail: RemainingBitsAndRefs
}

/// Referenced buffer-rate data read by get_buffer_data.
struct StormVaultNativeBufferRates {
    /// Target buffer reserve rate used by buffer accounting.
    bufferRate: coins
    /// Lower buffer threshold rate.
    bufferUnderRate: coins
    /// Upper buffer threshold rate.
    bufferOverRate: coins
}

/// Need-key-init variant carrying user public keys.
struct (0b1) StormNeedKeyInit {
    /// Dictionary of user public keys passed to smart-account deployment.
    userPublicKeys: map<uint256, cell>
}

/// Empty no-key-init variant.
struct (0b0) StormNoKeyInit {}

/// Key-initialization request embedded in native deposit payloads.
type StormInitializationRequest =
    | StormNeedKeyInit
    | StormNoKeyInit

/// Referral payout data forwarded to referral collection/items.
struct ReferralData {
    /// Referral amount to withdraw or distribute.
    amount: coins
    /// Referral item index used for destination lookup.
    index: uint32
}

/// Executor payout data forwarded to executor collection/items.
struct ExecutorData {
    /// Whether executor rewards are split by downstream executor logic.
    splitExecutorRewards: bool
    /// Executor amount to withdraw or distribute.
    amount: coins
    /// Executor item index used for destination lookup.
    index: uint32
}

/// Per-referrer split entry inside trade_notification_v2.
struct ReferrerData {
    /// Referrer smart-account address receiving the split.
    referrerAddress: address
    /// Referrer share part encoded as an 8-bit value.
    referrerPart: uint8
}

/// Position snapshot forwarded by trade notification payloads.
struct PositionData {
    /// Signed position size.
    size: int128
    /// Opaque direction cell preserved from position/VAMM payloads.
    direction: cell
    /// Position margin amount.
    margin: coins
    /// Open notional value for the position.
    openNotional: coins
    /// Last cumulative premium value recorded for funding.
    lastUpdatedCumulativePremium: int64
    /// Fee value encoded as uint32 in the position snapshot.
    fee: uint32
    /// Discount value encoded as uint32 in the position snapshot.
    discount: uint32
    /// Rebate value encoded as uint32 in the position snapshot.
    rebate: uint32
    /// Unix timestamp of the latest position update.
    lastUpdatedTimestamp: uint32
}

/// Notification payload referenced from trade/referral/update messages.
struct NotificationPayloadV2 {
    /// Original bundle sender address.
    bundleSenderAddress: address
    /// Balance delta associated with the notification.
    balanceDelta: coins
    /// VAMM address associated with the notification.
    ammAddress: address
    /// Opaque direction cell forwarded with the notification.
    direction: cell
    /// Optional referenced position snapshot.
    positionData: Cell<PositionData>?
}

/// Native TON deposit body.
struct (0x29bb3721) StormDepositNative {
    /// Native deposit query id.
    queryId: uint64
    /// Native TON amount declared in the body.
    amount: coins
    /// Receiver smart-account owner address.
    receiverAddress: address
    /// Whether key initialization data follows.
    init: bool
    /// Key initialization union selected by the init flag/tag.
    keyInit: StormInitializationRequest
}

/// Native vault staking request.
struct (0xc89a3ee4) StormVaultStake {
    /// Native TON amount to stake.
    amount: coins
}

/// Referral amount withdrawal request.
struct (0xf5d4eb52) StormWithdrawReferralAmount {
    /// Referral item index encoded by the requester.
    index: uint64
    /// Referral amount requested for withdrawal.
    referralAmount: coins
    /// Owner address authorized for the referral item.
    ownerAddr: address
}

/// Executor amount withdrawal request.
struct (0x2cde6351) StormWithdrawExecutorAmount {
    /// Executor item index encoded by the requester.
    index: uint64
    /// Executor amount requested for withdrawal.
    executorAmount: coins
    /// Owner address authorized for the executor item.
    ownerAddr: address
}

/// User LP unstake request.
struct (0xd5b5e9ad) StormVaultUnstake {
    /// LP jetton amount to burn/redeem.
    jettonAmount: coins
    /// User address receiving the unstake flow result.
    userAddress: address
}

/// Legacy trade notification body.
struct (0x3475fdd2) StormVaultTradeNotification {
    /// VAMM asset index for the trade accounting update.
    ammIndex: uint16
    /// Signed free-balance delta.
    freeAmount: int64
    /// Signed locked-balance delta.
    lockedAmount: int64
    /// Signed exchange amount delta.
    exchangeAmount: int64
    /// Locked amount released for withdrawal.
    withdrawLockedAmount: uint64
    /// Fee amount credited to stakers.
    feeToStakers: uint64
    /// Amount withdrawn to the trader destination.
    withdrawAmount: uint64
    /// Trader smart-account address.
    traderAddr: address
    /// Destination address for withdrawn funds.
    withdrawDestination: address
    /// Optional referenced referral payout data.
    referralParams: Cell<ReferralData>?
    /// Optional referenced executor payout data.
    executorParams: Cell<ExecutorData>?
}

/// Deposit revert callback from downstream contracts.
struct (0x5b27f9c5) StormDepositRevert {
    /// Original deposit query id.
    queryId: uint64
    /// Amount being reverted.
    amount: coins
    /// Address that sent the failed deposit flow.
    senderAddress: address
    /// Owner address associated with the reverted deposit.
    ownerAddress: address
}

/// Withdraw request callback from position/vamm flow.
struct (0x512cbd25) StormWithdrawRequest {
    /// Withdraw request query id.
    queryId: uint64
    /// Amount requested for withdrawal.
    amount: coins
    /// Owner address associated with the withdraw request.
    ownerAddress: address
}

/// V2 trade accounting callback from VAMM/position flow.
struct (0x28d36491) StormTradeNotificationV2 {
    /// Trade notification query id.
    queryId: uint64
    /// Asset/VAMM index for the trade.
    assetId: uint16
    /// Signed free-balance delta.
    freeAmount: int64
    /// Signed locked-balance delta.
    lockedAmount: int64
    /// Signed exchange amount delta.
    exchangeAmount: int64
    /// Locked amount released for withdrawal.
    withdrawLockedAmount: uint64
    /// Fee amount credited to stakers.
    feeToStakers: uint64
    /// Executor amount credited by the trade.
    executorAmount: uint64
    /// Total referral amount credited by the trade.
    totalReferrerAmount: uint64
    /// Number of referral split entries in referralData.
    refCount: uint4
    /// Hashmap keyed by 4-bit referral slot with referrer split data.
    referralData: map<uint4, ReferrerData>
    /// Smart-account address associated with the trade notification.
    saAddress: address
    /// Referenced V2 notification payload.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// Failed bundle callback; nested direction/intent are forwarded opaque by the vault.
@overflow1023_policy("suppress")
struct (0x666392ee) StormFailedBundleExecution {
    /// Failed bundle query id.
    queryId: uint64
    /// Asset/VAMM index for the failed bundle.
    assetId: uint16
    /// Downstream bundle execution error code.
    errorCode: uint16
    /// Amount spent before the bundle failed.
    spentAmount: coins
    /// Smart-account address associated with the failed bundle.
    saAddress: address
    /// VAMM address associated with the failed bundle.
    ammAddress: address
    /// Opaque direction cell forwarded from the failed bundle.
    direction: cell
    /// Original bundle sender address.
    bundleSenderAddress: address
    /// Opaque bundle intent cell forwarded on failure.
    intent: cell
}

/// V3 pause/unpause toggle message.
struct (0x3e56c929) StormChangeV3State {
    /// Admin toggle query id.
    queryId: uint64
}

/// Deposit notification sent to smart account/position flow.
struct (0x186b2edf) StormDepositNotify {
    /// Deposit notification query id.
    queryId: uint64
    /// Deposited amount.
    amount: coins
    /// Original deposit sender address.
    senderAddress: address
    /// Vault asset jetton minter address.
    jettonMinterAddress: address
}

/// Notify-with-deploy message sent when key initialization is requested.
struct (0x5a89f5a2) StormNotifyWithDeploy {
    /// Deploy notification query id.
    queryId: uint64
    /// Deposited amount forwarded with deployment.
    amount: coins
    /// Dictionary of user public keys for smart-account deployment.
    userPublicKeys: map<uint256, cell>
    /// Original deposit sender address.
    senderAddress: address
    /// Owner address for the deployed smart account.
    ownerAddress: address
}

/// Failure notification for bundle execution.
@overflow1023_policy("suppress")
struct (0x367f2743) StormFailNotification {
    /// Failure notification query id.
    query: uint64
    /// Amount spent before failure.
    spentAmount: coins
    /// Vault asset jetton minter address.
    jettonMinterAddress: address
    /// VAMM address associated with the failure.
    ammAddress: address
    /// Opaque direction cell forwarded with the failure.
    direction: cell
    /// Original bundle sender address.
    bundleSenderAddress: address
    /// Opaque bundle intent cell.
    intent: cell
}

/// Request to provide a position to downstream position logic.
struct (0x8865b402) StormProvidePosition {
    /// Order type selector encoded in 4 bits.
    orderType: uint4
    /// Order index encoded in 3 bits.
    orderIndex: uint3
    /// Direction flag encoded in 1 bit.
    direction: uint1
    /// Executor index associated with the order.
    executorIndex: uint32
    /// Opaque oracle payload cell.
    oraclePayload: cell
}

/// Referral-fee outgoing message.
struct (0x4fedc82b) StormReferralFees {
    /// Referral fee query id.
    queryId: uint64
    /// Referral smart-account address.
    referralSaAddress: address
    /// Referral fee amount.
    amount: coins
    /// Vault asset jetton minter address.
    jettonMinterAddress: address
    /// Referenced V2 notification payload.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// Executor amount addition emitted to executor item contracts.
struct (0x5dd66579) StormAddExecutorAmount {
    /// Amount credited to the executor item balance for the sender vault.
    referralAmount: coins
    /// Address receiving acknowledgement or excess value.
    originAddr: address
}

/// Referral amount addition emitted to referral item contracts.
struct (0x84dced7a) StormAddReferralAmount {
    /// Amount credited to the referral item balance for the sender vault.
    referralAmount: coins
    /// Address receiving acknowledgement or excess value.
    originAddr: address
}

/// VAMM initialization message sent by admin branches.
struct (0x29c102d1) StormVammInit {
    /// Redirect destination address used by VAMM initialization.
    redirectAddr: address
    /// VAMM code cell.
    code: cell
    /// VAMM data cell.
    data: cell
}

/// Unsuccessful deposit callback.
struct (0x6cde12e2) StormUnsuccessfulDeposit {
    /// Original deposit query id.
    queryId: uint64
}

/// Successful withdraw callback.
struct (0x20d835c2) StormWithdrawSuccess {
    /// Original withdraw query id.
    queryId: uint64
}

/// Position update notification.
struct (0x1ca43d2f) StormNotifyUpdatePosition {
    /// Position update query id.
    queryId: uint64
    /// Vault asset jetton minter address.
    jettonMinterAddress: address
    /// Referenced V2 notification payload.
    notificationPayload: Cell<NotificationPayloadV2>
}

/// LP mint request sent by vault stake flows.
struct (0x1674b0a0) StormMintJettons {
    /// LP mint query id.
    queryId: uint64
    /// LP jetton amount to mint.
    amount: coins
    /// Owner address receiving minted LP jettons.
    ownerAddress: address
}

/// Standard excess body.
struct (0xd53276db) StormExcess {
    /// Excess message query id.
    queryId: uint64
}

/// Incoming internal message bodies accepted directly by the native vault.
type StormVaultNativeIncomingMessage =
    | StormDepositNative
    | StormWithdrawReferralAmount
    | StormWithdrawExecutorAmount
    | StormVaultStake
    | StormVaultUnstake
    | StormVaultTradeNotification
    | StormDepositRevert
    | StormWithdrawRequest
    | StormTradeNotificationV2
    | StormFailedBundleExecution
    | StormChangeV3State

/// Outgoing internal message bodies emitted by the native vault.
type StormVaultNativeOutgoingMessage =
    | StormDepositNotify
    | StormNotifyWithDeploy
    | StormFailNotification
    | StormProvidePosition
    | StormReferralFees
    | StormAddExecutorAmount
    | StormAddReferralAmount
    | StormVammInit
    | StormUnsuccessfulDeposit
    | StormWithdrawSuccess
    | StormNotifyUpdatePosition
    | StormMintJettons
    | StormExcess

/// Return tuple for get_vault_data.
struct GetVaultDataReply {
    /// Vault companion wallet/account address stored by the native vault.
    jettonWallet: address
    /// Accounting rate used by LP mint/burn logic.
    rate: uint64
    /// Total LP supply tracked by the vault.
    totalSupply: coins
    /// Free vault balance available for positions/withdrawals.
    freeBalance: coins
    /// Balance locked by open positions.
    lockedBalance: coins
    /// Buffer balance exposed as uint64 by the getter.
    bufferBalance: uint64
    /// Balance accrued for stakers.
    stakersBalance: coins
    /// Balance accrued for executors.
    executorsBalance: coins
    /// V3 pause flag decoded from the optional storage tail.
    v3Paused: bool
}

/// Return tuple for get_buffer_data.
struct GetBufferDataReply {
    /// Current buffer balance exposed by storage.
    bufferBalance: uint64
    /// Target buffer reserve rate.
    bufferRate: coins
    /// Lower buffer threshold rate.
    bufferUnderRate: coins
    /// Upper buffer threshold rate.
    bufferOverRate: coins
}

/// Native vault exit codes.
enum Errors {
    /// Sender is not the authenticated jetton wallet or native companion.
    InvalidJetton = 100
    /// Amount does not satisfy the expected message amount.
    InvalidJettonAmount = 101
    /// Message value is insufficient for the requested operation.
    NotEnoughGas = 102
    /// Sender or computed address is not the expected position address.
    WrongPositionAddress = 103
    /// Sender or configured address is not an authorized VAMM.
    NotAVamm = 104
    /// Sender is not the LP minter.
    NotALpMinter = 106
    /// Sender is not an admin address.
    NotAnAdmin = 107
    /// Referral item address does not match the expected referral item.
    WrongReferralItem = 108
    /// Executor item address does not match the expected executor item.
    WrongExecutorItem = 109
    /// Sender is not the configured batch operator.
    NotABatchOp = 110
    /// Buffer parameter update failed validation.
    WrongBufferParams = 111
    /// Sender is not the configured claimer address.
    NotAClaimer = 112
    /// Jetton minter protocol address is absent.
    JettonMinterNotFound = 113
    /// Smart-account factory protocol address is absent.
    SmartAccountFactoryNotFound = 114
    /// Key initialization is not allowed for this deposit branch.
    KeysSetupNotAllowed = 115
    /// V3 operations are paused.
    V3Paused = 116
    /// Key dictionary failed validation.
    InvalidKeysDict = 117
    /// Operation opcode is unsupported.
    WrongOperation = 65535
}

/// Returns raw vault contract data cell used by off-chain integrations.
get fun get_vault_contract_data(): cell {
    throw 0;
}

/// Returns the main vault accounting tuple and V3 pause flag.
get fun get_vault_data(): GetVaultDataReply {
    throw 0;
}

/// Returns current buffer balance and configured buffer rates.
get fun get_buffer_data(): GetBufferDataReply {
    throw 0;
}

/// Returns the protocol-address dictionary used for whitelist lookups.
get fun get_vault_whitelisted_addresses(): map<uint4, address> {
    throw 0;
}

/// Computes the position contract address for a trader and VAMM pair.
get fun get_position_address(traderAddress: address, vammAddress: address): address {
    throw 0;
}

/// Returns the configured VAMM address for an asset index.
get fun get_vamm_address(assetIndex: int): address {
    throw 0;
}

/// Returns the configured LP minter address.
get fun get_lp_minter_address(): address {
    throw 0;
}

/// Computes or returns the referral item address for an item index.
get fun get_referral_item_addr(referralIndex: int): address {
    throw 0;
}

/// Computes or returns the executor item address for an item index.
get fun get_executor_item_addr(executorIndex: int): address {
    throw 0;
}

/// Returns the configured referral collection address.
get fun get_referral_collection_address(): address {
    throw 0;
}

/// Returns the configured executor collection address.
get fun get_executor_collection_address(): address {
    throw 0;
}

/// Returns the configured claimer address.
get fun get_claimer_address(): address {
    throw 0;
}

/// Returns the latest position manager code cell.
get fun get_last_position_manager_code(): cell {
    throw 0;
}

/// Returns the vault type discriminator for the native vault.
get fun get_vault_type(): uint32 {
    throw 0;
}
