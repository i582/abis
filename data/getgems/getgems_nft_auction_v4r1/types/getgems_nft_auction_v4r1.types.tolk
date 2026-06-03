/// Getgems NFT Auction V4 R1 interface for TON and Jetton bid auctions.
contract GetgemsNftAuctionV4R1 {
    author: "Getgems"
    version: "4r1"
    description: "Curated Getgems NFT auction V4R1 interface with storage, bid commands, settlement messages, and getter"
    storage: GetgemsNftAuctionV4R1Storage
    incomingMessages: GetgemsNftAuctionV4R1IncomingMessage
    incomingExternal: GetgemsNftAuctionV4R1IncomingExternalMessage
    outgoingMessages: GetgemsNftAuctionV4R1OutgoingMessage
    forceAbiExport: GetgemsNftAuctionV4R1RawSendAction
}

/// Persistent root data cell used by initialized and deploy-time auction states.
struct GetgemsNftAuctionV4R1Storage {
    /// True after the auction was cancelled, force-closed, or settled.
    end: bool
    /// True only when the final state returned the NFT without a winning bid.
    isCanceled: bool
    /// Last bidder address; `addr_none` before the first bid.
    lastMember: address?
    /// Last bid amount encoded as TL-B `Coins`.
    lastBid: coins
    /// Unix timestamp of the last accepted bid, or zero before bidding.
    lastBidAt: uint32
    /// Scheduled auction end Unix timestamp.
    endTime: uint32
    /// NFT owner/proceeds recipient; `addr_none` before ownership assignment activates the auction.
    nftOwner: address?
    /// Query id from the last accepted bid or state-changing command.
    lastQueryId: uint64
    /// Referenced marketplace and royalty fee configuration.
    fees: Cell<GetgemsNftAuctionV4R1Fees>
    /// Referenced immutable auction configuration.
    constants: Cell<GetgemsNftAuctionV4R1Constants>
    /// Optional referenced Jetton-mode configuration; absent for TON auctions.
    jettonData: Cell<GetgemsNftAuctionV4R1JettonData>?
}

/// Fee addresses and fee fractions stored in the first storage ref.
struct GetgemsNftAuctionV4R1Fees {
    /// Marketplace fee recipient.
    marketFeeAddress: address
    /// Royalty fee recipient.
    royaltyAddress: address
    /// Marketplace fee numerator.
    mpFeeFactor: uint32
    /// Marketplace fee denominator.
    mpFeeBase: uint32
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
}

/// Immutable auction parameters stored in the second storage ref.
struct GetgemsNftAuctionV4R1Constants {
    /// Marketplace address authorized for administrative recovery flows.
    marketplace: address
    /// Initial minimum bid encoded as TL-B `Coins`.
    minBid: coins
    /// Buy-now bid cap encoded as TL-B `Coins`; zero disables immediate settlement.
    maxBid: coins
    /// Minimum percentage step stored in 7 bits.
    minStep: uint7
    /// Anti-sniping end-time extension step stored in 17 bits.
    stepTime: uint17
    /// NFT item address controlled by the auction.
    nft: address
    /// Auction creation Unix timestamp.
    createdAt: uint32
}

/// Optional Jetton-mode configuration stored as a referenced cell.
struct GetgemsNftAuctionV4R1JettonData {
    /// Auction Jetton wallet; may temporarily hold an expected sender before wallet resolution.
    jettonWallet: address?
    /// Jetton master address used to detect unresolved Jetton-mode setup.
    jettonMaster: address?
    /// Optional Ed25519 public key used once to authorize the resolved Jetton wallet address.
    publicKey: uint256?
}

/// NFT ownership assignment notification accepted from the configured NFT item before activation.
struct (0x05138d91) GetgemsNftAuctionV4R1OwnershipAssigned {
    /// Query id from the NFT transfer request; source skips it during activation.
    queryId: uint64
    /// Previous owner address that becomes the auction NFT owner/proceeds recipient.
    previousOwnerAddress: address
    /// Raw forwarded payload tail ignored by the auction source.
    forwardPayload: RemainingBitsAndRefs
}

/// Marketplace emergency proxy command carrying one raw send action in a ref.
struct (0x0000022b) GetgemsNftAuctionV4R1EmergencyProxy {
    /// Marketplace-selected query id parsed by the shared dispatcher.
    queryId: uint64
    /// Referenced action cell containing send mode and raw message ref.
    action: Cell<GetgemsNftAuctionV4R1RawSendAction>
}

/// Raw send action used only by the marketplace emergency proxy command.
struct GetgemsNftAuctionV4R1RawSendAction {
    /// Raw mode passed directly to `send_raw_message`; mode bit 32 is rejected.
    mode: uint8
    /// Raw outbound message cell supplied by the marketplace.
    message: cell
}

/// Owner or marketplace cancellation command allowed only before any bid.
struct (0xb820e9c2) GetgemsNftAuctionV4R1CancelAuction {
    /// Caller-selected query id copied into the NFT return transfer.
    queryId: uint64
}

/// Settlement command accepted internally after the auction end time.
struct (0xf373ace5) GetgemsNftAuctionV4R1FinishAuction {
    /// Caller-selected query id copied into payouts and NFT transfer.
    queryId: uint64
}

/// Funding-only deploy command accepted without state changes.
struct (0x9af07447) GetgemsNftAuctionV4R1DeployAuction {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// Signed Jetton wallet resolution command used during Jetton-mode deployment.
struct (0x2bee0192) GetgemsNftAuctionV4R1SetJettonWallet {
    /// Caller-selected query id parsed by the shared dispatcher.
    queryId: uint64
    /// Ed25519 signature over the remaining body containing `jettonWallet`.
    signature: bits512
    /// Resolved Jetton wallet address for this auction contract.
    jettonWallet: address
}

/// TON bid command with explicit opcode and query id.
struct (0x344ef025) GetgemsNftAuctionV4R1ProcessTonBid {
    /// Bid query id stored as `lastQueryId` when the bid is accepted.
    queryId: uint64
}

/// TON bid body whose opcode is the explicit zero accepted by the source.
struct (0x00000000) GetgemsNftAuctionV4R1ZeroOpcodeTonBid {}

/// TEP-74 Jetton transfer notification used as a Jetton bid.
struct (0x7362d09c) GetgemsNftAuctionV4R1JettonTransferNotification {
    /// Jetton transfer query id stored as `lastQueryId` when the bid is accepted.
    queryId: uint64
    /// Jetton bid amount.
    amount: coins
    /// Bidder address reported by the Jetton wallet notification.
    buyerAddress: address
    /// Raw TEP-74 forward payload tail ignored by the auction source.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-62 NFT transfer body emitted when returning or settling the NFT.
struct (0x5fcc3d14) GetgemsNftAuctionV4R1NftTransfer {
    /// Query id copied from the triggering cancel, finish, bid, or NFT-return flow.
    queryId: uint64
    /// New NFT owner, either the original owner or the winning bidder.
    newOwnerAddress: address
    /// Response destination funded by the caller that triggered the transfer.
    responseDestination: address
    /// Source always writes no custom payload ref.
    customPayload: cell?
    /// Source forwards one nanotoken to the new owner notification.
    forwardTonAmount: coins
    /// Source writes an inline empty forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 Jetton transfer body emitted for payouts, bid refunds, and Jetton bid rejections.
struct (0x0f8a7ea5) GetgemsNftAuctionV4R1JettonTransfer {
    /// Query id copied from settlement, bid, or rejection context.
    queryId: uint64
    /// Jetton amount transferred from the auction wallet.
    amount: coins
    /// Destination address for the Jetton transfer.
    destination: address
    /// Response destination used for excesses or rejection gas handling.
    responseDestination: address
    /// Source always writes no custom payload ref.
    customPayload: cell?
    /// Nanoton amount forwarded by the Jetton wallet to the destination.
    forwardTonAmount: coins
    /// Source writes an inline empty forward payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Text-comment TON refund emitted to the previous bidder when outbid in TON mode.
struct (0x00000000) GetgemsNftAuctionV4R1OutbidComment {
    /// Raw comment bytes after the zero comment opcode.
    text: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the auction.
type GetgemsNftAuctionV4R1IncomingMessage =
    | GetgemsNftAuctionV4R1OwnershipAssigned
    | GetgemsNftAuctionV4R1EmergencyProxy
    | GetgemsNftAuctionV4R1CancelAuction
    | GetgemsNftAuctionV4R1FinishAuction
    | GetgemsNftAuctionV4R1DeployAuction
    | GetgemsNftAuctionV4R1SetJettonWallet
    | GetgemsNftAuctionV4R1ProcessTonBid
    | GetgemsNftAuctionV4R1ZeroOpcodeTonBid
    | GetgemsNftAuctionV4R1JettonTransferNotification

/// External-in message body accepted by the auction.
type GetgemsNftAuctionV4R1IncomingExternalMessage = GetgemsNftAuctionV4R1FinishAuction

/// Statically known internal message bodies emitted by the auction source.
type GetgemsNftAuctionV4R1OutgoingMessage =
    | GetgemsNftAuctionV4R1NftTransfer
    | GetgemsNftAuctionV4R1JettonTransfer
    | GetgemsNftAuctionV4R1OutbidComment

/// Structured result returned by `get_auction_data_v4`.
struct GetgemsNftAuctionV4R1AuctionDataReply {
    /// True after NFT ownership assignment has activated the auction.
    activated: bool
    /// True after cancellation, force-close, or settlement.
    end: bool
    /// Current auction end Unix timestamp.
    endTime: uint32
    /// Marketplace address from immutable storage.
    marketplace: address
    /// NFT item address from immutable storage.
    nft: address
    /// NFT owner/proceeds recipient, or `addr_none` before activation.
    owner: any_address
    /// Last bid amount returned as a stack integer.
    lastBid: int
    /// Last bidder address, or `addr_none` before the first bid.
    lastMember: any_address
    /// Minimum percentage step returned as a stack integer.
    minStep: uint32
    /// Marketplace fee recipient.
    marketFeeAddress: address
    /// Marketplace fee numerator.
    mpFeeFactor: uint32
    /// Marketplace fee denominator.
    mpFeeBase: uint32
    /// Royalty fee recipient.
    royaltyAddress: address
    /// Royalty fee numerator.
    royaltyFeeFactor: uint32
    /// Royalty fee denominator.
    royaltyFeeBase: uint32
    /// Buy-now bid cap returned as a stack integer.
    maxBid: int
    /// Current minimum bid; source recalculates it after a nonzero last bid.
    minBid: int
    /// Auction creation Unix timestamp.
    createdAt: uint32
    /// Unix timestamp of the last accepted bid.
    lastBidAt: uint32
    /// True only when cancellation returned the NFT without sale.
    isCanceled: bool
    /// Anti-sniping extension step in seconds.
    stepTime: uint32
    /// Last accepted bid query id.
    lastQueryId: uint64
    /// Auction Jetton wallet, or `addr_none` in TON mode.
    jettonWallet: any_address
    /// Jetton master address, or `addr_none` in TON mode.
    jettonMaster: any_address
    /// True when fee math or Jetton setup makes auction settlement unsafe.
    isBrokenState: bool
    /// Zero or the stored 256-bit public key used during Jetton wallet resolution.
    publicKey: int
}

/// Source-proven exit-code catalog for auction command validation.
enum GetgemsNftAuctionV4R1Errors {
    /// Signature over the Jetton wallet update payload is invalid.
    InvalidSignature = 35
    /// Resolved Jetton wallet is not in workchain 0.
    InvalidJettonWalletWorkchain = 36
    /// Sender is not authorized for owner, marketplace, bidder, or expected Jetton-wallet flows.
    UnauthorizedAddress = 403
    /// Jetton transfer notification sender is not in workchain 0.
    InvalidJettonNotificationWorkchain = 452
    /// Bid is below the minimum accepted amount, or external settlement balance is too low.
    LowBid = 1000
    /// NFT ownership assignment attempted after the auction already has an owner.
    AlreadyInitiated = 1001
    /// NFT-originated activation body is not `ownership_assigned`.
    InvalidOpExpectOwnershipAssigned = 1002
    /// Marketplace emergency proxy is not allowed while a normal active auction can still proceed.
    EmergencyProxyNotAllowed = 1004
    /// Auction was already cancelled, force-closed, or settled.
    AlreadyExecuted = 1005
    /// Jetton wallet update attempted after the one-time public key was consumed or absent.
    AlreadyActivated = 1006
    /// Attached TON value is below the command-specific processing budget.
    NotEnoughTons = 1008
    /// Cancellation or Jetton wallet update is blocked after a bid exists.
    AlreadyHasBid = 1009
    /// Finish attempted before end time.
    AuctionInProgress = 1010
    /// Marketplace emergency proxy tried to use send mode bit 32.
    BadEmergencySendMode = 1012
    /// Marketplace emergency proxy was attempted too close to the end time or last bid time.
    LastBidTooClose = 1013
    /// Auction duration is more than 20 days from the current time.
    AuctionDurationTooLong = 1014
    /// Bid, cancel, or finish attempted before NFT ownership assignment activated the auction.
    AuctionHasNotBeenActivatedYet = 1015
    /// Fee math or Jetton setup marks the auction as broken.
    AuctionIsInABrokenState = 1016
    /// TON bid sent to Jetton auction, Jetton bid sent to TON auction, or wrong Jetton wallet sent notification.
    WrongCurrency = 1017
    /// Incoming internal or external opcode is not recognized.
    UnknownOperation = 65535
}

/// Return the complete auction state exposed by source `get_auction_data_v4`.
get fun get_auction_data_v4(): GetgemsNftAuctionV4R1AuctionDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw GetgemsNftAuctionV4R1Errors.InvalidSignature;
    assert (true) throw GetgemsNftAuctionV4R1Errors.InvalidJettonWalletWorkchain;
    assert (true) throw GetgemsNftAuctionV4R1Errors.UnauthorizedAddress;
    assert (true) throw GetgemsNftAuctionV4R1Errors.InvalidJettonNotificationWorkchain;
    assert (true) throw GetgemsNftAuctionV4R1Errors.LowBid;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AlreadyInitiated;
    assert (true) throw GetgemsNftAuctionV4R1Errors.InvalidOpExpectOwnershipAssigned;
    assert (true) throw GetgemsNftAuctionV4R1Errors.EmergencyProxyNotAllowed;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AlreadyExecuted;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AlreadyActivated;
    assert (true) throw GetgemsNftAuctionV4R1Errors.NotEnoughTons;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AlreadyHasBid;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AuctionInProgress;
    assert (true) throw GetgemsNftAuctionV4R1Errors.BadEmergencySendMode;
    assert (true) throw GetgemsNftAuctionV4R1Errors.LastBidTooClose;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AuctionDurationTooLong;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AuctionHasNotBeenActivatedYet;
    assert (true) throw GetgemsNftAuctionV4R1Errors.AuctionIsInABrokenState;
    assert (true) throw GetgemsNftAuctionV4R1Errors.WrongCurrency;
    assert (true) throw GetgemsNftAuctionV4R1Errors.UnknownOperation;
    return {
        activated: false,
        end: false,
        endTime: 0,
        marketplace: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        nft: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000") as any_address,
        lastBid: 0,
        lastMember: address("0:0000000000000000000000000000000000000000000000000000000000000000") as any_address,
        minStep: 0,
        marketFeeAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        mpFeeFactor: 0,
        mpFeeBase: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        royaltyFeeFactor: 0,
        royaltyFeeBase: 0,
        maxBid: 0,
        minBid: 0,
        createdAt: 0,
        lastBidAt: 0,
        isCanceled: false,
        stepTime: 0,
        lastQueryId: 0,
        jettonWallet: address("0:0000000000000000000000000000000000000000000000000000000000000000") as any_address,
        jettonMaster: address("0:0000000000000000000000000000000000000000000000000000000000000000") as any_address,
        isBrokenState: false,
        publicKey: 0,
    };
}
