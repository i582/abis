/// Acton Tolk jetton template wallet interface.
contract JettonWallet {
    author: "Petr Makhnev"
    version: "2.1"
    description: "Standard Tolk Jetton Wallet used by the Acton jetton project template. TEP-74 and TEP-89 compliant."
    storage: WalletStorage
    incomingMessages: JettonWalletIncomingMessage
    outgoingMessages: JettonWalletOutgoingMessage
    thrownErrors: JettonWalletErrors
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

/// Owner-originated TEP-74 transfer request accepted by a jetton wallet.
struct (0x0f8a7ea5) AskToTransfer {
    /// Caller-selected query id copied into downstream messages.
    queryId: uint64
    /// Jetton amount debited from this wallet in base units.
    jettonAmount: coins
    /// Destination owner address that receives jettons.
    transferRecipient: address
    /// Optional address that receives excess TON after processing.
    sendExcessesTo: address?
    /// Optional custom payload cell carried by the transfer request.
    customPayload: cell?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// TEP-74 Either payload tail forwarded to the recipient owner notification.
    @abi.clientType(PayloadInline | PayloadInRef)
    forwardPayload: ForwardPayloadRemainder
}

/// Owner notification emitted when an incoming transfer carries forward TON.
struct (0x7362d09c) TransferNotificationForRecipient {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received jetton amount in base units.
    jettonAmount: coins
    /// Owner address that initiated the transfer, or null for mint-originated transfers.
    transferInitiator: address?
    /// TEP-74 Either payload tail delivered to the owner.
    @abi.clientType(PayloadInline | PayloadInRef)
    forwardPayload: ForwardPayloadRemainder
}

/// Minter-to-wallet or wallet-to-wallet TEP-74 internal transfer body.
struct (0x178d4519) InternalTransferStep {
    /// Query id copied from the mint or transfer request.
    queryId: uint64
    /// Jetton amount credited to the wallet in base units.
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

/// TEP-74 excesses response returned after transfer processing.
struct (0xd53276db) ReturnExcessesBack {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Owner-originated TEP-74 burn request accepted by a jetton wallet.
struct (0x595f07bc) AskToBurn {
    /// Caller-selected query id copied into the burn notification.
    queryId: uint64
    /// Jetton amount debited and burned in base units.
    jettonAmount: coins
    /// Optional address that receives excess TON from the minter.
    sendExcessesTo: address?
    /// Optional custom payload cell carried by the burn request.
    customPayload: cell?
}

/// Burn notification emitted by a wallet to the minter.
struct (0x7bdd97de) BurnNotificationForMinter {
    /// Query id copied from the burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    jettonAmount: coins
    /// Owner address whose wallet burned jettons.
    burnInitiator: address
    /// Optional address that receives remaining TON after burn accounting.
    sendExcessesTo: address?
}

/// Funding-only message accepted without changing jetton balance.
struct (0xd372158c) TopUpTons {}

/// Persistent wallet state stored in the root data cell.
struct WalletStorage {
    /// Wallet jetton balance encoded as TL-B Coins.
    jettonBalance: coins
    /// Owner address authorized for outgoing transfer and burn requests.
    ownerAddress: address
    /// Minter address accepted as the mint-originated transfer sender.
    minterAddress: address
}

/// Internal message bodies accepted by the wallet.
type JettonWalletIncomingMessage =
    | AskToTransfer
    | AskToBurn
    | InternalTransferStep
    | TopUpTons

/// Internal message bodies emitted by the wallet.
type JettonWalletOutgoingMessage =
    | TransferNotificationForRecipient
    | ReturnExcessesBack
    | InternalTransferStep
    | BurnNotificationForMinter

/// Stack tuple returned by get_wallet_data.
struct JettonWalletDataReply {
    /// Wallet jetton balance returned as TL-B Coins.
    jettonBalance: coins
    /// Wallet owner address.
    ownerAddress: address
    /// Jetton minter address.
    minterAddress: address
    /// Current wallet code cell.
    jettonWalletCode: cell
}

/// Exit-code catalog used by the Tolk jetton template wallet.
enum JettonWalletErrors {
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

/// Return wallet balance, owner address, minter address, and wallet code.
get fun get_wallet_data(): JettonWalletDataReply {
    throw 0;
}
