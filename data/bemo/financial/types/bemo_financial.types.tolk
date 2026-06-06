/// Bemo v2 Financial liquid-staking jetton minter and pool accounting contract.
contract BemoFinancial {
    author: "Bemo"
    version: "2.0"
    description: "Curated interface for the Bemo v2 Financial bmTON jetton master contract"
    storage: BemoFinancialStorage
    incomingMessages: BemoFinancialIncomingMessage
    outgoingMessages: BemoFinancialOutgoingMessage
    forceAbiExport: BemoFinancialEmptyStake | BemoFinancialLockupData
}

/// Referenced lockup accounting state stored at the end of Financial storage.
struct BemoFinancialLockupData {
    /// Current 36-hour lockup epoch number.
    lastLockupEpoch: uint32
    /// TON amount assigned to requests unlockable in the current epoch.
    lockupSupply: coins
    /// TON amount assigned to requests unlockable in the next epoch.
    nextLockupSupply: coins
    /// TON amount assigned to requests unlockable in later epochs.
    laterLockupSupply: coins
    /// Next sequential Unstake Request index.
    nextUnstakeRequestIndex: uint64
    /// Exotic library-reference code cell used to derive Unstake Request addresses.
    unstakeRequestCode: cell
}

/// Persistent Financial state stored in the root data cell.
@overflow1023_policy("suppress")
struct BemoFinancialStorage {
    /// Total issued bmTON supply encoded as TL-B `Coins`.
    jettonTotalSupply: coins
    /// Total TON pool supply tracked by Bemo, in nanotons.
    tonTotalSupply: coins
    /// Accumulated protocol commission supply, in nanotons.
    commissionTotalSupply: coins
    /// Protocol commission factor in per-mille units.
    commissionFactor: uint16
    /// Address receiving protocol commission withdrawals.
    commissionAddress: address
    /// Admin address authorized for privileged update branches.
    adminAddress: address
    /// Operational transaction address used by privileged transfer branches.
    transactionAddress: address
    /// Referenced bmTON metadata content cell returned by `get_jetton_data`.
    content: cell
    /// Referenced bmTON jetton wallet code cell.
    jettonWalletCode: cell
    /// Referenced lockup accounting and Unstake Request code cell.
    lockupData: Cell<BemoFinancialLockupData>
}

/// Empty incoming body treated as a simple TON stake with query id zero.
struct BemoFinancialEmptyStake {
}

/// Explicit stake request accepted by Financial.
struct (0x4253c4d5) BemoFinancialStake {
    /// User-selected query id copied to the minted wallet internal transfer.
    queryId: uint64
    /// Nanotons forwarded with the minted bmTON transfer notification.
    forwardTonAmount: coins
    /// Optional referenced payload forwarded to the recipient owner notification.
    forwardPayload: cell?
}

/// Maintenance deposit that increases TON supply and commission accounting.
struct (0x4353307d) BemoFinancialDepositWithCommission {
    /// TON amount from the attached value to add to the tracked pool supply.
    tonAmount: coins
}

/// Burn notification sent by a bmTON wallet when a user starts unstaking.
struct (0x7bdd97de) BemoFinancialBurnNotification {
    /// Query id copied from the wallet burn request.
    queryId: uint64
    /// Burned bmTON amount in base units.
    amount: coins
    /// Owner address reported by the burning wallet.
    ownerAddress: address
    /// Receiver address that should receive TON or notifications after unstaking.
    receiverAddress: address
    /// Optional payload carried into the Unstake Request and final notification.
    forwardPayload: cell?
}

/// Unstake completion message sent by an Unstake Request after its lockup expires.
struct (0x492ab1b3) BemoFinancialUnstake {
    /// Sequential Unstake Request index used to authenticate the sender address.
    index: uint64
    /// User address that receives the unstaked TON.
    owner: address
    /// TON amount requested for withdrawal, in nanotons.
    tonAmount: coins
    /// Burned bmTON amount associated with the request.
    jettonAmount: coins
    /// Optional payload copied to the final unstake notification.
    forwardPayload: cell?
}

/// Legacy quote request that returns pool supply with the same opcode.
struct (0x2a158bc3) BemoFinancialProvideLegacyQuote {
    /// Caller-selected query id copied to the legacy quote response.
    queryId: uint64
}

/// On-chain quote request for current TON and bmTON pool supplies.
struct (0xad83913f) BemoFinancialProvideCurrentQuote {
    /// Caller-selected query id copied to the quote response.
    queryId: uint64
    /// Optional payload copied to the quote response.
    customPayload: cell?
}

/// TEP-89 wallet discovery request accepted by Financial.
struct (0x2c76b973) BemoFinancialProvideWalletAddress {
    /// Caller-selected query id copied to the wallet-address response.
    queryId: uint64
    /// Owner address whose deterministic bmTON wallet is requested.
    ownerAddress: address
    /// True when the response should include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Admin command that replaces the Financial admin address.
struct (0x79ceac0f) BemoFinancialSetAdminAddress {
    /// New admin address stored in Financial state.
    adminAddress: address
}

/// Admin command that replaces the operational transaction address.
struct (0x631a9e70) BemoFinancialSetTransactionAddress {
    /// New operational transaction address stored in Financial state.
    transactionAddress: address
}

/// Admin command that replaces the bmTON metadata content cell.
struct (0x5773d1f5) BemoFinancialSetContent {
    /// Replacement metadata content cell.
    content: cell
}

/// Admin command that updates the protocol commission factor.
struct (0x07bccc4f) BemoFinancialSetCommissionFactor {
    /// New protocol commission factor, bounded by the contract to at most 1000.
    commissionFactor: uint16
}

/// Admin command that replaces the protocol commission withdrawal address.
struct (0x792dc2c5) BemoFinancialSetCommissionAddress {
    /// New address receiving protocol commission withdrawals.
    commissionAddress: address
}

/// Operational command that sends a raw TON transfer from Financial.
struct (0x13f22452) BemoFinancialOperationalTransfer {
    /// Destination address of the outgoing raw transfer.
    destination: address
    /// Nanotons sent to `destination`.
    amount: coins
    /// Optional referenced body copied into the outgoing message.
    body: cell?
}

/// Admin command that withdraws accumulated protocol commission.
struct (0x7e4d3ce7) BemoFinancialWithdrawCommission {
}

/// No-op maintenance body accepted and ignored by Financial.
struct (0x73273971) BemoFinancialNoop {
}

/// Maintenance command that refreshes lockup epoch accounting.
struct (0x75339d14) BemoFinancialRefreshLockupEpoch {
}

/// Admin command that replaces contract code with a referenced code cell.
struct (0x60c248ef) BemoFinancialSetCode {
    /// Replacement TVM code cell.
    code: cell
}

/// Admin command that asks Financial to send a standard jetton transfer body to a wallet.
struct (0x0f8a7ea5) BemoFinancialAdminJettonTransferCommand {
    /// Target jetton wallet that receives the outgoing transfer body.
    walletAddress: address
    /// Destination owner address used as both destination and response destination.
    destination: address
    /// Jetton amount to transfer.
    amount: coins
}

/// bmTON wallet internal transfer emitted after a successful stake.
struct (0x178d4519) BemoFinancialInternalTransfer {
    /// Query id from the stake request, or zero for simple empty-body stake.
    queryId: uint64
    /// Newly minted bmTON amount in base units.
    amount: coins
    /// Financial contract address reported as the transfer source.
    from: address
    /// Staker address used as the wallet response address.
    responseAddress: address
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Optional referenced forward payload from the stake request.
    forwardPayload: cell?
}

/// Body used by Financial to initialize or update an Unstake Request.
struct (0x10a1ce75) BemoFinancialDeployUnstakeRequest {
    /// Receiver or owner address stored in the Unstake Request.
    ownerAddress: address
    /// TON amount withdrawable after the lockup, in nanotons.
    withdrawTonAmount: coins
    /// Burned bmTON amount associated with the request.
    withdrawJettonAmount: coins
    /// Optional payload stored in the Unstake Request.
    forwardPayload: cell?
    /// Unix timestamp when the Unstake Request may send `BemoFinancialUnstake`.
    lockupTimestamp: uint32
}

/// Final notification sent to the user when Financial pays an unstake.
struct (0x90c80a07) BemoFinancialUnstakeNotification {
    /// Query id is currently emitted as zero by the verified code path.
    queryId: uint64
    /// Optional payload copied from the Unstake Request.
    forwardPayload: cell?
}

/// Body sent back to an Unstake Request when Financial cannot pay yet.
struct (0x38633538) BemoFinancialReturnUnstakeRequest {
    /// Unix timestamp for the next retry attempt.
    lockupTimestamp: uint32
}

/// Legacy quote response emitted with opcode `0x2a158bc3`.
struct (0x2a158bc3) BemoFinancialTakeLegacyQuote {
    /// Query id copied from the legacy quote request.
    queryId: uint64
    /// Total issued bmTON supply encoded as TL-B `Coins`.
    jettonTotalSupply: coins
    /// Total TON pool supply encoded as TL-B `Coins`.
    tonTotalSupply: coins
}

/// Quote response emitted to the requester.
struct (0x0a420458) BemoFinancialTakeCurrentQuote {
    /// Query id copied from the request.
    queryId: uint64
    /// Current TON pool supply returned as a 128-bit integer.
    tonTotalSupply: uint128
    /// Current bmTON supply returned as a 128-bit integer.
    jettonTotalSupply: uint128
    /// Optional payload copied from the request.
    customPayload: cell?
}

/// TEP-89 wallet discovery response emitted to the requester.
struct (0xd1735400) BemoFinancialTakeWalletAddress {
    /// Query id copied from the discovery request.
    queryId: uint64
    /// Deterministic bmTON wallet address, or `addr_none` when the owner cannot be resolved.
    walletAddress: address?
    /// Optional referenced owner address when the requester asked for it.
    ownerAddress: Cell<address>?
}

/// Standard TEP-74 jetton transfer body emitted by an admin-triggered wallet command.
struct (0x0f8a7ea5) BemoFinancialJettonTransfer {
    /// Query id emitted as zero by the verified branch.
    queryId: uint64
    /// Jetton amount to transfer.
    amount: coins
    /// Destination owner address.
    destination: address
    /// Response destination copied from `destination` by the verified branch.
    responseDestination: address
    /// Optional custom payload; verified branch emits none.
    customPayload: cell?
    /// Nanotons forwarded to the recipient notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by Financial.
type BemoFinancialIncomingMessage =
    | BemoFinancialStake
    | BemoFinancialDepositWithCommission
    | BemoFinancialBurnNotification
    | BemoFinancialUnstake
    | BemoFinancialProvideLegacyQuote
    | BemoFinancialProvideCurrentQuote
    | BemoFinancialProvideWalletAddress
    | BemoFinancialSetAdminAddress
    | BemoFinancialSetTransactionAddress
    | BemoFinancialSetContent
    | BemoFinancialSetCommissionFactor
    | BemoFinancialSetCommissionAddress
    | BemoFinancialOperationalTransfer
    | BemoFinancialWithdrawCommission
    | BemoFinancialNoop
    | BemoFinancialRefreshLockupEpoch
    | BemoFinancialSetCode
    | BemoFinancialAdminJettonTransferCommand

/// Internal message bodies emitted by Financial.
type BemoFinancialOutgoingMessage =
    | BemoFinancialInternalTransfer
    | BemoFinancialDeployUnstakeRequest
    | BemoFinancialUnstakeNotification
    | BemoFinancialReturnUnstakeRequest
    | BemoFinancialTakeLegacyQuote
    | BemoFinancialTakeCurrentQuote
    | BemoFinancialTakeWalletAddress
    | BemoFinancialJettonTransfer

/// Structured result returned by `get_full_data`.
struct BemoFinancialFullDataReply {
    /// Total issued bmTON supply.
    jettonTotalSupply: coins
    /// Total TON pool supply.
    tonTotalSupply: coins
    /// Accumulated protocol commission supply.
    commissionTotalSupply: coins
    /// Protocol commission factor in per-mille units.
    commissionFactor: uint16
    /// Address receiving protocol commission withdrawals.
    commissionAddress: address
    /// Admin address returned from storage.
    adminAddress: address
    /// Operational transaction address returned from storage.
    transactionAddress: address
    /// bmTON metadata content cell.
    content: cell
    /// bmTON wallet code cell.
    jettonWalletCode: cell
    /// Unstake Request code cell.
    unstakeRequestCode: cell
    /// Current 36-hour lockup epoch number.
    lastLockupEpoch: uint32
    /// TON supply unlockable in the current epoch.
    lockupSupply: coins
    /// TON supply unlockable in the next epoch.
    nextLockupSupply: coins
    /// TON supply unlockable in later epochs.
    laterLockupSupply: coins
    /// Next sequential Unstake Request index.
    nextUnstakeRequestIndex: uint64
}

/// Structured result returned by standard TEP-74 `get_jetton_data`.
struct BemoFinancialJettonDataReply {
    /// Total issued bmTON supply returned as a stack integer.
    totalSupply: int
    /// Source returns true because Financial can mint bmTON on stake.
    mintable: bool
    /// Admin address returned in the standard jetton data tuple.
    adminAddress: address
    /// bmTON metadata content cell.
    jettonContent: cell
    /// bmTON wallet code cell.
    jettonWalletCode: cell
}

/// Financial exit-code catalog proven from decompiled branches.
enum BemoFinancialErrors {
    /// Staking message originated outside basechain workchain zero.
    WrongWorkchain = 333
    /// Attached TON value is below the gas, storage, or payout budget.
    NotEnoughValue = 709
    /// Burn notification sender is not the deterministic bmTON wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// Unstake message sender is not the deterministic Unstake Request for the reported index.
    InvalidUnstakeRequestSender = 76
    /// Commission deposit amount is larger than the attached message value.
    InvalidCommissionDeposit = 105
    /// Sender is not authorized for a privileged Financial branch.
    Unauthorized = 73
    /// Operational transfer branch was not sent by the configured transaction address.
    InvalidTransactionSender = 75
    /// A privileged branch received an unsupported zero amount.
    InvalidAmount = 103
    /// A privileged branch failed its non-zero tracked amount check.
    MissingTrackedAmount = 104
    /// Admin attempted to set a commission factor above the 1000 maximum.
    InvalidCommissionFactor = 46
    /// Message opcode is unsupported by the verified dispatcher.
    UnsupportedOperation = 65535
}

/// Return the complete Financial storage tuple exposed by Bemo docs.
get fun get_full_data(): BemoFinancialFullDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw BemoFinancialErrors.WrongWorkchain;
    assert (true) throw BemoFinancialErrors.NotEnoughValue;
    assert (true) throw BemoFinancialErrors.InvalidBurnNotificationSender;
    assert (true) throw BemoFinancialErrors.InvalidUnstakeRequestSender;
    assert (true) throw BemoFinancialErrors.InvalidCommissionDeposit;
    assert (true) throw BemoFinancialErrors.Unauthorized;
    assert (true) throw BemoFinancialErrors.InvalidTransactionSender;
    assert (true) throw BemoFinancialErrors.InvalidAmount;
    assert (true) throw BemoFinancialErrors.MissingTrackedAmount;
    assert (true) throw BemoFinancialErrors.InvalidCommissionFactor;
    assert (true) throw BemoFinancialErrors.UnsupportedOperation;
    return {
        jettonTotalSupply: 0,
        tonTotalSupply: 0,
        commissionTotalSupply: 0,
        commissionFactor: 0,
        commissionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        transactionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        content: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
        unstakeRequestCode: createEmptyCell(),
        lastLockupEpoch: 0,
        lockupSupply: 0,
        nextLockupSupply: 0,
        laterLockupSupply: 0,
        nextUnstakeRequestIndex: 0,
    };
}

/// Return total supply, mintability, admin address, content cell, and wallet code cell.
get fun get_jetton_data(): BemoFinancialJettonDataReply {
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic bmTON wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the deterministic Unstake Request address for a sequential `index`.
get fun get_unstake_request_address(index: uint64): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the Bemo lockup period in seconds.
get fun get_lockup_period(): uint32 {
    return 0;
}
