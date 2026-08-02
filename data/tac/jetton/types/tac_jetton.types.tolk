/// TAC-origin Jetton master that maps a TON token contract to its EVM token address.
contract TacJetton {
    author: "TAC"
    description: "TAC Jetton master with cross-chain burn routing and an EVM token-address getter."
    storage: TacJettonStorage
    incomingMessages: TacJettonIncomingMessage
    outgoingMessages: TacJettonOutgoingMessage
    thrownErrors: TacJettonErrors
}

/// Cross-chain parameters referenced by a burn notification.
struct TacJettonBurnCrosschainPayload {
    /// Nanotons reserved for the resulting TAC cross-chain operation.
    crosschainTonAmount: coins
    /// Optional fee configuration forwarded to the TAC Cross-Chain Layer.
    feeData: cell?
    /// Optional EVM call payload forwarded to the TAC Cross-Chain Layer.
    evmData: cell?
}

/// TAC Cross-Chain Layer error that remints Jettons after a failed operation.
struct (0xae7df95b) TacJettonErrorNotification {
    /// Cross-chain operation query identifier.
    queryId: uint64
    /// Failed operation identifier carried by the Cross-Chain Layer.
    operation: uint32
    /// Owner whose deterministic Jetton wallet receives the reminted amount.
    ownerAddress: address
    /// Jetton amount restored after the failed operation.
    jettonAmount: coins
}

/// Admin request that mints Jettons and optionally updates metadata.
struct (0xd7b9c06e) TacJettonMint {
    /// Admin-selected identifier copied into the wallet internal transfer.
    queryId: uint64
    /// Owner address whose deterministic wallet receives the minted Jettons.
    recipientAddress: address
    /// Jetton amount minted in base units.
    jettonAmount: coins
    /// Address that receives excess TON after wallet processing.
    responseAddress: address?
    /// Nanotons forwarded by the receiving wallet.
    forwardTonAmount: coins
    /// Optional payload referenced directly by the wallet internal transfer.
    forwardPayload: cell?
    /// Optional replacement Jetton metadata content cell.
    newJettonContent: cell?
}

/// Wallet burn notification that either starts a TAC operation or returns excess value.
struct (0x7bdd97de) TacJettonBurnNotification {
    /// Query identifier copied from the wallet burn request.
    queryId: uint64
    /// Jetton amount removed from the total supply.
    jettonAmount: coins
    /// Owner used to authenticate the deterministic sending Jetton wallet.
    ownerAddress: address
    /// TAC Cross-Chain Layer address, or another address that receives excess TON.
    responseAddress: address?
    /// Referenced cross-chain parameters; successful processing requires this value.
    crosschainPayload: Cell<TacJettonBurnCrosschainPayload>?
}

/// Admin request that starts a two-step administrator change.
struct (0x581879bc) TacJettonChangeAdmin {
    /// Admin-selected request identifier.
    queryId: uint64
    /// Pending administrator; `addr_none` is rejected by the contract.
    newAdminAddress: address?
}

/// Current-admin request that clears the pending administrator.
struct (0x60094a1b) TacJettonCancelAdminChange {
    /// Admin-selected request identifier.
    queryId: uint64
}

/// Pending-admin request that accepts administrator ownership.
struct (0x6a4fbe34) TacJettonConfirmAdminChange {
    /// Pending-admin request identifier.
    queryId: uint64
}

/// Admin request that replaces Jetton metadata content.
struct (0x23f78ab7) TacJettonChangeContent {
    /// Admin-selected request identifier.
    queryId: uint64
    /// Referenced replacement TEP-64 metadata content cell.
    jettonContent: cell
}

/// Admin request that withdraws TON not reserved for storage.
struct (0x1754ab63) TacJettonWithdrawExtraTon {
    /// Admin-selected request identifier.
    queryId: uint64
}

/// Internal message bodies accepted by the TAC Jetton master.
type TacJettonIncomingMessage =
    | TacJettonErrorNotification
    | TacJettonMint
    | TacJettonBurnNotification
    | TacJettonChangeAdmin
    | TacJettonCancelAdminChange
    | TacJettonConfirmAdminChange
    | TacJettonChangeContent
    | TacJettonWithdrawExtraTon

/// Minter-to-wallet transfer used to deploy or credit a deterministic Jetton wallet.
struct (0x178d4519) TacJettonInternalTransfer {
    /// Query identifier copied from the mint or recovery request.
    queryId: uint64
    /// Jetton amount credited to the receiving wallet.
    jettonAmount: coins
    /// TAC Jetton master address used as the mint origin.
    senderAddress: address
    /// Address that receives excess TON after wallet processing.
    responseAddress: address?
    /// Nanotons forwarded by the receiving wallet.
    forwardTonAmount: coins
    /// Optional payload stored as a direct cell reference.
    forwardPayload: cell?
}

/// Cross-chain burn instruction emitted to the TAC Cross-Chain Layer.
struct (0x6c582059) TacJettonTvmMessageToEvm {
    /// Query identifier copied from the burn notification.
    queryId: uint64
    /// TAC operation identifier; Jetton burns use `0xb0afa74d`.
    operation: uint32
    /// Nanotons reserved for the cross-chain operation.
    crosschainTonAmount: coins
    /// Optional fee configuration forwarded to the Cross-Chain Layer.
    feeData: cell?
    /// TON address that receives a cross-chain response.
    responseAddress: address
    /// Jetton owner recorded in the cross-chain burn log.
    ownerAddress: address
    /// Burned Jetton amount in base units.
    jettonAmount: coins
    /// Optional EVM call payload copied from the burn request.
    evmData: cell?
}

/// Excess-value response emitted when a burn is not routed through the TAC layer.
struct (0xd53276db) TacJettonExcesses {
    /// Query identifier copied from the burn notification.
    queryId: uint64
    /// Optional EVM payload returned to the response recipient.
    evmData: cell?
}

/// Body-bearing internal messages emitted by the TAC Jetton master.
type TacJettonOutgoingMessage =
    | TacJettonInternalTransfer
    | TacJettonTvmMessageToEvm
    | TacJettonExcesses

/// Persistent TAC Jetton master state.
struct TacJettonStorage {
    /// Current issued Jetton supply encoded as TL-B Coins.
    totalSupply: coins
    /// Cross-Chain Layer administrator authorized to mint and process errors.
    adminAddress: address?
    /// Pending administrator for the two-step ownership change.
    newAdminAddress: address?
    /// Referenced TEP-64 Jetton metadata content cell.
    jettonContent: cell
    /// Referenced Jetton wallet code used for deterministic wallet derivation.
    jettonWalletCode: cell
    /// EVM token address string stored as the remaining root-cell bits and refs.
    evmTokenAddress: RemainingBitsAndRefs
}

/// Standard Jetton master data returned on the TVM stack.
struct TacJettonData {
    /// Current issued Jetton supply.
    totalSupply: int
    /// Mintability flag; the TAC minter returns true.
    mintable: bool
    /// Current Cross-Chain Layer administrator address.
    adminAddress: any_address
    /// TEP-64 Jetton metadata content cell.
    jettonContent: cell
    /// Jetton wallet code used for deterministic wallet derivation.
    jettonWalletCode: cell
}

/// Complete TAC Jetton master data returned on the TVM stack.
struct TacJettonFullData {
    /// Current issued Jetton supply.
    totalSupply: int
    /// Current Cross-Chain Layer administrator address.
    adminAddress: any_address
    /// Pending administrator, or `addr_none` when no change is active.
    newAdminAddress: any_address
    /// TEP-64 Jetton metadata content cell.
    jettonContent: cell
    /// Jetton wallet code used for deterministic wallet derivation.
    jettonWalletCode: cell
    /// EVM token address encoded as an ASCII Slice.
    evmTokenAddress: slice
}

/// Exit codes thrown by the deployed TAC Jetton master.
enum TacJettonErrors {
    /// A protected request was not sent by the current administrator.
    SenderIsNotAdmin = 73
    /// A burn notification was not sent by the owner's deterministic Jetton wallet.
    SenderIsNotJettonWallet = 74
    /// Administrator confirmation was not sent by the pending administrator.
    SenderIsNotNewAdmin = 75
    /// A change-admin request supplied `addr_none`.
    NewAdminAddressIsNone = 80
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Returns standard Jetton supply, admin, metadata, and wallet-code data.
get fun get_jetton_data(): TacJettonData {
    throw 0;
}

/// Returns the deterministic Jetton wallet address for an owner.
get fun get_wallet_address(ownerAddress: any_address): any_address {
    throw 0;
}

/// Returns the paired EVM token address as a 42-byte ASCII Slice.
get fun get_evm_token_address(): slice {
    throw 0;
}

/// Returns all stored TAC Jetton master fields on the TVM stack.
get fun get_full_data(): TacJettonFullData {
    throw 0;
}
