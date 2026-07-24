/// Wrapped TON jetton master deployed by Megaton Finance.
contract WtonMinter {
    author: "Ozys / Megaton Finance"
    version: "202301191"
    description: "WTON wraps deposited TON one-for-one, burns WTON for withdrawals, and implements TEP-74/TEP-89 discovery."
    storage: WtonMinterStorage
    incomingMessages: WtonMinterIncomingMessage
    outgoingMessages: WtonMinterOutgoingMessage
    thrownErrors: WtonMinterErrors
}

/// Persistent WTON master state.
struct WtonMinterStorage {
    /// Total issued WTON amount in base units.
    totalSupply: coins
    /// Current administrator allowed to nominate an administrator and update metadata.
    adminAddress: address
    /// Nominated administrator; absent after a successful handover.
    nextAdminAddress: address?
    /// TEP-64 WTON metadata content.
    content: cell
    /// WTON wallet code used for deterministic address derivation.
    walletCode: cell
}

/// Deposit attached TON and mint the requested WTON amount.
struct (0x77a33521) WtonDeposit {
    /// Caller-selected correlation id copied to an excess response.
    queryId: uint64
    /// WTON amount to mint; attached value after gas must cover it.
    amount: coins
}

/// Ask the minter to burn the caller's WTON wallet balance and release TON.
struct (0x47d1895f) WtonWithdraw {
    /// Caller-selected correlation id.
    queryId: uint64
    /// WTON amount the minter instructs the caller's wallet to burn.
    amount: coins
}

/// Burn notification emitted by the deterministic WTON wallet.
struct (0x7bdd97de) WtonBurnNotification {
    /// Query id copied from the wallet burn.
    queryId: uint64
    /// Burned WTON amount released as nanotons.
    amount: coins
    /// WTON owner that receives the released TON.
    ownerAddress: address
    /// Address supplied by the minter as the burn-response destination.
    responseDestination: address?
    /// Optional payload copied by the WTON wallet.
    customPayload: cell?
}

/// TEP-89 request for the deterministic wallet address of an owner.
struct (0x2c76b973) WtonProvideWalletAddress {
    /// Request correlation id copied to the response.
    queryId: uint64
    /// Owner whose deterministic WTON wallet is requested.
    ownerAddress: address
    /// Whether the response should include the owner address in a referenced cell.
    includeOwnerAddress: bool
}

/// Current-admin request to nominate the next administrator.
struct (0x62dd86f1) WtonChangeNextAdmin {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Address allowed to complete the administrator handover.
    nextAdminAddress: address
}

/// Nominated-admin request to complete the handover.
struct (0x66447dad) WtonAcceptAdmin {
    /// Admin-selected correlation id.
    queryId: uint64
}

/// Current-admin request to replace WTON metadata.
struct (0x743f8e58) WtonChangeContent {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Replacement TEP-64 metadata content.
    content: cell
}

/// Standard excess-value body accepted and ignored by the minter.
struct (0xd53276db) WtonIncomingExcesses {
    /// Correlation id of the completed operation.
    queryId: uint64
}

/// Ordinary internal bodies accepted by the WTON minter.
type WtonMinterIncomingMessage =
    | WtonDeposit
    | WtonWithdraw
    | WtonBurnNotification
    | WtonProvideWalletAddress
    | WtonChangeNextAdmin
    | WtonAcceptAdmin
    | WtonChangeContent
    | WtonIncomingExcesses

/// Minter-to-wallet transfer used to issue WTON.
struct (0x178d4519) WtonMintInternalTransfer {
    /// Correlation id; the minter emits zero for deposits.
    queryId: uint64
    /// Newly issued WTON amount.
    amount: coins
    /// Depositor address represented as the jetton sender.
    fromAddress: address
    /// Depositor address that receives remaining wallet value.
    responseDestination: address?
    /// Forwarded nanotons; the minter emits zero for deposits.
    forwardTonAmount: coins
}

/// Minter-to-wallet burn instruction used by the withdrawal flow.
struct (0x595f07bc) WtonBurn {
    /// Correlation id; the minter emits zero for withdrawals.
    queryId: uint64
    /// WTON amount to burn.
    amount: coins
    /// Minter address that receives the burn notification.
    responseDestination: address?
    /// Optional payload; the minter emits no payload for withdrawals.
    customPayload: cell?
}

/// Standard excess-value response.
struct (0xd53276db) WtonOutgoingExcesses {
    /// Query id copied from the initiating message.
    queryId: uint64
}

/// TEP-89 wallet-address response.
struct (0xd1735400) WtonTakeWalletAddress {
    /// Query id copied from the discovery request.
    queryId: uint64
    /// Deterministic wallet address, or absent for an unresolvable owner.
    walletAddress: address?
    /// Optional referenced owner address requested by the caller.
    includedOwnerAddress: Cell<address>?
}

/// Every statically typed ordinary internal body emitted by the WTON minter.
type WtonMinterOutgoingMessage =
    | WtonMintInternalTransfer
    | WtonBurn
    | WtonOutgoingExcesses
    | WtonTakeWalletAddress

/// Standard TEP-74 master data returned by `get_jetton_data`.
struct WtonJettonData {
    /// Total issued WTON amount.
    totalSupply: int
    /// Always true; TON deposits may mint new WTON.
    mintable: bool
    /// Current WTON administrator.
    adminAddress: address
    /// TEP-64 metadata content.
    content: cell
    /// WTON wallet code.
    walletCode: cell
}

/// WTON minter exit codes.
enum WtonMinterErrors {
    /// Sender is not the current or nominated administrator required by the operation.
    UnauthorizedAdmin = 73
    /// Attached value is below required gas or a burn notification came from another wallet.
    InvalidValueOrWallet = 74
    /// Requested amount exceeds attached TON/supply, or a discovery request lacks gas.
    InvalidAmountOrDiscoveryValue = 75
    /// Incoming opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return standard WTON jetton-master data.
get fun get_jetton_data(): WtonJettonData {
    throw 0;
}

/// Return the nominated administrator, if one exists.
get fun get_jetton_extra_data(): address? {
    throw 0;
}

/// Return the deterministic WTON wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return the deployed WTON version constant.
get fun version(): int {
    throw 0;
}
