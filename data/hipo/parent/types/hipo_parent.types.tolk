/// Hipo Finance Parent jetton master for hTON supply accounting, wallet discovery, and treasury/wallet proxy messages.
contract HipoParent {
    author: "Hipo Finance"
    version: "1.0"
    description: "Curated interface for the Hipo Finance Parent hTON jetton master contract"
    storage: HipoParentStorage
    incomingMessages: HipoParentIncomingMessage
    outgoingMessages: HipoParentOutgoingMessage
}

/// Runtime persistent Parent state stored in the root data cell.
struct HipoParentStorage {
    /// Total hTON supply encoded as TL-B `Coins`.
    totalTokens: coins
    /// Treasury contract address authorized for treasury-originated proxy/admin messages.
    treasury: address
    /// Referenced wallet code cell used to derive deterministic Hipo wallet addresses.
    walletCode: cell
    /// Referenced TEP-64 jetton metadata content cell returned by `get_jetton_data`.
    content: cell
}

/// Treasury-to-Parent mint proxy that increases total supply and forwards `tokens_minted` to the owner wallet.
struct (0x5be57626) HipoParentProxyTokensMinted {
    /// Query id copied into the outgoing wallet message.
    queryId: uint64
    /// hTON amount minted in base units.
    tokens: coins
    /// TON amount associated with the mint.
    coins: coins
    /// Owner whose deterministic wallet receives the minted tokens.
    owner: address
    /// Treasury round identifier carried to the wallet.
    roundSince: uint32
}

/// Treasury-to-Parent save-coins proxy that forwards `save_coins` to the owner wallet.
struct (0x47daa10f) HipoParentProxySaveCoins {
    /// Query id copied into the outgoing wallet message.
    queryId: uint64
    /// TON amount saved for the owner.
    coins: coins
    /// Owner whose deterministic wallet receives the save notification.
    owner: address
    /// Treasury round identifier carried to the wallet.
    roundSince: uint32
}

/// Wallet-to-Parent reserve proxy that forwards an unstake reservation to Treasury.
struct (0x688b0213) HipoParentProxyReserveTokens {
    /// Query id copied into the outgoing Treasury `reserve_tokens` message.
    queryId: uint64
    /// hTON amount reserved in base units.
    tokens: coins
    /// Owner used to authenticate the deterministic source wallet and forwarded to Treasury.
    owner: address
    /// Four-bit unstake mode from the source wallet.
    mode: uint4
    /// TON amount assigned for ownership notification handling.
    ownershipAssignedAmount: coins
}

/// Treasury-to-Parent rollback proxy that forwards `rollback_unstake` to the owner wallet.
struct (0x32b67194) HipoParentProxyRollbackUnstake {
    /// Query id copied into the outgoing wallet message.
    queryId: uint64
    /// hTON amount to roll back in the wallet.
    tokens: coins
    /// Owner whose deterministic wallet receives the rollback.
    owner: address
}

/// Treasury-to-Parent burn proxy that decreases total supply and forwards `tokens_burned` to the owner wallet.
struct (0x4476fde0) HipoParentProxyTokensBurned {
    /// Query id copied into the outgoing wallet message.
    queryId: uint64
    /// hTON amount burned in base units.
    tokens: coins
    /// TON amount associated with the burn.
    coins: coins
    /// Owner whose deterministic wallet receives the burn result.
    owner: address
}

/// Treasury-to-Parent proxy that forwards `unstake_all` to the owner wallet.
struct (0x76bd2760) HipoParentProxyUnstakeAll {
    /// Query id copied into the outgoing wallet message.
    queryId: uint64
    /// Owner whose deterministic wallet receives the unstake-all command.
    owner: address
}

/// Treasury-to-Parent proxy that forwards `upgrade_wallet` to the owner wallet with bounce enabled.
struct (0x4664bc68) HipoParentProxyUpgradeWallet {
    /// Query id copied into the outgoing wallet upgrade message.
    queryId: uint64
    /// Owner whose deterministic wallet receives the upgrade message.
    owner: address
}

/// Wallet-to-Parent migration proxy that decreases total supply and forwards `migrate_wallet` to Treasury.
struct (0x0cb246bb) HipoParentProxyMigrateWallet {
    /// Query id copied into the outgoing Treasury migration message.
    queryId: uint64
    /// hTON amount removed from Parent supply for migration.
    tokens: coins
    /// Owner used to authenticate the deterministic source wallet and forwarded to Treasury.
    owner: address
}

/// Treasury-to-Parent merge proxy that increases total supply and forwards `merge_wallet` to the owner wallet.
struct (0x6833d7d0) HipoParentProxyMergeWallet {
    /// Query id copied into the outgoing wallet merge message.
    queryId: uint64
    /// hTON amount merged into the owner wallet.
    tokens: coins
    /// Owner whose deterministic wallet receives the merge.
    owner: address
}

/// TEP-89 wallet discovery request accepted by Parent.
struct (0x2c76b973) HipoParentProvideWalletAddress {
    /// Query id copied into the `take_wallet_address` response.
    queryId: uint64
    /// Owner address whose deterministic Hipo wallet is requested.
    owner: address
    /// True when the response must include a referenced copy of `owner`.
    includeAddress: bool
}

/// Treasury-only metadata update request.
struct (0x04dc78b7) HipoParentSetContent {
    /// Query id copied into the outgoing `gas_excess` response.
    queryId: uint64
    /// Address that receives the excess response after content replacement.
    returnExcess: address
    /// Referenced replacement TEP-64 full content cell stored as Parent metadata.
    newContent: cell
}

/// Treasury-only request that reserves storage fee and returns surplus TON.
struct (0x23355ffb) HipoParentWithdrawSurplus {
    /// Query id copied into the outgoing `gas_excess` response.
    queryId: uint64
    /// Address that receives the unreserved surplus response.
    returnExcess: address
}

/// Treasury-only code upgrade request with optional replacement data passed to `upgrade_data`.
struct (0x3d6a29b5) HipoParentUpgradeCode {
    /// Query id copied into the outgoing `gas_excess` response after upgrade.
    queryId: uint64
    /// Referenced replacement contract code cell.
    newCode: cell
    /// Optional referenced replacement data cell; current source leaves data migration as a template.
    newData: cell?
    /// Address that receives the excess response after upgrade.
    returnExcess: address
}

/// Funding-only message accepted without state changes.
struct (0x5372158c) HipoParentTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// Parent-to-wallet mint result emitted by `proxy_tokens_minted`.
struct (0x5445efee) HipoParentTokensMinted {
    /// Query id copied from the proxy request.
    queryId: uint64
    /// hTON amount minted in base units.
    tokens: coins
    /// TON amount associated with the mint.
    coins: coins
    /// Owner copied into the wallet body for bounced-message diagnostics.
    owner: address
    /// Treasury round identifier copied from the proxy request.
    roundSince: uint32
}

/// Parent-to-wallet save-coins result emitted by `proxy_save_coins`.
struct (0x4cce0e74) HipoParentSaveCoins {
    /// Query id copied from the proxy request.
    queryId: uint64
    /// TON amount saved for the owner.
    coins: coins
    /// Owner copied into the wallet body for bounced-message diagnostics.
    owner: address
    /// Treasury round identifier copied from the proxy request.
    roundSince: uint32
}

/// Parent-to-Treasury reservation request emitted by `proxy_reserve_tokens`.
struct (0x386a358b) HipoParentReserveTokens {
    /// Query id copied from the wallet proxy request.
    queryId: uint64
    /// hTON amount reserved in base units.
    tokens: coins
    /// Owner forwarded to Treasury.
    owner: address
    /// Four-bit unstake mode forwarded to Treasury.
    mode: uint4
    /// TON amount assigned for ownership notification handling.
    ownershipAssignedAmount: coins
}

/// Parent-to-wallet rollback result emitted by `proxy_rollback_unstake`.
struct (0x1b77fd1a) HipoParentRollbackUnstake {
    /// Query id copied from the proxy request.
    queryId: uint64
    /// hTON amount to roll back in the wallet.
    tokens: coins
}

/// Parent-to-wallet burn result emitted by `proxy_tokens_burned`.
struct (0x5b512e25) HipoParentTokensBurned {
    /// Query id copied from the proxy request.
    queryId: uint64
    /// hTON amount burned in base units.
    tokens: coins
    /// TON amount associated with the burn.
    coins: coins
}

/// Parent-to-wallet unstake-all command emitted by `proxy_unstake_all`.
struct (0x5ae30148) HipoParentUnstakeAll {
    /// Query id copied from the proxy request.
    queryId: uint64
}

/// Parent-to-wallet upgrade command emitted by `proxy_upgrade_wallet`.
struct (0x01d9ae1c) HipoParentUpgradeWallet {
    /// Query id copied from the proxy request.
    queryId: uint64
}

/// Parent-to-Treasury migration request emitted by `proxy_migrate_wallet`.
struct (0x325aacfa) HipoParentMigrateWallet {
    /// Query id copied from the wallet proxy request.
    queryId: uint64
    /// hTON amount removed from Parent supply for migration.
    tokens: coins
    /// Owner forwarded to Treasury.
    owner: address
}

/// Parent-to-wallet merge result emitted by `proxy_merge_wallet`.
struct (0x63d3a76c) HipoParentMergeWallet {
    /// Query id copied from the proxy request.
    queryId: uint64
    /// hTON amount merged into the owner wallet.
    tokens: coins
}

/// TEP-89 wallet discovery response emitted to the original requester.
struct (0xd1735400) HipoParentTakeWalletAddress {
    /// Query id copied from the `provide_wallet_address` request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when the requested owner is not basechain.
    walletAddress: address?
    /// Optional referenced owner address cell included only when requested.
    ownerAddress: Cell<address>?
}

/// TEP-74 excess response emitted by content, surplus, and upgrade flows.
struct (0xd53276db) HipoParentGasExcess {
    /// Query id copied from the request that produced the excess response.
    queryId: uint64
}

/// Internal message bodies accepted by Hipo Parent.
type HipoParentIncomingMessage =
    | HipoParentProxyTokensMinted
    | HipoParentProxySaveCoins
    | HipoParentProxyReserveTokens
    | HipoParentProxyRollbackUnstake
    | HipoParentProxyTokensBurned
    | HipoParentProxyUnstakeAll
    | HipoParentProxyUpgradeWallet
    | HipoParentProxyMigrateWallet
    | HipoParentProxyMergeWallet
    | HipoParentProvideWalletAddress
    | HipoParentSetContent
    | HipoParentWithdrawSurplus
    | HipoParentUpgradeCode
    | HipoParentTopUp

/// Internal message bodies emitted by Hipo Parent.
type HipoParentOutgoingMessage =
    | HipoParentTokensMinted
    | HipoParentSaveCoins
    | HipoParentReserveTokens
    | HipoParentRollbackUnstake
    | HipoParentTokensBurned
    | HipoParentUnstakeAll
    | HipoParentUpgradeWallet
    | HipoParentMigrateWallet
    | HipoParentMergeWallet
    | HipoParentTakeWalletAddress
    | HipoParentGasExcess

/// Structured result returned by `get_jetton_data`.
struct HipoParentJettonDataReply {
    /// Total issued hTON returned as a TVM stack integer.
    totalTokens: int
    /// Source returns true for the mintable flag because Treasury can mint through proxy flow.
    mintable: bool
    /// Treasury address returned in the standard admin-address slot.
    treasury: address
    /// Referenced TEP-64 metadata content cell.
    content: cell
    /// Referenced wallet code cell used for deterministic wallet derivation.
    walletCode: cell
}

/// Exit-code catalog used by Parent source branches.
enum HipoParentErrors {
    /// Sender is not Treasury or not the deterministic owner wallet required by the proxy branch.
    AccessDenied = 103
    /// Wallet-address getter was called with an owner outside the basechain.
    OnlyBasechainAllowed = 104
    /// Incoming internal message opcode is unsupported by Parent.
    InvalidOperation = 107
}

/// Return supply, mintability, treasury address, metadata content cell, and wallet code cell.
get fun get_jetton_data(): HipoParentJettonDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw HipoParentErrors.AccessDenied;
    assert (true) throw HipoParentErrors.OnlyBasechainAllowed;
    assert (true) throw HipoParentErrors.InvalidOperation;
    return {
        totalTokens: 0,
        mintable: true,
        treasury: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        content: createEmptyCell(),
        walletCode: createEmptyCell(),
    };
}

/// Return the deterministic Hipo wallet address for a basechain owner.
get fun get_wallet_address(owner: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
