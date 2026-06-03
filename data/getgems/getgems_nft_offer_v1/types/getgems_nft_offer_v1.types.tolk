/// Getgems original NFT offer V1 interface reconstructed from upstream FunC source.
contract GetgemsNftOfferV1 {
    author: "Getgems"
    version: "1"
    description: "Curated Getgems NFT offer V1 interface"
    storage: GetgemsNftOfferV1Storage
    incomingMessages: GetgemsNftOfferV1IncomingMessage
    incomingExternal: GetgemsNftOfferV1IncomingExternalMessage
    outgoingMessages: GetgemsNftOfferV1OutgoingMessage
    forceAbiExport: GetgemsNftOfferV1InitialFunding | GetgemsNftOfferV1MarketplaceCancelPayload | GetgemsNftOfferV1RawSendAction
}

/// Referenced marketplace and royalty fee configuration cell.
struct GetgemsNftOfferV1Fees {
    /// Address receiving marketplace fee when the offer is accepted.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator used by the source percent helper.
    marketplaceFactor: uint32
    /// Marketplace fee denominator used by the source percent helper.
    marketplaceBase: uint32
    /// Royalty recipient; the source skips royalty payout when this is `addr_none`.
    royaltyAddress: address?
    /// Royalty numerator used by the source percent helper.
    royaltyFactor: uint32
    /// Royalty denominator used by the source percent helper.
    royaltyBase: uint32
}

/// Persistent V1 offer storage. The same shape is used before and after the first funding message.
struct GetgemsNftOfferV1Storage {
    /// True after the offer is accepted or cancelled.
    isComplete: bool
    /// Offer creation Unix timestamp stored as uint32.
    createdAt: uint32
    /// Expiry timestamp after which external cancellation is accepted.
    finishAt: uint32
    /// Marketplace address authorized for marketplace cancellation and emergency relay.
    marketplaceAddress: address
    /// NFT item address expected to send `ownership_assigned` on acceptance.
    nftAddress: address
    /// Offer creator address that receives the NFT when the offer is accepted.
    offerOwnerAddress: address
    /// Current offer amount in nanotons, encoded as TL-B `Coins`.
    fullPrice: coins
    /// Referenced fee and royalty configuration.
    fees: Cell<GetgemsNftOfferV1Fees>
    /// One-bit deployment flag; while true, the first internal message sets `fullPrice`.
    canDeploy: bool
}

/// State-dependent initial internal body; while `canDeploy` is set, source accepts any body and stores `msg_value`.
struct GetgemsNftOfferV1InitialFunding {
    /// Raw body ignored by the deployment branch.
    body: RemainingBitsAndRefs
}

/// Opcode-zero command. Text `cancel` cancels; non-cancel opcode zero from the offer owner tops up `fullPrice`.
struct (0x00000000) GetgemsNftOfferV1TextCommand {
    /// Raw text or payload tail after the zero opcode.
    payload: RemainingBitsAndRefs
}

/// TEP-62 ownership notification sent by the NFT item when an NFT owner accepts the offer.
struct (0x05138d91) GetgemsNftOfferV1OwnershipAssigned {
    /// Query id copied into outgoing NFT transfer bodies.
    queryId: uint64
    /// Previous NFT owner that receives the TON payout or the returned NFT.
    previousOwnerAddress: address
    /// Raw standard ownership-assigned tail ignored by this source.
    forwardPayload: RemainingBitsAndRefs
}

/// Marketplace-only emergency relay accepted after completion.
struct (0x0000022b) GetgemsNftOfferV1EmergencyProxy {
    /// Referenced raw send action containing send mode and raw message.
    action: Cell<GetgemsNftOfferV1RawSendAction>
}

/// Raw send action used only by the marketplace emergency relay command.
struct GetgemsNftOfferV1RawSendAction {
    /// Raw mode passed directly to `send_raw_message`.
    mode: uint8
    /// Complete raw message cell supplied by the marketplace.
    message: cell
}

/// Opcode-three cancellation. Marketplace cancellation parses a structured tail; owner cancellation ignores the tail.
struct (0x00000003) GetgemsNftOfferV1CancelOffer {
    /// Sender-dependent payload. See `GetgemsNftOfferV1MarketplaceCancelPayload` for the marketplace layout.
    payload: RemainingBitsAndRefs
}

/// Tail parsed after opcode three when the sender is the marketplace.
struct GetgemsNftOfferV1MarketplaceCancelPayload {
    /// Marketplace cancellation fee capped by source at 0.5 TON.
    cancelFee: coins
    /// Referenced body forwarded to the offer owner.
    ownerPayload: cell
}

/// External cancellation body accepted only after `finishAt`.
struct (0x00000000) GetgemsNftOfferV1ExternalCancel {
    /// Raw text tail forwarded to the offer owner after validation.
    text: RemainingBitsAndRefs
}

/// TEP-62 NFT transfer body emitted when accepting the offer or returning an unexpected NFT.
struct (0x5fcc3d14) GetgemsNftOfferV1NftTransfer {
    /// Query id copied from the NFT ownership callback.
    queryId: uint64
    /// Offer owner on successful swap, or previous owner on NFT return.
    newOwnerAddress: address
    /// Previous NFT owner in this source.
    responseAddress: address
    /// Always absent in this source.
    customPayload: cell?
    /// `0.01 TON` on successful swap, zero on NFT return.
    forwardTonAmount: coins
    /// Raw TEP-62 forward payload tail; source writes an empty inline payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Opcode-zero outgoing text-comment body for profit, royalty, marketplace fee, and cancel-fee payouts.
struct (0x00000000) GetgemsNftOfferV1TextComment {
    /// Raw UTF-8 text after the zero comment opcode.
    text: RemainingBitsAndRefs
}

/// Internal message bodies parsed by Getgems NFT offer V1.
type GetgemsNftOfferV1IncomingMessage =
    | GetgemsNftOfferV1TextCommand
    | GetgemsNftOfferV1OwnershipAssigned
    | GetgemsNftOfferV1EmergencyProxy
    | GetgemsNftOfferV1CancelOffer

/// External-in body accepted by Getgems NFT offer V1.
type GetgemsNftOfferV1IncomingExternalMessage = GetgemsNftOfferV1ExternalCancel

/// Statically known internal message bodies emitted by Getgems NFT offer V1.
type GetgemsNftOfferV1OutgoingMessage =
    | GetgemsNftOfferV1NftTransfer
    | GetgemsNftOfferV1TextComment

/// Structured result returned by `get_offer_data`.
struct GetgemsNftOfferV1OfferDataReply {
    /// Fixed magic `0x4f46464552`, ASCII `OFFER`.
    magic: uint64
    /// True after the offer is accepted or cancelled.
    isComplete: bool
    /// Offer creation Unix timestamp.
    createdAt: uint32
    /// Expiry timestamp for external cancellation.
    finishAt: uint32
    /// Marketplace address stored in offer state.
    marketplaceAddress: address
    /// NFT item address stored in offer state.
    nftAddress: address
    /// Offer creator address that receives the NFT on acceptance.
    offerOwnerAddress: address
    /// Current offer amount in nanotons.
    fullPrice: coins
    /// Marketplace fee recipient address.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator.
    marketplaceFactor: uint32
    /// Marketplace fee denominator.
    marketplaceBase: uint32
    /// Royalty recipient address, or `addr_none`.
    royaltyAddress: any_address
    /// Royalty numerator.
    royaltyFactor: uint32
    /// Royalty denominator.
    royaltyBase: uint32
    /// Approximate seller profit after fee and royalty; can be negative in malformed configs.
    profitPrice: int
}

/// Exit-code catalog proven by V1 FunC throw sites.
enum GetgemsNftOfferV1Errors {
    /// Offer is already accepted or cancelled.
    OfferAlreadyComplete = 404
    /// Cancellation sender is neither offer owner nor marketplace.
    UnauthorizedCancellation = 458
    /// External cancellation opcode is not zero.
    ExternalCancelInvalidOpcode = 4003
    /// External cancellation body has refs.
    ExternalCancelHasRefs = 4004
    /// External cancellation text tail is larger than 500 bits after opcode parsing.
    ExternalCancelBodyTooLarge = 4005
    /// External cancellation arrived before `finishAt`.
    ExternalCancelTooEarly = 65534
    /// Internal message opcode is not supported.
    UnknownOperation = 65535
}

/// Return offer state, fee settings, and computed profit.
get fun get_offer_data(): GetgemsNftOfferV1OfferDataReply {
    // ABI-export scaffolding: constant assertions make every source-thrown error variant visible in thrown_errors.
    assert (true) throw GetgemsNftOfferV1Errors.OfferAlreadyComplete;
    assert (true) throw GetgemsNftOfferV1Errors.UnauthorizedCancellation;
    assert (true) throw GetgemsNftOfferV1Errors.ExternalCancelInvalidOpcode;
    assert (true) throw GetgemsNftOfferV1Errors.ExternalCancelHasRefs;
    assert (true) throw GetgemsNftOfferV1Errors.ExternalCancelBodyTooLarge;
    assert (true) throw GetgemsNftOfferV1Errors.ExternalCancelTooEarly;
    assert (true) throw GetgemsNftOfferV1Errors.UnknownOperation;
    return {
        magic: 0x4f46464552,
        isComplete: false,
        createdAt: 0,
        finishAt: 0,
        marketplaceAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nftAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        offerOwnerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        fullPrice: 0,
        marketplaceFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        marketplaceFactor: 0,
        marketplaceBase: 0,
        royaltyAddress: createAddressNone(),
        royaltyFactor: 0,
        royaltyBase: 0,
        profitPrice: 0,
    };
}
