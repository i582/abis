/// Getgems fixed-price NFT sale V1 interface reconstructed from upstream FunC source.
contract GetgemsNftFixpriceSaleV1 {
    author: "Getgems"
    version: "1"
    description: "Curated Getgems fixed-price NFT sale V1 interface"
    storage: GetgemsNftFixpriceSaleV1Storage
    storageAtDeployment: GetgemsNftFixpriceSaleV1DeploymentStorage
    incomingMessages: GetgemsNftFixpriceSaleV1IncomingMessage
    outgoingMessages: GetgemsNftFixpriceSaleV1OutgoingMessage
    thrownErrors: GetgemsNftFixpriceSaleV1Errors
}

/// Deployment storage before the NFT ownership callback records the previous owner.
struct GetgemsNftFixpriceSaleV1DeploymentStorage {
    /// Marketplace address allowed to top up the just-deployed sale.
    marketplaceAddress: address
    /// NFT item address that must send the initialization callback.
    nftAddress: address
    /// Null before `ownership_assigned`; later set to the previous NFT owner.
    nftOwnerAddress: address?
    /// Required sale price in nanotons, encoded as TL-B `Coins`.
    fullPrice: coins
    /// Referenced fee and royalty configuration cell.
    fees: Cell<GetgemsNftFixpriceSaleV1Fees>
}

/// Runtime storage after the NFT item has assigned ownership to this sale.
struct GetgemsNftFixpriceSaleV1Storage {
    /// Marketplace address stored in the root data cell.
    marketplaceAddress: address
    /// NFT item address stored in the root data cell.
    nftAddress: address
    /// Previous NFT owner that receives proceeds or the NFT on cancellation.
    nftOwnerAddress: address
    /// Required sale price in nanotons, encoded as TL-B `Coins`.
    fullPrice: coins
    /// Referenced fee and royalty configuration cell.
    fees: Cell<GetgemsNftFixpriceSaleV1Fees>
}

/// Referenced fee cell stored from the deployment config.
struct GetgemsNftFixpriceSaleV1Fees {
    /// Marketplace fee amount in nanotons.
    marketplaceFee: coins
    /// Address receiving the marketplace fee payout.
    marketplaceFeeAddress: address
    /// Royalty recipient address.
    royaltyAddress: address
    /// Royalty amount in nanotons.
    royaltyAmount: coins
}

/// NFT ownership callback accepted from the stored NFT address during initialization.
struct (0x05138d91) GetgemsNftFixpriceSaleV1OwnershipAssigned {
    /// Query id sent by the NFT item callback.
    queryId: uint64
    /// Previous NFT owner recorded as the sale owner.
    previousOwnerAddress: address
    /// Unparsed standard ownership-assigned tail; the sale source ignores it.
    forwardPayload: RemainingBitsAndRefs
}

/// Initialized sale command that only accepts attached nanotons.
struct (0x00000001) GetgemsNftFixpriceSaleV1AcceptCoins {
    /// Caller-selected id parsed and then ignored by this command.
    queryId: uint64
}

/// Initialized sale command that buys the NFT for the message sender.
struct (0x00000002) GetgemsNftFixpriceSaleV1Buy {
    /// Query id copied into the outgoing NFT transfer.
    queryId: uint64
}

/// Initialized sale command that returns the NFT to the recorded owner.
struct (0x00000003) GetgemsNftFixpriceSaleV1Cancel {
    /// Query id copied into the outgoing NFT transfer.
    queryId: uint64
}

/// NFT transfer body emitted to the NFT item on buy and cancel flows.
struct (0x5fcc3d14) GetgemsNftFixpriceSaleV1NftTransfer {
    /// Query id copied from the buy or cancel command, or zero for empty-body buy.
    queryId: uint64
    /// Buyer address on sale, or recorded owner address on cancellation.
    newOwnerAddress: address
    /// Response address, equal to the new owner in this source.
    responseAddress: address
    /// Optional custom payload; V1 always sends `none`.
    customPayload: cell?
    /// Forwarded nanotons to the new owner; V1 always sends zero.
    forwardTonAmount: coins
    /// Raw TEP-62 forward payload tail; V1 sends an empty inline tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the fixed-price sale.
type GetgemsNftFixpriceSaleV1IncomingMessage =
    | GetgemsNftFixpriceSaleV1OwnershipAssigned
    | GetgemsNftFixpriceSaleV1AcceptCoins
    | GetgemsNftFixpriceSaleV1Buy
    | GetgemsNftFixpriceSaleV1Cancel

/// Internal message bodies emitted by the fixed-price sale.
type GetgemsNftFixpriceSaleV1OutgoingMessage =
    | GetgemsNftFixpriceSaleV1NftTransfer

/// Structured result returned by `get_sale_data`.
struct GetgemsNftFixpriceSaleV1SaleDataReply {
    /// Marketplace address stored in sale data.
    marketplaceAddress: address
    /// NFT item address stored in sale data.
    nftAddress: address
    /// NFT owner address, or `addr_none` before initialization.
    nftOwnerAddress: any_address
    /// Full sale price returned as a TVM stack integer.
    fullPrice: int
    /// Marketplace fee recipient address.
    marketplaceFeeAddress: address
    /// Marketplace fee amount returned as a TVM stack integer.
    marketplaceFee: int
    /// Royalty recipient address.
    royaltyAddress: address
    /// Royalty amount returned as a TVM stack integer.
    royaltyAmount: int
}

/// Exit-code catalog proven by the V1 FunC throw sites.
enum GetgemsNftFixpriceSaleV1Errors {
    /// Buy value is below `full_price + 1 TON`.
    NotEnoughTonsForSale = 450
    /// Uninitialized sale was not called by the stored NFT address.
    UnauthorizedInitiation = 500
    /// Initialization body opcode is not `ownership_assigned`.
    InvalidOpExpectedOwnershipAssigned = 501
    /// Cancel value is below `1 TON`.
    NotEnoughTonsForCancellation = 457
    /// Initialized sale received an unsupported opcode.
    UnknownOperation = 65535
}

/// Return marketplace, NFT, owner, price, fee recipient, fee, royalty recipient, and royalty amount.
get fun get_sale_data(): GetgemsNftFixpriceSaleV1SaleDataReply {
    throw 0;
}
