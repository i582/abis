/// Getgems NFT swap interface reconstructed from `packages/contracts/sources/nft-swap.fc`.
contract GetgemsNftSwap {
    author: "Getgems"
    version: "1.0"
    description: "Curated Getgems two-party NFT swap interface"
    storage: GetgemsNftSwapStorage
    incomingMessages: GetgemsNftSwapIncomingMessage
    outgoingMessages: GetgemsNftSwapOutgoingMessage
    thrownErrors: GetgemsNftSwapErrors
}

/// Persistent swap state stored in the root data cell.
@overflow1023_policy("suppress")
struct GetgemsNftSwapStorage {
    /// Lifecycle code: 1 active, 2 canceled, 3 completed.
    state: uint2
    /// Left participant allowed to add coins and cancel while active.
    leftTrader: address
    /// Right participant allowed to add coins and cancel while active.
    rightTrader: address
    /// Required left-side commission in nanotons.
    leftCommission: coins
    /// Required left-side surcharge in nanotons, transferred to the right trader on completion.
    leftSurcharge: coins
    /// Nanotons already received from the left side.
    leftCoinsGot: coins
    /// NFT status dictionary keyed by NFT item address hash; value 0 means pending, 1 means received.
    leftNft: map<uint256, uint1>
    /// Required right-side commission in nanotons.
    rightCommission: coins
    /// Required right-side surcharge in nanotons, transferred to the left trader on completion.
    rightSurcharge: coins
    /// Nanotons already received from the right side.
    rightCoinsGot: coins
    /// NFT status dictionary keyed by NFT item address hash; value 0 means pending, 1 means received.
    rightNft: map<uint256, uint1>
    /// Referenced maintenance and commission addresses.
    controls: Cell<GetgemsNftSwapControls>
}

/// Referenced control-address cell stored at the end of swap storage.
struct GetgemsNftSwapControls {
    /// Address receiving remaining commission balance after completion or cancellation.
    commissionGainer: address
    /// Supervisor address allowed to cancel and relay maintenance messages.
    supervisor: address
}

/// Standard NFT ownership callback accepted from required NFT item contracts.
struct (0x05138d91) GetgemsNftSwapOwnershipAssigned {
    /// Query id copied into outbound NFT transfers and trade notifications.
    queryId: uint64
    /// Previous NFT owner used as the return destination when the NFT is rejected.
    previousOwnerAddress: address
    /// Standard callback tail ignored by the swap source after the previous owner is parsed.
    forwardPayload: RemainingBitsAndRefs
}

/// Participant command that contributes additional nanotons to the sender side.
struct (0x00000001) GetgemsNftSwapAddCoins {
    /// Query id copied if the contribution completes the swap.
    queryId: uint64
    /// Nanotons credited to the sender side; source rejects values greater than `msg_value`.
    coins: coins
}

/// Trader or supervisor command that cancels an active swap.
struct (0x00000002) GetgemsNftSwapCancel {
    /// Query id copied into cancellation transfers and notifications.
    queryId: uint64
}

/// Supervisor-only command that relays an arbitrary raw outbound message.
struct (0x00000003) GetgemsNftSwapMaintain {
    /// Query id parsed by the shared dispatcher before the supervisor-only relay fields.
    queryId: uint64
    /// Raw mode passed to `send_raw_message`.
    mode: uint8
    /// Raw outbound message cell loaded by reference and sent unchanged.
    message: cell
}

/// Top-up/no-op command that may complete an already satisfied active swap.
struct (0x00000004) GetgemsNftSwapTopup {
    /// Query id copied if the top-up triggers completion.
    queryId: uint64
}

/// NFT transfer message emitted when returning, completing, or canceling swap NFTs.
struct (0x5fcc3d14) GetgemsNftSwapNftTransfer {
    /// Query id copied from the inbound command or ownership callback.
    queryId: uint64
    /// NFT recipient: the opposite trader on completion, or the original owner on return/cancel.
    newOwnerAddress: address
    /// Response destination mirrors the recipient address in this source.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// Always zero in the body; outbound message value is `0.05 TON` except rejected returns.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Trade-completed notification sent to both traders with returned surplus/surcharge value.
struct (0xef03d009) GetgemsNftSwapTradeCompleted {
    /// Query id copied from the inbound command that completed the swap.
    queryId: uint64
}

/// Trade-canceled notification sent to both traders with returned side balances.
struct (0xb5188860) GetgemsNftSwapTradeCanceled {
    /// Query id copied from the cancellation command.
    queryId: uint64
}

/// Commission-withdrawal notification sent to the commission recipient.
struct (0x82bd8f2a) GetgemsNftSwapTradeCommission {
    /// Query id copied from the completion or cancellation flow.
    queryId: uint64
}

/// Internal message bodies accepted by Getgems NFT swap.
type GetgemsNftSwapIncomingMessage =
    | GetgemsNftSwapOwnershipAssigned
    | GetgemsNftSwapAddCoins
    | GetgemsNftSwapCancel
    | GetgemsNftSwapMaintain
    | GetgemsNftSwapTopup

/// Structured outgoing message bodies emitted by Getgems NFT swap.
type GetgemsNftSwapOutgoingMessage =
    | GetgemsNftSwapNftTransfer
    | GetgemsNftSwapTradeCompleted
    | GetgemsNftSwapTradeCanceled
    | GetgemsNftSwapTradeCommission

/// Structured result returned by `get_trade_state`.
struct GetgemsNftSwapTradeStateReply {
    /// Lifecycle code: 1 active, 2 canceled, 3 completed.
    state: uint2
    /// True when all left-side NFTs and nanotons are received.
    leftOk: bool
    /// True when all right-side NFTs and nanotons are received.
    rightOk: bool
    /// Left participant address stored in swap state.
    leftTrader: address
    /// Right participant address stored in swap state.
    rightTrader: address
    /// Raw `HashmapE 256` left NFT status dictionary returned on the stack; null means empty.
    leftNft: cell?
    /// Raw `HashmapE 256` right NFT status dictionary returned on the stack; null means empty.
    rightNft: cell?
    /// Required left-side commission in nanotons.
    leftCommission: int
    /// Required left-side surcharge in nanotons.
    leftSurcharge: int
    /// Nanotons received from the left side.
    leftCoinsGot: int
    /// Required right-side commission in nanotons.
    rightCommission: int
    /// Required right-side surcharge in nanotons.
    rightSurcharge: int
    /// Nanotons received from the right side.
    rightCoinsGot: int
}

/// Source-level exit-code catalog for Getgems NFT swap.
enum GetgemsNftSwapErrors {
    /// Sender is not authorized for add-coins, cancel, or maintain.
    UnauthorizedSender = 401
    /// Sender address is not `addr_std`, or command requires active state.
    InvalidStateOrSenderAddress = 403
    /// Attached value is below the NFT minimum, or add-coins body exceeds message value.
    InsufficientValue = 405
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return full swap state, condition flags, and raw NFT dictionaries.
get fun get_trade_state(): GetgemsNftSwapTradeStateReply {
    throw 0;
}

/// Return the supervisor address authorized for cancellation and maintenance.
get fun get_supervisor(): address {
    throw 0;
}
