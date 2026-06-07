/// Stablecoin v1.04 Jetton minter with governed wallet controls and two-step admin transfer.
contract StablecoinMaster {
    author: "TON Core"
    version: "1.04"
    description: "Curated interface for ton-blockchain/stablecoin-contract v1.04 minter"
    storage: StablecoinMasterStorage
    incomingMessages: StablecoinMasterIncomingMessage
    outgoingMessages: StablecoinMasterOutgoingMessage
    forceAbiExport: StablecoinMasterWalletAdminAction
    thrownErrors: StablecoinMasterErrors
}

/// Persistent stablecoin minter state stored in the root data cell.
struct StablecoinMasterStorage {
    /// Total issued jettons encoded as TL-B `Coins` in storage.
    totalSupply: coins
    /// Current admin address authorized to mint, force wallet actions, and upgrade code/data.
    adminAddress: address
    /// Pending admin address for the two-step `change_admin` / `claim_admin` flow.
    nextAdminAddress: address?
    /// Referenced wallet code cell used to derive deterministic governed wallet addresses.
    jettonWalletCode: cell
    /// Referenced snake-encoded metadata URI cell stored without the on-chain metadata dictionary prefix.
    metadataUri: cell
}

/// Wallet action body accepted through the minter `call_to` command for forced transfers.
struct (0x0f8a7ea5) StablecoinMasterForceTransfer {
    /// Admin-selected query id forwarded to the governed wallet.
    queryId: uint64
    /// Jetton amount to debit from the target wallet, in base units.
    amount: coins
    /// Destination owner address whose deterministic wallet receives the transfer.
    destination: address
    /// Optional response address for wallet `Excesses`.
    responseDestination: address?
    /// Optional referenced TEP-74 custom payload.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner's notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet action body accepted through the minter `call_to` command for forced burns.
struct (0x595f07bc) StablecoinMasterForceBurn {
    /// Admin-selected query id forwarded to the governed wallet.
    queryId: uint64
    /// Jetton amount to burn from the target wallet, in base units.
    amount: coins
    /// Optional response address for the minter's `Excesses` after burn notification.
    responseDestination: address?
    /// Optional referenced TEP-74 custom payload.
    customPayload: cell?
}

/// Wallet action body accepted through the minter `call_to` command to change wallet lock status.
struct (0xeed236d3) StablecoinMasterSetStatus {
    /// Admin-selected query id forwarded to the governed wallet.
    queryId: uint64
    /// Four-bit lock mask: 0 unlocked, bit 0 disables outgoing, bit 1 disables incoming.
    status: uint4
}

/// Minter-to-wallet internal transfer body used by minting and wallet transfers.
struct (0x178d4519) StablecoinMasterJettonInternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the mint payload or sending wallet; mint wrappers may use `addr_none`.
    from: address?
    /// Optional response address for wallet `Excesses`.
    responseAddress: address?
    /// Nanotons forwarded to the recipient owner's notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin mint request accepted by the stablecoin minter.
struct (0x642b7d07) StablecoinMasterMint {
    /// Admin-selected query id carried only in the minter request.
    queryId: uint64
    /// Jetton owner address whose deterministic governed wallet receives the mint transfer.
    toAddress: address
    /// Nanotons attached to the wallet deployment/internal-transfer message.
    tonAmount: coins
    /// Referenced internal transfer body validated and forwarded to the recipient wallet.
    masterMsg: Cell<StablecoinMasterJettonInternalTransfer>
}

/// Burn notification sent by a deterministic governed wallet to decrease total supply.
struct (0x7bdd97de) StablecoinMasterBurnNotification {
    /// Query id copied from the original wallet burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Owner address whose deterministic wallet burned the jettons.
    sender: address
    /// Optional response address that receives an `Excesses` refund when non-null.
    responseDestination: address?
}

/// TEP-89 wallet discovery request accepted by the stablecoin minter.
struct (0x2c76b973) StablecoinMasterProvideWalletAddress {
    /// Caller-selected query id copied into the `TakeWalletAddress` response.
    queryId: uint64
    /// Owner address whose deterministic governed wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Admin request that sets the pending next admin address.
struct (0x6501f354) StablecoinMasterChangeAdmin {
    /// Admin-selected query id carried in the change request.
    queryId: uint64
    /// Pending admin address stored until that address sends `claim_admin`; may be `addr_none` to clear.
    newAdminAddress: address?
}

/// Pending-admin request that promotes `nextAdminAddress` to `adminAddress`.
struct (0xfb88e119) StablecoinMasterClaimAdmin {
    /// Query id carried by the pending-admin claim request.
    queryId: uint64
}

/// Admin request that forwards a validated wallet admin action to a governed wallet.
struct (0x235caf52) StablecoinMasterCallTo {
    /// Admin-selected query id carried by the minter request and expected inside the nested action.
    queryId: uint64
    /// Governed wallet address that receives the nested wallet action.
    toAddress: address
    /// Nanotons attached to the forwarded wallet action.
    tonAmount: coins
    /// Referenced wallet action body: transfer, burn, or status update.
    masterMsg: Cell<StablecoinMasterWalletAdminAction>
}

/// Admin request that replaces minter data and code.
struct (0x2508d66a) StablecoinMasterUpgrade {
    /// Admin-selected query id carried in the upgrade request.
    queryId: uint64
    /// Referenced replacement root data cell passed directly to `set_data`.
    newData: cell
    /// Referenced replacement code cell passed directly to `set_code`.
    newCode: cell
}

/// Admin request that replaces the stored snake metadata URI tail.
struct (0xcb862902) StablecoinMasterChangeMetadataUri {
    /// Admin-selected query id carried in the metadata change request.
    queryId: uint64
    /// Raw remaining body slice stored as the snake metadata URI cell.
    metadataUri: RemainingBitsAndRefs
}

/// Funding-only message accepted by the minter without changing state.
struct (0xd372158c) StablecoinMasterTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// TEP-74 excesses response emitted after burn notification processing when a response address is present.
struct (0xd53276db) StablecoinMasterExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// TEP-89 wallet discovery response emitted to the original requester.
struct (0xd1735400) StablecoinMasterTakeWalletAddress {
    /// Query id copied from the `ProvideWalletAddress` request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced cell containing the requested owner address when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Wallet admin actions accepted inside `StablecoinMasterCallTo.masterMsg`.
type StablecoinMasterWalletAdminAction =
    | StablecoinMasterForceTransfer
    | StablecoinMasterForceBurn
    | StablecoinMasterSetStatus

/// Internal message bodies accepted by the stablecoin v1.04 minter.
type StablecoinMasterIncomingMessage =
    | StablecoinMasterMint
    | StablecoinMasterBurnNotification
    | StablecoinMasterProvideWalletAddress
    | StablecoinMasterChangeAdmin
    | StablecoinMasterClaimAdmin
    | StablecoinMasterCallTo
    | StablecoinMasterUpgrade
    | StablecoinMasterChangeMetadataUri
    | StablecoinMasterTopUp

/// Statically known internal message bodies emitted by the stablecoin v1.04 minter.
type StablecoinMasterOutgoingMessage =
    | StablecoinMasterJettonInternalTransfer
    | StablecoinMasterForceTransfer
    | StablecoinMasterForceBurn
    | StablecoinMasterSetStatus
    | StablecoinMasterExcesses
    | StablecoinMasterTakeWalletAddress

/// Structured result returned by `get_jetton_data`.
struct GetStablecoinJettonDataReply {
    /// Total issued jettons returned as a TVM stack integer.
    totalSupply: int
    /// Source returns true because this minter can mint through the admin.
    mintable: bool
    /// Current admin address.
    adminAddress: address
    /// On-chain metadata dictionary built from the stored URI and fixed `decimals = 6`.
    jettonContent: cell
    /// Referenced governed wallet code cell embedded in deterministic wallet state init.
    jettonWalletCode: cell
}

/// Stablecoin v1.04 minter exit-code catalog from official FunC source.
enum StablecoinMasterErrors {
    /// Nested mint or `call_to` action opcode is not one of the accepted wallet actions.
    InvalidNestedOperation = 72
    /// Sender is not the stored admin or pending admin for the requested admin action.
    UnauthorizedAdmin = 73
    /// Burn notification sender is not the deterministic wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// Transfer or burn funding is below the required gas/forward-fee budget.
    NotEnoughGas = 48
    /// Forward payload layout is invalid for a validated nested transfer.
    InvalidMessage = 49
    /// Target owner or wallet address is outside the configured base workchain.
    WrongWorkchain = 333
    /// Incoming internal message opcode is not supported by the minter.
    UnsupportedOperation = 65535
}

/// Return supply, mintability, admin address, metadata content cell, and wallet code cell.
get fun get_jetton_data(): GetStablecoinJettonDataReply {
    throw 0;
}

/// Return the deterministic governed wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return the pending next admin `MsgAddress`, or `addr_none` when no admin claim is pending.
get fun get_next_admin_address(): any_address {
    throw 0;
}
