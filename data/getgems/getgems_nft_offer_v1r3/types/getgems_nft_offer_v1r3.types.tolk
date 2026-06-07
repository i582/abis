/// Getgems NFT offer V1R3 interface reconstructed from upstream FunC source.
contract GetgemsNftOfferV1R3 {
    author: "Getgems"
    version: "1r3"
    description: "Curated Getgems NFT offer V1R3 interface with swap timestamp getter"
    storage: GetgemsNftOfferV1R3Storage
    incomingMessages: GetgemsNftOfferV1R3IncomingMessage
    incomingExternal: GetgemsNftOfferV1R3IncomingExternalMessage
    outgoingMessages: GetgemsNftOfferV1R3OutgoingMessage
    forceAbiExport: GetgemsNftOfferV1R3InitialFunding
        | GetgemsNftOfferV1R3MarketplaceCancelPayload
        | GetgemsNftOfferV1R3RawSendAction
    thrownErrors: GetgemsNftOfferV1R3Errors
}

/// Referenced marketplace and royalty fee configuration cell.
struct GetgemsNftOfferV1R3Fees {
    /// Address receiving marketplace fee when the offer is accepted.
    marketplaceFeeAddress: address
    /// Marketplace fee numerator used by the source percent helper.
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator used by the source percent helper.
    marketplaceFeeBase: uint32
    /// Royalty recipient; source skips royalty payout when this is `addr_none`.
    royaltyAddress: address?
    /// Royalty numerator used by the source percent helper.
    royaltyFeeFactor: uint32
    /// Royalty denominator used by the source percent helper.
    royaltyFeeBase: uint32
}

/// Persistent V1R3 offer storage. The same root shape is used before and after the first funding message.
struct GetgemsNftOfferV1R3Storage {
    /// True after the offer is accepted or cancelled.
    isComplete: bool
    /// Offer creation Unix timestamp stored as uint32.
    createdAt: uint32
    /// Expiry timestamp after which external cancellation is accepted.
    finishAt: uint32
    /// Timestamp when the NFT swap completed; zero before successful acceptance or after cancellation.
    swapAt: uint32
    /// Marketplace address authorized for marketplace cancellation and emergency relay.
    marketplaceAddress: address
    /// NFT item address expected to send `ownership_assigned` on acceptance.
    nftAddress: address
    /// Offer creator address that receives the NFT when the offer is accepted.
    offerOwnerAddress: address
    /// Current offer amount in nanotons, encoded as TL-B `Coins`.
    fullPrice: coins
    /// Referenced fee and royalty configuration.
    fees: Cell<GetgemsNftOfferV1R3Fees>
    /// One-bit deployment flag; while true, the first internal message sets `fullPrice`.
    canDeploy: bool
}

/// State-dependent initial internal body; while `canDeploy` is set, source accepts any body and stores `msg_value`.
struct GetgemsNftOfferV1R3InitialFunding {
    /// Raw body ignored by the deployment branch.
    body: RemainingBitsAndRefs
}

/// Opcode-zero command. Text `cancel` cancels; non-cancel opcode zero from the offer owner tops up `fullPrice`.
struct (0x00000000) GetgemsNftOfferV1R3TextCommand {
    /// Raw text or payload tail after the zero opcode.
    payload: RemainingBitsAndRefs
}

/// TEP-62 ownership notification sent by the NFT item when an NFT owner accepts the offer.
struct (0x05138d91) GetgemsNftOfferV1R3OwnershipAssigned {
    /// Query id copied into outgoing NFT transfer bodies.
    queryId: uint64
    /// Previous NFT owner that receives the TON payout or the returned NFT.
    previousOwnerAddress: address
    /// Raw standard ownership-assigned tail ignored by this source.
    forwardPayload: RemainingBitsAndRefs
}

/// Marketplace-only emergency relay accepted after completion.
struct (0x0000022b) GetgemsNftOfferV1R3EmergencyProxy {
    /// Referenced raw send action containing send mode and raw message.
    action: Cell<GetgemsNftOfferV1R3RawSendAction>
}

/// Raw send action used only by the marketplace emergency relay command.
struct GetgemsNftOfferV1R3RawSendAction {
    /// Raw mode passed directly to `send_raw_message`; mode bit 32 is rejected.
    mode: uint8
    /// Complete raw message cell supplied by the marketplace.
    message: cell
}

/// Opcode-three cancellation. Marketplace cancellation parses a structured tail; owner cancellation ignores the tail.
struct (0x00000003) GetgemsNftOfferV1R3CancelOffer {
    /// Sender-dependent payload. See `GetgemsNftOfferV1R3MarketplaceCancelPayload` for the marketplace layout.
    payload: RemainingBitsAndRefs
}

/// Tail parsed after opcode three when the sender is the marketplace.
struct GetgemsNftOfferV1R3MarketplaceCancelPayload {
    /// Marketplace cancellation fee capped by source at 0.5 TON.
    cancelFee: coins
    /// Referenced body forwarded to the offer owner.
    ownerPayload: cell
}

/// External cancellation body accepted only after `finishAt`.
struct (0x00000000) GetgemsNftOfferV1R3ExternalCancel {
    /// Raw text tail forwarded to the offer owner after validation.
    text: RemainingBitsAndRefs
}

/// TEP-62 NFT transfer body emitted when accepting the offer or returning an unexpected NFT.
struct (0x5fcc3d14) GetgemsNftOfferV1R3NftTransfer {
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

/// Opcode-zero outgoing text-comment body for profit, royalty, marketplace fee, cancel-fee, and expiry-cancel payouts.
struct (0x00000000) GetgemsNftOfferV1R3TextComment {
    /// Raw UTF-8 text after the zero comment opcode.
    text: RemainingBitsAndRefs
}

/// Internal message bodies parsed by Getgems NFT offer V1R3.
type GetgemsNftOfferV1R3IncomingMessage =
    | GetgemsNftOfferV1R3TextCommand
    | GetgemsNftOfferV1R3OwnershipAssigned
    | GetgemsNftOfferV1R3EmergencyProxy
    | GetgemsNftOfferV1R3CancelOffer

/// External-in body accepted by Getgems NFT offer V1R3.
type GetgemsNftOfferV1R3IncomingExternalMessage = GetgemsNftOfferV1R3ExternalCancel

/// Statically known internal message bodies emitted by Getgems NFT offer V1R3.
type GetgemsNftOfferV1R3OutgoingMessage =
    | GetgemsNftOfferV1R3NftTransfer
    | GetgemsNftOfferV1R3TextComment

/// Structured result returned by legacy `get_offer_data`.
struct GetgemsNftOfferV1R3OfferDataReply {
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
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty recipient address, or `addr_none`.
    royaltyAddress: any_address
    /// Royalty numerator.
    royaltyFeeFactor: uint32
    /// Royalty denominator.
    royaltyFeeBase: uint32
    /// Approximate seller profit after fee and royalty; can be negative in malformed configs.
    profitPrice: int
}

/// Structured result returned by V1R3 `get_offer_data_v2`.
struct GetgemsNftOfferV1R3OfferDataV2Reply {
    /// Fixed magic `0x4f46464552`, ASCII `OFFER`.
    magic: uint64
    /// True after the offer is accepted or cancelled.
    isComplete: bool
    /// Offer creation Unix timestamp.
    createdAt: uint32
    /// Expiry timestamp for external cancellation.
    finishAt: uint32
    /// Timestamp when the NFT swap completed; zero before successful acceptance or after cancellation.
    swapAt: uint32
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
    marketplaceFeeFactor: uint32
    /// Marketplace fee denominator.
    marketplaceFeeBase: uint32
    /// Royalty recipient address, or `addr_none`.
    royaltyAddress: any_address
    /// Royalty numerator.
    royaltyFeeFactor: uint32
    /// Royalty denominator.
    royaltyFeeBase: uint32
    /// Approximate seller profit after fee and royalty; can be negative in malformed configs.
    profitPrice: int
}

/// Exit-code catalog proven by V1R3 FunC throw sites.
enum GetgemsNftOfferV1R3Errors {
    /// Offer is already accepted or cancelled.
    OfferAlreadyComplete = 404
    /// Emergency relay send mode includes bit 32.
    EmergencyProxyMode32NotAllowed = 405
    /// Emergency relay is too close to `swapAt`.
    EmergencyProxySwapWindowBlocked = 406
    /// Deployment funding would leave profit below 0.005 TON.
    ProfitTooLowOnDeploy = 407
    /// Getter called before deployment funding is finalized.
    GetterBeforeDeployFinalized = 408
    /// Getter profit calculation is below 0.005 TON.
    ProfitTooLow = 409
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

/// Return legacy offer state, fee settings, and computed profit.
get fun get_offer_data(): GetgemsNftOfferV1R3OfferDataReply {
    throw 0;
}

/// Return V1R3 offer state, including `swapAt`, fee settings, and computed profit.
get fun get_offer_data_v2(): GetgemsNftOfferV1R3OfferDataV2Reply {
    throw 0;
}
