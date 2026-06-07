/// Storm Trade executor NFT item interface.
contract StormExecutor {
    author: "Storm Trade"
    version: "1.0"
    description: "Executor NFT item with TEP-62 item surface and Storm executor balance ABI"
    storage: StormExecutorStorage
    storageAtDeployment: StormExecutorDeploymentStorage
    incomingMessages: StormExecutorIncomingMessage
    outgoingMessages: StormExecutorOutgoingMessage
    forceAbiExport: StormExecutorInitPayload
    thrownErrors: StormExecutorErrors
}

/// Deployment storage before the collection initializes the executor item.
struct StormExecutorDeploymentStorage {
    /// Executor NFT item index stored as uint32.
    itemIndex: uint32
    /// Executor collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized executor item storage.
struct StormExecutorStorage {
    /// Executor NFT item index stored as uint32.
    itemIndex: uint32
    /// Executor collection address used for init checks and static-data reports.
    collectionAddress: address
    /// Current NFT owner address.
    ownerAddress: address
    /// Balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Collection-to-item initialization body accepted before runtime storage is present.
struct (0x4f38cae8) StormMintExecutor {
    /// Initial NFT owner stored by the item.
    nftOwner: address
    /// Address that receives deployment excess value.
    redirectAddress: address
    /// Initial balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Vault-originated balance addition.
struct (0x5dd66579) StormAddExecutorAmount {
    /// Nanotons added to the sender vault balance entry; schema names this field `referral_amount`.
    referralAmount: coins
    /// Address that receives the acknowledgement/excess message.
    originAddr: address
}

/// Collection response carrying a vault whitelist and original add-amount request tail.
struct (0x6996158d) StormExecutorVaultsReply {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Forwarded tail beginning with vault address, amount, and origin address.
    requestTail: RemainingBitsAndRefs
}

/// Collection bootstrap body that merges whitelisted vaults into the item balance dictionary.
struct (0x87b6c438) StormExecutorVaultsBootstrap {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Collection address copied into the callback body.
    collectionAddress: address
}

/// Owner request to claim the balance associated with a vault.
struct (0x8c679e23) StormClaimExecutorAmount {
    /// Vault address whose balance entry is withdrawn.
    vaultAddress: address
}

/// TEP-62 transfer request accepted by executor items.
struct (0x5fcc3d14) StormExecutorTransfer {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New owner address; live code restricts it to basechain workchain 0.
    newOwnerAddress: address
    /// Optional response destination for excesses.
    responseDestination: address?
    /// Optional custom payload from the TEP-62 transfer layout.
    customPayload: cell?
    /// Nanotons forwarded to the new owner notification.
    forwardTonAmount: coins
    /// Raw TEP-62 forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data.
struct (0x2fcb26a2) StormExecutorGetStaticData {
    /// Query id copied into the outgoing static-data report.
    queryId: uint64
}

/// Withdraw body sent to the vault when the owner claims an executor balance.
struct (0x2cde6351) StormWithdrawExecutorAmount {
    /// Executor item index copied from storage.
    index: uint32
    /// Claimed executor balance amount.
    executorAmount: coins
    /// Executor NFT owner address.
    ownerAddr: address
}

/// Request emitted to the collection when a vault is missing from the local balance dictionary.
struct (0xdd5aab73) StormExecutorProvideVaultsRequest {
    /// Vault address from the original add-amount sender.
    vaultAddress: address
    /// Original add-amount body tail.
    requestTail: RemainingBitsAndRefs
}

/// TEP-62 ownership assignment notification sent to a new owner.
struct (0x05138d91) StormExecutorOwnershipAssigned {
    /// Query id copied from the transfer request.
    queryId: uint64
    /// Previous owner address.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to a requester.
struct (0x8b771735) StormExecutorReportStaticData {
    /// Query id copied from the request.
    queryId: uint64
    /// Executor item index encoded as uint256 by the live code.
    itemIndex: uint256
    /// Executor collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response emitted by transfer and init flows.
struct (0xd53276db) StormExecutorExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Item initialization body alias used for force-export documentation.
type StormExecutorInitPayload = StormMintExecutor

/// Internal message bodies accepted by the executor item.
type StormExecutorIncomingMessage =
    | StormMintExecutor
    | StormAddExecutorAmount
    | StormExecutorVaultsReply
    | StormExecutorVaultsBootstrap
    | StormClaimExecutorAmount
    | StormExecutorTransfer
    | StormExecutorGetStaticData

/// Internal message bodies emitted by the executor item.
type StormExecutorOutgoingMessage =
    | StormWithdrawExecutorAmount
    | StormExecutorProvideVaultsRequest
    | StormExecutorOwnershipAssigned
    | StormExecutorReportStaticData
    | StormExecutorExcesses

/// Structured result returned by `get_nft_data`.
struct StormExecutorNftDataReply {
    /// True when runtime storage includes owner and balances dictionary.
    isInitialized: bool
    /// Executor item index returned as a stack integer.
    itemIndex: int
    /// Executor collection address.
    collectionAddress: address
    /// Current owner address, or null before initialization.
    ownerAddress: address?
    /// Compatibility content cell; live code returns an empty cell for initialized items.
    content: cell?
}

/// Executor item exit codes.
enum StormExecutorErrors {
    /// Sender is not the current owner.
    NotAnOwner = 351
    /// Vault or owner address is not in basechain workchain 0.
    WrongVaultWc = 354
    /// Transfer response value would be negative.
    NegativeResponseValue = 357
    /// Initialization or collection callback sender is not the collection.
    NotACollection = 358
    /// Add-amount request attached less than 0.03 TON.
    MinAddAmountValue = 359
    /// Vault balance entry was expected but not found after whitelist merge.
    VaultWasNotAdded = 360
    /// Claim request attached less than 0.2 TON.
    MinTonForClaim = 361
    /// Requested vault balance entry was not found.
    VaultNotFound = 362
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and compatibility content cell.
get fun get_nft_data(): StormExecutorNftDataReply {
    throw 0;
}

/// Return the executor balances dictionary.
get fun get_executor_balances(): map<uint256, coins> {
    throw 0;
}
