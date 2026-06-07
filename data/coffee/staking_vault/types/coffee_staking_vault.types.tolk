/// Low-level ABI for the Coffee Swap staking vault contract.
contract CoffeeStakingVault {
    author: "swap.coffee"
    version: "0.1"
    description: "Coffee Swap staking vault ABI for Jetton transfer lock handling, master/item deployment routing, owner updates, storage, and getters."
    storage: CoffeeStakingVaultStorage
    incomingMessages: CoffeeStakingVaultIncomingMessage
    outgoingMessages: CoffeeStakingVaultOutgoingMessage
    forceAbiExport: CoffeeStakingLockForwardPayload | CoffeeStakingVaultMasterInit | CoffeeStakingVaultItemInit | CoffeeStakingVaultJettonRefund
}

/// Root persistent storage for the staking vault.
struct CoffeeStakingVaultStorage {
    /// Initialization flag.
    initialized: bool
    /// Vault owner authorized to update dictionaries and code.
    owner: address
    /// Jetton dictionary keyed by notifying Jetton wallet hash.
    jettons: cell?
    /// Period dictionary keyed by period id.
    periods: cell?
    /// Master collection code cell used for deterministic master address derivation.
    masterCode: cell
    /// NFT item code cell used for deterministic item address derivation.
    itemCode: cell
}

/// Jetton staking lock forward payload embedded in TEP-74 transfer notifications.
struct (0x0c0ffede) CoffeeStakingLockForwardPayload {
    /// Staking period selected by the user.
    periodId: uint32
}

/// Owner-authorized vault initialization.
struct (0xbe5a7595) CoffeeStakingVaultInit {
    /// Caller-selected query id.
    queryId: uint64
    /// Vault owner address.
    owner: address
    /// Initial Jetton dictionary.
    jettons: cell?
    /// Initial periods dictionary.
    periods: cell?
}

/// TEP-74 transfer notification accepted from known staking Jetton wallets.
struct (0x7362d09c) CoffeeStakingVaultTransferNotification {
    /// Query id copied from the Jetton transfer.
    queryId: uint64
    /// Received Jetton amount.
    amount: coins
    /// Original user address reported by the Jetton wallet.
    sender: address
    /// Raw Jetton forward payload containing a referenced `CoffeeStakingLockForwardPayload`.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner request that changes the vault owner.
struct (0xf1eef33c) CoffeeStakingVaultSetOwner {
    /// Caller-selected query id.
    queryId: uint64
    /// New vault owner.
    owner: address
}

/// Owner request that replaces the Jetton dictionary.
struct (0xeec15c2a) CoffeeStakingVaultSetJettons {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement Jetton dictionary.
    jettons: cell?
}

/// Owner request that replaces the periods dictionary.
struct (0xfab30dc2) CoffeeStakingVaultSetPeriods {
    /// Caller-selected query id.
    queryId: uint64
    /// Replacement periods dictionary.
    periods: cell?
}

/// Owner request that replaces contract code and optionally full storage data.
struct (0xce4e2066) CoffeeStakingVaultUpdateContract {
    /// Caller-selected query id.
    queryId: uint64
    /// New code cell passed to `set_code`.
    newCode: cell
    /// Optional replacement data cell passed to `set_data` before `set_code`.
    newData: cell?
}

/// Master initialization body emitted by the vault after vault initialization.
struct (0xbe5a7595) CoffeeStakingVaultMasterInit {
    /// Query id copied from the vault init request.
    queryId: uint64
    /// Staking owner address.
    owner: address
    /// Distributor or derived helper address.
    distributor: address
    /// Jetton dictionary.
    jettons: cell?
    /// Period dictionary.
    periods: cell?
}

/// Master deposit callback emitted after a valid Jetton lock transfer.
struct (0xf9471134) CoffeeStakingVaultDepositToMaster {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Notifying Jetton wallet address.
    sender: address
    /// Locked Jetton amount.
    jettonAmount: coins
    /// User address reported by the Jetton transfer notification.
    fromUser: address
    /// Selected staking period id.
    periodId: uint32
}

/// Item initialization body emitted by the vault through deterministic item deployment.
struct (0xbe5a7595) CoffeeStakingVaultItemInit {
    /// Query id copied from the Jetton transfer notification.
    queryId: uint64
    /// Initial NFT owner.
    owner: address
    /// Referenced asset data cell.
    jettonData: cell
    /// Referenced position data cell.
    positionData: cell
    /// Period dictionary.
    periods: cell?
}

/// TEP-74 Jetton transfer body used by refund branches.
struct (0x0f8a7ea5) CoffeeStakingVaultJettonRefund {
    /// Query id copied from the failed transfer notification.
    queryId: uint64
    /// Amount refunded.
    amount: coins
    /// Refund destination owner.
    destination: address
    /// Response destination owner.
    responseDestination: address
    /// Optional custom payload.
    customPayload: cell?
    /// Forward TON amount.
    forwardTonAmount: coins
    /// Optional forward payload.
    forwardPayload: cell?
}

/// Structured return value for `get_stored_data`.
struct CoffeeStakingVaultStoredDataReply {
    /// Initialization flag.
    initialized: bool
    /// Vault owner.
    owner: address
    /// Jetton dictionary.
    jettons: cell
    /// Period dictionary.
    periods: cell
    /// Master collection code cell.
    masterCode: cell
    /// NFT item code cell.
    itemCode: cell
}

/// Internal messages accepted by the staking vault.
type CoffeeStakingVaultIncomingMessage =
    | CoffeeStakingVaultInit
    | CoffeeStakingVaultTransferNotification
    | CoffeeStakingVaultSetOwner
    | CoffeeStakingVaultSetJettons
    | CoffeeStakingVaultSetPeriods
    | CoffeeStakingVaultUpdateContract

/// Internal messages emitted by the staking vault.
type CoffeeStakingVaultOutgoingMessage =
    | CoffeeStakingVaultDepositToMaster
    | CoffeeStakingVaultJettonRefund

enum CoffeeStakingVaultErrors {
    /// Locked Jetton amount must be positive.
    InvalidAmount = 80
    /// Dictionary lookup or dictionary value validation failed.
    InvalidDictionaryValue = 82
    /// Contract is not initialized.
    NotInitialized = 99
    /// Contract is already initialized.
    AlreadyInitialized = 100
    /// Sender is not authorized for the requested operation.
    UnauthorizedAccess = 403
    /// Lock period is not present in the period dictionary.
    WrongPeriod = 503
    /// Jetton transfer forward payload is not `CoffeeStakingLockForwardPayload`.
    UnexpectedForwardOpcode = 504
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return vault owner, dictionaries, and code cells.
get fun get_stored_data(): CoffeeStakingVaultStoredDataReply {
    throw 0;
}

/// Return the deterministic staking master collection address.
get fun get_master_address(): address {
    throw 0;
}
