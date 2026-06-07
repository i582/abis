/// Getgems NFT raffle interface for two-party NFT exchange raffles.
contract GetgemsNftRaffle {
    author: "Getgems"
    version: "1.0"
    description: "Curated Getgems NFT raffle interface"
    storage: GetgemsNftRaffleStorage
    incomingMessages: GetgemsNftRaffleIncomingMessage
    outgoingMessages: GetgemsNftRaffleOutgoingMessage
    thrownErrors: GetgemsNftRaffleErrors
}

/// Root persistent raffle state; source stores each logical group in a referenced cell.
struct GetgemsNftRaffleStorage {
    /// Referenced counters and lifecycle state cell.
    state: Cell<GetgemsNftRaffleStateData>
    /// Referenced left/right/super-user address cell.
    addresses: Cell<GetgemsNftRaffleAddresses>
    /// Referenced commission and fee accounting cell.
    commissions: Cell<GetgemsNftRaffleCommissions>
    /// Referenced dictionary cell with expected NFT inventory and raffle result dictionaries.
    dictionaries: Cell<GetgemsNftRaffleDictionaries>
}

/// Lifecycle and NFT receipt counters stored in the first storage ref.
struct GetgemsNftRaffleStateData {
    /// Lifecycle code: 1 active, 2 canceled, 3 completed.
    state: uint2
    /// Number of NFTs the right user must provide.
    rightNftsCount: uint4
    /// Number of right-user NFTs already received.
    rightNftsReceived: uint4
    /// Number of NFTs the left user must provide.
    leftNftsCount: uint4
    /// Number of left-user NFTs already received.
    leftNftsReceived: uint4
}

/// Participant and maintenance addresses stored in the second storage ref.
struct GetgemsNftRaffleAddresses {
    /// Left participant allowed to add coins and cancel while active.
    leftUser: address
    /// Right participant allowed to add coins and cancel while active.
    rightUser: address
    /// Maintenance address allowed to relay raw messages after raffle leaves active state.
    superUser: address
}

/// Commission accounting stored in the third storage ref.
struct GetgemsNftRaffleCommissions {
    /// Required left-side commission in nanotons.
    leftCommission: coins
    /// Required right-side commission in nanotons.
    rightCommission: coins
    /// Extra nanotons received from the left side, after operation and NFT-transfer fees.
    leftCoinsGot: coins
    /// Extra nanotons received from the right side, after operation and NFT-transfer fees.
    rightCoinsGot: coins
    /// Per-NFT outbound transfer amount used when returning or raffling NFTs.
    nftTransferFee: coins
}

/// NFT inventory dictionaries stored in the fourth storage ref.
struct GetgemsNftRaffleDictionaries {
    /// NFT address-hash dictionary keyed by uint256; values are uint4 status codes 0/1 pending and 2/3 received.
    nfts: map<uint256, uint4>
    /// Raffle result dictionary keyed by uint256 NFT address hash; FunC sends flag 1 to leftUser and flag 0 to rightUser.
    raffledNfts: map<uint256, uint1>
}

/// Standard NFT ownership callback accepted from listed NFT item contracts.
struct (0x05138d91) GetgemsNftRaffleOwnershipAssigned {
    /// Query id skipped when the source needs to return an NFT.
    queryId: uint64
    /// Previous owner used as the return destination when the NFT is rejected.
    previousOwnerAddress: address?
    /// Standard callback tail ignored by the raffle source.
    forwardPayload: RemainingBitsAndRefs
}

/// Participant or super-user command that cancels an active raffle before all conditions are met.
struct (0x000007d1) GetgemsNftRaffleCancel {}

/// Left/right participant command that contributes additional commission nanotons.
struct (0x000007d2) GetgemsNftRaffleAddCoins {}

/// Super-user command that relays a raw message after the raffle is canceled or completed.
struct (0x000007d3) GetgemsNftRaffleMaintain {
    /// Raw outbound internal message loaded by reference and sent unchanged.
    rawMessage: cell
    /// Raw mode passed to `send_raw_message`.
    mode: uint8
}

/// Command that resends completed raffle NFT transfers using the attached value.
struct (0x000007d4) GetgemsNftRaffleSendAgain {}

/// NFT transfer message emitted when returning, canceling, completing, or resending raffle NFTs.
struct (0x5fcc3d14) GetgemsNftRaffleNftTransfer {
    /// Current logical time used as the query id.
    queryId: uint64
    /// NFT recipient: previous owner, original participant, or raffle winner depending on the branch.
    newOwnerAddress: address?
    /// Response destination mirrors the recipient address in this source.
    responseDestination: address?
    /// Always absent in this source.
    customPayload: cell?
    /// Always zero in the body; the outbound message value carries `nftTransferFee` or branch-specific amount.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; source emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Zero-op text notification emitted for cancel and commission-withdrawal messages.
struct (0x00000000) GetgemsNftRaffleTextNotification {
    /// Human-readable text-comment body after the zero opcode.
    text: string
}

/// Internal message bodies accepted by Getgems NFT raffle.
type GetgemsNftRaffleIncomingMessage =
    | GetgemsNftRaffleOwnershipAssigned
    | GetgemsNftRaffleCancel
    | GetgemsNftRaffleAddCoins
    | GetgemsNftRaffleMaintain
    | GetgemsNftRaffleSendAgain

/// Structured outgoing message bodies emitted by Getgems NFT raffle.
type GetgemsNftRaffleOutgoingMessage =
    | GetgemsNftRaffleNftTransfer
    | GetgemsNftRaffleTextNotification

/// Full stack result returned by `raffle_state`.
struct GetgemsNftRaffleStateReply {
    /// Lifecycle code: 1 active, 2 canceled, 3 completed.
    state: uint2
    /// Number of NFTs the right user must provide.
    rightNftsCount: uint4
    /// Number of right-user NFTs already received.
    rightNftsReceived: uint4
    /// Number of NFTs the left user must provide.
    leftNftsCount: uint4
    /// Number of left-user NFTs already received.
    leftNftsReceived: uint4
    /// Left participant address stored in raffle state.
    leftUser: address
    /// Right participant address stored in raffle state.
    rightUser: address
    /// Super-user address authorized for maintenance raw sends.
    superUser: address
    /// Required left-side commission in nanotons.
    leftCommission: coins
    /// Required right-side commission in nanotons.
    rightCommission: coins
    /// Extra nanotons received from the left side.
    leftCoinsGot: coins
    /// Extra nanotons received from the right side.
    rightCoinsGot: coins
    /// Per-NFT transfer amount used by outbound NFT transfers.
    nftTransferFee: coins
    /// Raw `HashmapE 256` NFT status dictionary returned on the stack; null means empty.
    nfts: cell?
    /// Raw `HashmapE 256` raffle-result dictionary returned on the stack; null means empty.
    raffledNfts: cell?
}

/// Source-level exit-code catalog for Getgems NFT raffle.
enum GetgemsNftRaffleErrors {
    /// Bounced inbound messages are rejected by the first internal-message flag check.
    BouncedInboundMessage = 0
    /// Command is invalid for the current lifecycle state.
    InvalidState = 1001
    /// Sender is not authorized for the requested operation.
    WrongAddress = 1002
    /// Attached nanotons are below the required operation or resend amount.
    NotEnoughCoins = 1003
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return full raffle state and raw dictionary cells.
get fun raffle_state(): GetgemsNftRaffleStateReply {
    throw 0;
}

/// Return whether all NFT receipt and commission conditions needed for completion are currently met.
get fun `utils::check_conditions`(): bool {
    throw 0;
}
