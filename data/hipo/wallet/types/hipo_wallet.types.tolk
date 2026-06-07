/// Hipo Finance hTON wallet interface for Jetton wallet flows, Hipo staking/unstaking callbacks, storage, getters, and exit codes.
contract HipoWallet {
    author: "Hipo Finance"
    version: "1.0"
    description: "Hipo Finance hTON wallet ABI for TEP-74 transfers, Hipo staking callbacks, wallet migration, withdrawal notifications, storage, and getters."
    storage: HipoWalletStorage
    incomingMessages: HipoWalletIncomingMessage
    outgoingMessages: HipoWalletOutgoingMessage
    forceAbiExport: HipoWalletUnstakeCustomPayload | HipoWalletBouncedKnownBody
    thrownErrors: HipoWalletErrors
}

/// Persistent Hipo wallet state stored in the root data cell.
struct HipoWalletStorage {
    /// Wallet owner authorized to transfer hTON, unstake, upgrade, withdraw surplus, and withdraw child Jettons.
    owner: address
    /// Hipo parent Jetton master address authorized for mint/burn/save/merge callbacks.
    parent: address
    /// hTON balance encoded as TL-B `Coins`.
    tokens: coins
    /// Pending staking TON by `round_since`, encoded as `HashmapE 32 Coins`; empty map means no active staking entries.
    staking: map<uint32, coins>
    /// hTON amount currently reserved for unstaking.
    unstaking: coins
}

/// Standard Jetton transfer request accepted from the stored wallet owner.
struct (0x0f8a7ea5) HipoWalletSendTokens {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// hTON amount debited from this wallet.
    tokens: coins
    /// Destination owner whose deterministic Hipo wallet receives the transfer.
    recipient: address
    /// Excess-refund address; `addr_none` is treated as the sender by source code.
    returnExcess: address?
    /// Optional custom payload ignored by this wallet but preserved in the standard transfer layout.
    customPayload: cell?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail forwarded into the peer wallet.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton internal transfer accepted from peer Hipo wallets and emitted to peer Hipo wallets.
struct (0x178d4519) HipoWalletReceiveTokens {
    /// Query id copied from the originating transfer.
    queryId: uint64
    /// hTON amount credited to the recipient wallet.
    tokens: coins
    /// Original owner address reported by the sending wallet.
    sender: address
    /// Excess-refund address used after processing the internal transfer.
    returnExcess: address?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail copied to the owner notification.
    forwardPayload: RemainingBitsAndRefs
}

/// Parent-originated mint callback that credits hTON and may reduce a staking round entry.
struct (0x5445efee) HipoWalletTokensMinted {
    /// Query id copied into the owner transfer notification.
    queryId: uint64
    /// hTON amount minted to this wallet.
    tokens: coins
    /// TON amount represented by the minted hTON, used to reduce the staking dictionary entry.
    coins: coins
    /// Owner address field carried by the parent callback; source skips it after parsing.
    owner: address
    /// Staking round key to reduce; zero means no staking dictionary update.
    roundSince: uint32
}

/// Parent-originated callback that records pending staking TON for a round.
struct (0x4cce0e74) HipoWalletSaveCoins {
    /// Query id carried for traceability.
    queryId: uint64
    /// TON amount added to the pending staking dictionary entry.
    coins: coins
    /// Owner address field carried by the parent callback; source skips it after parsing.
    owner: address
    /// Staking round key where the TON amount is accumulated.
    roundSince: uint32
}

/// Optional payload for `unstake_tokens`, encoded as `Maybe ^Cell`.
struct HipoWalletUnstakeCustomPayload {
    /// Unstake mode: 0 auto, 1 instant, or 2 best.
    mode: uint4
    /// TON amount forwarded for ownership assignment in bill/payout flows.
    ownershipAssignedAmount: coins
}

/// Standard Jetton burn request repurposed by Hipo as an unstake request.
struct (0x595f07bc) HipoWalletUnstakeTokens {
    /// Caller-selected query id copied to the parent reserve request.
    queryId: uint64
    /// hTON amount to burn/reserve for unstaking.
    tokens: coins
    /// Optional excess-refund address; source accepts owner or `addr_none`.
    returnExcess: address?
    /// Optional referenced Hipo unstake mode payload.
    customPayload: Cell<HipoWalletUnstakeCustomPayload>?
}

/// Parent-originated rollback that restores hTON after a failed unstake reserve.
struct (0x1b77fd1a) HipoWalletRollbackUnstake {
    /// Query id copied into the owner excess response.
    queryId: uint64
    /// hTON amount restored from `unstaking` back to spendable balance.
    tokens: coins
}

/// Parent-originated burn completion that reduces `unstaking` and notifies the owner about withdrawn TON.
struct (0x5b512e25) HipoWalletTokensBurned {
    /// Query id copied into the withdrawal notification.
    queryId: uint64
    /// hTON amount removed from the `unstaking` balance.
    tokens: coins
    /// TON amount sent to the owner in the withdrawal notification.
    coins: coins
}

/// Parent or owner request that converts the whole spendable hTON balance into an unstake request to self.
struct (0x5ae30148) HipoWalletUnstakeAll {
    /// Query id copied into the self-sent `unstake_tokens` body.
    queryId: uint64
}

/// Owner or parent request that asks the parent to migrate this wallet balance to a new wallet.
struct (0x01d9ae1c) HipoWalletUpgradeWallet {
    /// Query id copied into the parent proxy migrate request.
    queryId: uint64
}

/// Parent-originated merge callback that credits migrated hTON into this wallet.
struct (0x63d3a76c) HipoWalletMergeWallet {
    /// Query id copied into the owner excess response.
    queryId: uint64
    /// Migrated hTON amount credited to this wallet.
    newTokens: coins
}

/// Owner request to withdraw surplus TON while preserving the wallet storage reserve.
struct (0x23355ffb) HipoWalletWithdrawSurplus {
    /// Query id copied into the gas excess response.
    queryId: uint64
    /// Optional excess destination; `addr_none` is treated as the sender by source code.
    returnExcess: address?
}

/// Owner request that tells a child Jetton wallet to transfer its Jettons back to the Hipo owner.
struct (0x768a50b2) HipoWalletWithdrawJettons {
    /// Query id copied into the child Jetton transfer request.
    queryId: uint64
    /// Child Jetton wallet address receiving the outgoing standard Jetton transfer body.
    childWallet: address
    /// Child Jetton amount requested for withdrawal.
    tokens: coins
    /// Optional child-wallet custom payload forwarded without wallet-side parsing.
    customPayload: cell?
}

/// Value top-up body accepted by the wallet; source checks only the opcode and ignores this tail.
struct (0x5372158c) HipoWalletTopUp {
    /// Unparsed body tail after the opcode, commonly a uint64 query id in the TypeScript wrapper.
    tail: RemainingBitsAndRefs
}

/// Zero-op one-byte text command accepted by source for `w` or `W` unstake-all.
struct (0x00000000) HipoWalletTextUnstakeAll {
    /// ASCII command byte; source lowercases it and accepts only `w`.
    command: uint8
}

/// Standard Jetton transfer notification emitted to the wallet owner.
struct (0x7362d09c) HipoWalletTransferNotification {
    /// Query id copied from the incoming mint/internal-transfer body.
    queryId: uint64
    /// hTON amount reported to the owner.
    tokens: coins
    /// Sender address reported to the owner; mints use the owner address as sender.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excess response emitted to the selected refund/owner address.
struct (0xd53276db) HipoWalletGasExcess {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Parent proxy reserve request emitted after an owner unstake request.
struct (0x688b0213) HipoWalletProxyReserveTokens {
    /// Query id copied from the unstake request.
    queryId: uint64
    /// hTON amount reserved for unstaking.
    tokens: coins
    /// Wallet owner address forwarded to the parent.
    owner: address
    /// Hipo unstake mode: 0 auto, 1 instant, or 2 best.
    mode: uint4
    /// TON amount forwarded for ownership assignment in payout flows.
    ownershipAssignedAmount: coins
}

/// Parent proxy migrate request emitted during wallet upgrade.
struct (0x0cb246bb) HipoWalletProxyMigrateWallet {
    /// Query id copied from the upgrade request.
    queryId: uint64
    /// hTON balance migrated out of this wallet.
    tokens: coins
    /// Wallet owner whose new wallet should receive the migrated hTON.
    owner: address
}

/// Owner withdrawal notification emitted after the parent confirms a burn.
struct (0xf0fa223b) HipoWalletWithdrawalNotification {
    /// Query id copied from the parent burn completion.
    queryId: uint64
    /// hTON amount burned from unstaking.
    tokens: coins
    /// TON amount withdrawn to the owner.
    coins: coins
}

/// Bounced body prefix handled by `on_bounce` before checking the original opcode.
struct (0xffffffff) HipoWalletBouncedKnownBody {
    /// Original opcode; source restores balance for `receive_tokens`, `proxy_reserve_tokens`, and `proxy_migrate_wallet`.
    originalOpcode: uint32
    /// Query id copied into the owner gas excess response.
    queryId: uint64
    /// Remaining original body tail; accepted bounce shapes differ by original opcode.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the Hipo wallet.
type HipoWalletIncomingMessage =
    | HipoWalletSendTokens
    | HipoWalletReceiveTokens
    | HipoWalletTokensMinted
    | HipoWalletSaveCoins
    | HipoWalletUnstakeTokens
    | HipoWalletRollbackUnstake
    | HipoWalletTokensBurned
    | HipoWalletUnstakeAll
    | HipoWalletUpgradeWallet
    | HipoWalletMergeWallet
    | HipoWalletWithdrawSurplus
    | HipoWalletWithdrawJettons
    | HipoWalletTopUp
    | HipoWalletTextUnstakeAll

/// Internal message bodies emitted by the Hipo wallet.
type HipoWalletOutgoingMessage =
    | HipoWalletReceiveTokens
    | HipoWalletUnstakeTokens
    | HipoWalletSendTokens
    | HipoWalletTransferNotification
    | HipoWalletGasExcess
    | HipoWalletProxyReserveTokens
    | HipoWalletProxyMigrateWallet
    | HipoWalletWithdrawalNotification

/// Structured result returned by `get_wallet_data`.
struct HipoWalletDataReply {
    /// hTON balance returned as a TVM stack integer.
    tokens: int
    /// Stored owner address.
    owner: address
    /// Stored parent Jetton master address.
    parent: address
    /// Current wallet code cell returned by `my_code()`.
    code: cell
}

/// Structured result returned by `get_wallet_state`.
struct HipoWalletStateReply {
    /// hTON balance returned as a TVM stack integer.
    tokens: int
    /// Pending staking TON dictionary keyed by uint32 round.
    staking: map<uint32, coins>
    /// hTON amount currently reserved for unstaking.
    unstaking: int
}

/// Structured fee tuple returned by `get_wallet_fees`.
struct HipoWalletFeesReply {
    /// Required TON for owner `send_tokens`, including one forward-fee estimate.
    sendTokensFee: int
    /// Required TON for `unstake_tokens` before optional ownership assignment amount.
    unstakeTokensFee: int
    /// Required TON for `upgrade_wallet`.
    upgradeWalletFee: int
    /// Wallet storage reserve maintained by the contract.
    walletStorageFee: int
}

/// Hipo wallet exit-code catalog used by source throw sites.
enum HipoWalletErrors {
    /// Incoming TON is lower than the required operation fee.
    InsufficientFee = 101
    /// Requested hTON amount is zero or larger than the available balance.
    InsufficientFunds = 102
    /// Sender is not the owner, parent, authenticated peer wallet, or self address required by the operation.
    AccessDenied = 103
    /// Transfer recipient owner is outside the base workchain.
    OnlyBasechainAllowed = 104
    /// Transfer recipient owner equals the sending wallet owner.
    ReceiverIsSender = 105
    /// Incoming opcode is unsupported.
    InvalidOp = 107
    /// Zero-op text command is unsupported.
    InvalidComment = 108
    /// Parsed parameters fail wallet-specific validation.
    InvalidParameters = 109
}

/// Return wallet balance, owner, parent, and current wallet code cell.
get fun get_wallet_data(): HipoWalletDataReply {
    throw 0;
}

/// Return wallet balance, pending staking dictionary, and current unstaking balance.
get fun get_wallet_state(): HipoWalletStateReply {
    throw 0;
}

/// Return precomputed operation fee requirements and storage reserve.
get fun get_wallet_fees(): HipoWalletFeesReply {
    throw 0;
}
