/// Storm Trade referral NFT item interface.
contract StormReferral {
    author: "Storm Trade"
    version: "1.0"
    description: "Referral NFT item with TEP-62 item surface and Storm referral balance ABI"
    storage: StormReferralStorage
    storageAtDeployment: StormReferralDeploymentStorage
    incomingMessages: StormReferralIncomingMessage
    outgoingMessages: StormReferralOutgoingMessage
    forceAbiExport: StormReferralParameters | StormReferralInitPayload
    thrownErrors: StormReferralErrors
}

/// Deployment storage before the collection initializes the referral item.
struct StormReferralDeploymentStorage {
    /// Referral NFT item index stored as uint64.
    itemIndex: uint64
    /// Referral collection address authorized to initialize this item.
    collectionAddress: address
}

/// Initialized referral item storage.
struct StormReferralStorage {
    /// Referral NFT item index stored as uint64.
    itemIndex: uint64
    /// Referral collection address used for init checks and static-data reports.
    collectionAddress: address
    /// Current NFT owner address.
    ownerAddress: address
    /// Referral type stored as uint2; type 1 is non-transferable in the live code.
    referralType: uint2
    /// Balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
    /// Referenced discount/rebate parameters returned by `get_referral_data`.
    parameters: Cell<StormReferralParameters>
}

/// Referral fee parameters stored as two uint32 values.
struct StormReferralParameters {
    /// Discount rate value.
    discount: uint32
    /// Rebate rate value.
    rebate: uint32
}

/// Collection-to-item initialization body accepted before runtime storage is present.
struct (0xcb4ddc3c) StormMintReferral {
    /// Initial NFT owner stored by the item.
    nftOwner: address
    /// Referral type stored in item storage as uint2.
    refType: uint2
    /// Address that receives deployment excess value.
    redirectAddress: address
    /// Referenced discount/rebate parameters.
    parameters: Cell<StormReferralParameters>
    /// Initial balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Vault-originated balance addition.
struct (0x84dced7a) StormAddReferralAmount {
    /// Nanotons added to the sender vault balance entry.
    referralAmount: coins
    /// Address that receives the acknowledgement/excess message.
    originAddr: address
}

/// Request current fee parameters from the referral item.
struct (0x7e43f5fc) StormReferralProvideFees {
}

/// Collection response carrying a vault whitelist and original add-amount request tail.
struct (0x6996158d) StormReferralVaultsReply {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Forwarded tail beginning with vault address, amount, and origin address.
    requestTail: RemainingBitsAndRefs
}

/// Collection bootstrap body that merges whitelisted vaults into the item balance dictionary.
struct (0x87b6c438) StormReferralVaultsBootstrap {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Collection address copied into the callback body.
    collectionAddress: address
}

/// Owner request to claim the balance associated with a vault.
struct (0x556d1620) StormClaimReferralAmount {
    /// Vault address whose balance entry is withdrawn.
    vaultAddress: address
}

/// TEP-62 transfer request accepted when `referralType != 1`.
struct (0x5fcc3d14) StormReferralTransfer {
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
struct (0x2fcb26a2) StormReferralGetStaticData {
    /// Query id copied into the outgoing static-data report.
    queryId: uint64
}

/// Withdraw body sent to the vault when the owner claims a referral balance.
struct (0xf5d4eb52) StormWithdrawReferralAmount {
    /// Referral item index copied from storage.
    index: uint64
    /// Claimed referral balance amount.
    referralAmount: coins
    /// Referral NFT owner address.
    ownerAddr: address
}

/// Fee-parameters response emitted by the referral item.
struct (0x12d9601d) StormTakeReferralFees {
    /// Referenced discount/rebate parameters from item storage.
    referralFees: Cell<StormReferralParameters>
}

/// Request emitted to the collection when a vault is missing from the local balance dictionary.
struct (0xdd5aab73) StormReferralProvideVaultsRequest {
    /// Vault address from the original add-amount sender.
    vaultAddress: address
    /// Original add-amount body tail.
    requestTail: RemainingBitsAndRefs
}

/// TEP-62 ownership assignment notification sent to a new owner.
struct (0x05138d91) StormReferralOwnershipAssigned {
    /// Query id copied from the transfer request.
    queryId: uint64
    /// Previous owner address.
    previousOwnerAddress: address
    /// Raw forwarded payload copied from the transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Static-data response sent to a requester.
struct (0x8b771735) StormReferralReportStaticData {
    /// Query id copied from the request.
    queryId: uint64
    /// Referral item index encoded as uint256 by the live code.
    itemIndex: uint256
    /// Referral collection address stored by this item.
    collectionAddress: address
}

/// Excess-value response emitted by transfer and init flows.
struct (0xd53276db) StormReferralExcesses {
    /// Query id copied from the request.
    queryId: uint64
}

/// Item initialization body alias used for force-export documentation.
type StormReferralInitPayload = StormMintReferral

/// Internal message bodies accepted by the referral item.
type StormReferralIncomingMessage =
    | StormMintReferral
    | StormAddReferralAmount
    | StormReferralProvideFees
    | StormReferralVaultsReply
    | StormReferralVaultsBootstrap
    | StormClaimReferralAmount
    | StormReferralTransfer
    | StormReferralGetStaticData

/// Internal message bodies emitted by the referral item.
type StormReferralOutgoingMessage =
    | StormWithdrawReferralAmount
    | StormTakeReferralFees
    | StormReferralProvideVaultsRequest
    | StormReferralOwnershipAssigned
    | StormReferralReportStaticData
    | StormReferralExcesses

/// Structured result returned by `get_nft_data`.
struct StormReferralNftDataReply {
    /// True when runtime storage includes owner, type, balances, and parameters.
    isInitialized: bool
    /// Referral item index returned as a stack integer.
    itemIndex: int
    /// Referral collection address.
    collectionAddress: address
    /// Current owner address, or null before initialization.
    ownerAddress: address?
    /// Compatibility content cell; live code returns an empty cell for initialized items.
    content: cell?
}

/// Structured result returned by `get_referral_data`.
struct GetReferralDataReply {
    /// Referral type returned as a stack integer; storage width is uint2.
    referralType: int
    /// Discount loaded from the parameters ref.
    discount: uint32
    /// Rebate loaded from the parameters ref.
    rebate: uint32
    /// Balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Referral item exit codes.
enum StormReferralErrors {
    /// Sender is not the current owner.
    NotAnOwner = 301
    /// Vault or owner address is not in basechain workchain 0.
    WrongVaultWc = 303
    /// Type-1 referral items cannot be transferred.
    CanNotTransferKol = 307
    /// Transfer response value would be negative.
    NegativeResponseValue = 308
    /// Initialization or collection callback sender is not the collection.
    NotACollection = 309
    /// Add-amount request attached less than 0.03 TON.
    MinAddAmountValue = 311
    /// Provide-fees request attached less than 0.05 TON.
    MinProvideFeesValue = 312
    /// Vault balance entry was expected but not found after whitelist merge.
    VaultWasNotAdded = 313
    /// Claim request attached less than 0.2 TON.
    MinTonForClaim = 314
    /// Requested vault balance entry was not found.
    VaultNotFound = 315
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return item initialization flag, index, collection, owner, and compatibility content cell.
get fun get_nft_data(): StormReferralNftDataReply {
    throw 0;
}

/// Return referral type, default fee parameters, and raw balances dictionary.
get fun get_referral_data(): GetReferralDataReply {
    throw 0;
}
