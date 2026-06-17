import "@stdlib/strings"

/// Acton Tolk jetton template minter interface.
contract JettonMinter {
    author: "Petr Makhnev"
    version: "2.1"
    description: "Standard Tolk Jetton Minter used by the Acton jetton project template. TEP-74 and TEP-89 compliant."
    storage: MinterStorage
    incomingMessages: JettonMinterIncomingMessage
    outgoingMessages: JettonMinterOutgoingMessage
    thrownErrors: Errors
}

/// Raw TEP-74 forward payload tail after the Either tag is decoded.
type ForwardPayloadRemainder = RemainingBitsAndRefs

/// Inline TEP-74 forward payload variant with the payload bits stored in the body.
struct (0b0) PayloadInline {
    /// Remaining forward payload bits and refs stored inline after the Either tag.
    value: RemainingBitsAndRefs
}

/// Referenced TEP-74 forward payload variant with the payload stored in a cell ref.
struct (0b1) PayloadInRef {
    /// Referenced forward payload cell.
    value: Cell<RemainingBitsAndRefs>
}

/// Minter-to-wallet or wallet-to-wallet TEP-74 internal transfer body.
struct (0x178d4519) InternalTransferStep {
    /// Query id copied from the mint or transfer request.
    queryId: uint64
    /// Jetton amount transferred in base units.
    jettonAmount: coins
    /// Owner address that initiated the transfer, or null for mint-originated transfers.
    transferInitiator: address?
    /// Optional address that receives excess TON after processing.
    sendExcessesTo: address?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// TEP-74 Either payload tail used by recipient notification logic.
    @abi.clientType(PayloadInline | PayloadInRef)
    forwardPayload: ForwardPayloadRemainder
}

/// TEP-74 excesses response returned after burn or transfer processing.
struct (0xd53276db) ReturnExcessesBack {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Burn notification accepted by the minter from a valid jetton wallet.
struct (0x7bdd97de) BurnNotificationForMinter {
    /// Query id copied from the wallet burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    jettonAmount: coins
    /// Owner address whose wallet burned jettons.
    burnInitiator: address
    /// Optional address that receives remaining TON after burn accounting.
    sendExcessesTo: address?
}

/// TEP-89 wallet address discovery request.
struct (0x2c76b973) RequestWalletAddress {
    /// Caller-selected query id copied into the discovery response.
    queryId: uint64
    /// Owner address whose wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of ownerAddress.
    includeOwnerAddress: bool
}

/// TEP-89 wallet address discovery response.
struct (0xd1735400) ResponseWalletAddress {
    /// Query id copied from RequestWalletAddress.
    queryId: uint64
    /// Derived wallet address, or null when the owner workchain is unsupported.
    jettonWalletAddress: address?
    /// Optional referenced owner address included when requested.
    ownerAddress: Cell<address>?
}

/// Admin mint request that deploys or credits the recipient jetton wallet.
struct (0x642b7d07) MintNewJettons {
    /// Admin-selected query id for the mint request.
    queryId: uint64
    /// Jetton owner address that receives the minted amount.
    mintRecipient: address
    /// Nanotons attached to the wallet deployment or credit message.
    tonAmount: coins
    /// Referenced InternalTransferStep forwarded to the recipient wallet.
    internalTransferMsg: Cell<InternalTransferStep>
}

/// Admin request that sets a pending next admin address.
struct (0x6501f354) ChangeMinterAdmin {
    /// Admin-selected query id.
    queryId: uint64
    /// Address that can later claim admin rights.
    newAdminAddress: address
}

/// Pending-admin request that promotes nextAdminAddress to adminAddress.
struct (0xfb88e119) ClaimMinterAdmin {
    /// Pending-admin selected query id.
    queryId: uint64
}

/// Admin request that clears both current and pending admin slots.
struct (0x7431f221) DropMinterAdmin {
    /// Admin-selected query id.
    queryId: uint64
}

/// Admin request that replaces contract data and code.
struct (0x2508d66a) UpgradeMinterCode {
    /// Admin-selected query id.
    queryId: uint64
    /// Replacement root data cell passed to set_data.
    newData: cell
    /// Replacement code cell scheduled through set_code.
    newCode: cell
}

/// Admin request that replaces on-chain metadata content.
struct (0xcb862902) ChangeMinterMetadata {
    /// Admin-selected query id.
    queryId: uint64
    /// Replacement on-chain metadata root cell.
    newMetadata: cell
}

/// Funding-only message accepted without changing jetton state.
struct (0xd372158c) TopUpTons {}

/// Persistent minter state stored in the root data cell.
struct MinterStorage {
    /// Total issued jettons encoded as TL-B Coins.
    totalSupply: coins
    /// Current admin address, or null after admin rights are dropped.
    adminAddress: address?
    /// Pending admin address for the two-step admin transfer flow.
    nextAdminAddress: address?
    /// On-chain jetton metadata root cell.
    metadata: cell
}

/// Internal message bodies accepted by the minter.
type JettonMinterIncomingMessage =
    | MintNewJettons
    | BurnNotificationForMinter
    | RequestWalletAddress
    | ChangeMinterAdmin
    | ClaimMinterAdmin
    | DropMinterAdmin
    | ChangeMinterMetadata
    | UpgradeMinterCode
    | TopUpTons

/// Internal message bodies emitted by the minter.
type JettonMinterOutgoingMessage =
    | ReturnExcessesBack
    | ResponseWalletAddress
    | InternalTransferStep

/// Stack tuple returned by get_jetton_data.
struct JettonDataReply {
    /// Total issued jettons returned as a TVM integer.
    totalSupply: int
    /// True while the minter has an active admin.
    mintable: bool
    /// Current admin address, or null after admin rights are dropped.
    adminAddress: address?
    /// On-chain metadata content cell.
    jettonContent: Cell<OnchainMetadataReply>
    /// Jetton wallet code cell used for wallet address derivation.
    jettonWalletCode: cell
}

/// TEP-64 on-chain metadata dictionary cell with 0x00 content prefix.
struct (0x00) OnchainMetadataReply {
    /// Dictionary keyed by sha256 metadata key with 0x00-prefixed string values.
    contentDict: map<uint256, string_prefixed0x>
}

/// Exit-code catalog used by the Tolk jetton template minter.
enum Errors {
    /// Wallet balance would become negative.
    BalanceError = 47
    /// Attached TON value is below the required gas budget.
    NotEnoughGas = 48
    /// Message payload shape or forward payload Either layout is invalid.
    InvalidMessage = 49
    /// Nested message opcode does not match the expected body type.
    InvalidOp = 72
    /// Sender is not authorized for the requested operation.
    NotOwner = 73
    /// Burn notification or internal transfer sender is not a valid wallet.
    NotValidWallet = 74
    /// Target address is outside the base workchain accepted by the contract.
    WrongWorkchain = 333
}

/// Return supply, mintability, admin address, metadata content, and wallet code.
get fun get_jetton_data(): JettonDataReply {
    throw 0;
}

/// Return the deterministic wallet address for ownerAddress.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return the pending next admin address, or null when absent.
get fun get_next_admin_address(): address? {
    throw 0;
}
