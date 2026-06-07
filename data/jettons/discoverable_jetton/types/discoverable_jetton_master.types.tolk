/// TEP-89 discoverable Jetton minter with admin minting and mutable admin/content controls.
contract DiscoverableJettonMaster {
    author: "TON Core"
    version: "1.05M"
    description: "Curated interface for discoverable Jetton minters from token-contract v1.04+ and minter-contract 1.04M+"
    storage: DiscoverableJettonMasterStorage
    incomingMessages: DiscoverableJettonMasterIncomingMessage
    outgoingMessages: DiscoverableJettonMasterOutgoingMessage
    thrownErrors: DiscoverableJettonMasterErrors
}

/// Persistent discoverable minter state stored in the root data cell.
struct DiscoverableJettonMasterStorage {
    /// Total issued jettons encoded as TL-B `Coins` in storage.
    totalSupply: coins
    /// Current admin address authorized to mint and mutate admin/content fields.
    adminAddress: address
    /// Referenced jetton metadata content cell returned by `get_jetton_data`.
    jettonContent: cell
    /// Referenced wallet code cell used to derive deterministic user wallet addresses.
    jettonWalletCode: cell
}

/// Admin mint request accepted by the discoverable minter.
struct (0x00000015) JettonMint {
    /// Admin-selected query id carried only in the minter request.
    queryId: uint64
    /// Jetton owner address whose deterministic wallet receives the mint transfer.
    toAddress: address
    /// Nanotons attached to the wallet deployment/internal-transfer message.
    tonAmount: coins
    /// Referenced raw wallet message body, normally `JettonInternalTransfer`.
    masterMsg: cell
}

/// Burn notification sent by a deterministic user wallet to decrease total supply.
struct (0x7bdd97de) JettonBurnNotification {
    /// Query id copied from the original wallet burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Owner address whose deterministic wallet burned the jettons.
    sender: address
    /// Optional response address that receives an `Excesses` refund when non-null.
    responseDestination: address
}

/// TEP-89 wallet discovery request accepted by discoverable minters.
struct (0x2c76b973) ProvideWalletAddress {
    /// Caller-selected query id copied into the `TakeWalletAddress` response.
    queryId: uint64
    /// Owner address whose deterministic jetton wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Admin request that replaces the stored admin address.
struct (0x00000003) JettonChangeAdmin {
    /// Admin-selected query id carried in the change request.
    queryId: uint64
    /// New admin address stored by the minter.
    newAdminAddress: address
}

/// Admin request that replaces the stored metadata content cell.
struct (0x00000004) JettonChangeContent {
    /// Admin-selected query id carried in the change request.
    queryId: uint64
    /// Referenced replacement jetton metadata content cell.
    jettonContent: cell
}

/// TEP-74 excesses response emitted after burn notification processing when a response address is present.
struct (0xd53276db) JettonExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// TEP-89 wallet discovery response emitted to the original requester.
struct (0xd1735400) TakeWalletAddress {
    /// Query id copied from the `ProvideWalletAddress` request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced cell containing the requested owner address when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by discoverable Jetton minters.
type DiscoverableJettonMasterIncomingMessage =
    | JettonMint
    | JettonBurnNotification
    | ProvideWalletAddress
    | JettonChangeAdmin
    | JettonChangeContent

/// Statically known internal message bodies emitted by discoverable Jetton minters.
type DiscoverableJettonMasterOutgoingMessage =
    | JettonExcesses
    | TakeWalletAddress

/// Structured result returned by `get_jetton_data`.
struct GetDiscoverableJettonDataReply {
    /// Total issued jettons returned as a TVM stack integer.
    totalSupply: int
    /// Source returns true because this minter can mint through the admin.
    mintable: bool
    /// Current admin address.
    adminAddress: address
    /// Referenced jetton metadata content cell.
    jettonContent: cell
    /// Referenced wallet code cell embedded in deterministic wallet state init.
    jettonWalletCode: cell
}

/// Discoverable Jetton minter exit-code catalog from source variants.
enum DiscoverableJettonMasterErrors {
    /// Sender is not the stored admin for mint/admin/content requests.
    UnauthorizedAdmin = 73
    /// Burn notification sender is not the deterministic wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// `provide_wallet_address` message value cannot cover the response budget.
    InsufficientProvideWalletAddressValue = 75
    /// Incoming internal message opcode is not supported by the minter.
    UnsupportedOperation = 65535
}

/// Return total supply, mintability, admin address, content cell, and wallet code cell.
get fun get_jetton_data(): GetDiscoverableJettonDataReply {
    throw 0;
}

/// Return the deterministic wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}
