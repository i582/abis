/// Stablecoin v1.04 governed Jetton wallet with lock status and admin-controlled actions.
contract StablecoinWallet {
    author: "TON Core"
    version: "1.04"
    description: "Curated interface for ton-blockchain/stablecoin-contract v1.04 governed wallet"
    storage: StablecoinWalletStorage
    incomingMessages: StablecoinWalletIncomingMessage
    outgoingMessages: StablecoinWalletOutgoingMessage
}

/// Persistent governed wallet state stored in the root data cell.
struct StablecoinWalletStorage {
    /// Four-bit lock mask: 0 unlocked, bit 0 disables outgoing, bit 1 disables incoming.
    status: uint4
    /// Jetton balance encoded as TL-B `Coins` in storage.
    balance: coins
    /// Owner address normally authorized for outgoing transfers when status permits.
    ownerAddress: address
    /// Stablecoin minter/master address authenticated for mint and admin-originated wallet actions.
    jettonMasterAddress: address
}

/// Owner- or master-originated transfer request accepted by the governed wallet.
struct (0x0f8a7ea5) StablecoinWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// Jetton amount to debit from this wallet, in base units.
    amount: coins
    /// Destination owner address whose deterministic wallet receives the transfer.
    destination: address
    /// Optional response address for an `Excesses` refund.
    responseDestination: address?
    /// Optional referenced custom payload; source validates the field shape and ignores content.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or minter-to-wallet TEP-74 internal transfer body.
struct (0x178d4519) StablecoinWalletInternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the sending wallet or mint payload.
    from: address?
    /// Optional response address for an `Excesses` refund after processing.
    responseAddress: address?
    /// Nanotons forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Master-originated burn request accepted by the governed wallet.
struct (0x595f07bc) StablecoinWalletBurn {
    /// Caller-selected query id copied into the burn notification.
    queryId: uint64
    /// Jetton amount to burn from this wallet, in base units.
    amount: coins
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
    /// Optional referenced custom payload; source validates the field shape and ignores content.
    customPayload: cell?
}

/// Minter-originated status update accepted by the governed wallet.
struct (0xeed236d3) StablecoinWalletSetStatus {
    /// Admin-selected query id forwarded by the minter.
    queryId: uint64
    /// Four-bit lock mask: 0 unlocked, bit 0 disables outgoing, bit 1 disables incoming.
    status: uint4
}

/// Funding-only message accepted by the wallet without changing state.
struct (0xd372158c) StablecoinWalletTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// Burn notification emitted to the minter after a successful governed wallet burn.
struct (0x7bdd97de) StablecoinWalletBurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Wallet owner address reported to the minter.
    sender: address
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
}

/// Owner notification emitted when an incoming transfer carries forward TON.
struct (0x7362d09c) StablecoinWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received jetton amount in base units.
    amount: coins
    /// Source owner address reported by the internal transfer.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excesses response emitted to a transfer response address when value remains after processing.
struct (0xd53276db) StablecoinWalletExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the stablecoin v1.04 governed wallet.
type StablecoinWalletIncomingMessage =
    | StablecoinWalletTransfer
    | StablecoinWalletInternalTransfer
    | StablecoinWalletBurn
    | StablecoinWalletSetStatus
    | StablecoinWalletTopUp

/// Internal message bodies emitted by the stablecoin v1.04 governed wallet.
type StablecoinWalletOutgoingMessage =
    | StablecoinWalletInternalTransfer
    | StablecoinWalletBurnNotification
    | StablecoinWalletTransferNotification
    | StablecoinWalletExcesses

/// Structured result returned by `get_wallet_data`.
struct GetStablecoinWalletDataReply {
    /// Jetton balance returned as a TVM stack integer.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// Stablecoin minter/master address.
    jettonMasterAddress: address
    /// Current wallet code cell; live deployments may expose an exotic library reference cell.
    jettonWalletCode: cell
}

/// Stablecoin v1.04 governed wallet exit-code catalog from official FunC source.
enum StablecoinWalletErrors {
    /// Wallet status prevents the attempted outgoing or incoming transfer.
    ContractLocked = 45
    /// Transfer or burn would make the stored jetton balance negative.
    InsufficientJettonBalance = 47
    /// Transfer or burn funding is below the required gas/forward-fee budget.
    NotEnoughGas = 48
    /// Forward payload layout is invalid for a validated transfer.
    InvalidMessage = 49
    /// Sender is neither the stored owner nor the authenticated minter where required.
    UnauthorizedOwnerOrMaster = 73
    /// Internal transfer, burn, or status sender is not authenticated.
    InvalidSender = 74
    /// Destination owner address is outside the configured base workchain.
    WrongWorkchain = 333
    /// Incoming internal message opcode is unsupported, or bounced body opcode is not recognized.
    UnsupportedOperation = 65535
}

/// Return wallet balance, owner address, minter address, and wallet code cell.
get fun get_wallet_data(): GetStablecoinWalletDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw StablecoinWalletErrors.ContractLocked;
    assert (true) throw StablecoinWalletErrors.InsufficientJettonBalance;
    assert (true) throw StablecoinWalletErrors.NotEnoughGas;
    assert (true) throw StablecoinWalletErrors.InvalidMessage;
    assert (true) throw StablecoinWalletErrors.UnauthorizedOwnerOrMaster;
    assert (true) throw StablecoinWalletErrors.InvalidSender;
    assert (true) throw StablecoinWalletErrors.WrongWorkchain;
    assert (true) throw StablecoinWalletErrors.UnsupportedOperation;
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the current four-bit wallet lock status.
get fun get_status(): uint4 {
    return 0;
}
