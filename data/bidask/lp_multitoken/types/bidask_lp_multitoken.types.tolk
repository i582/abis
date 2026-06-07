/// Bidask DLMM LP multitoken wallet for one user/range position.
contract BidaskLpMultitoken {
    author: "Bidask"
    version: "1.0"
    description: "Curated Bidask DLMM LP multitoken interface with packed four-bin token dictionaries"
    storage: BidaskLpMultitokenStorage
    incomingMessages: BidaskLpMultitokenIncomingMessage
    outgoingMessages: BidaskLpMultitokenOutgoingMessage
}

/// Persistent LP multitoken wallet state stored in the account data cell.
struct BidaskLpMultitokenStorage {
    /// Range contract that owns the position bins for this LP multitoken wallet.
    rangeAddress: address
    /// User address that owns this LP multitoken wallet.
    userAddress: address
    /// Number of initialized LP token bins tracked by this wallet.
    binsNumber: uint32
    /// Optional direct Hashmap root cell, not a serialized `Cell<map<...>>`; keys are signed 32-bit group indexes.
    tokenChunks: cell?
}

/// Raw dictionary value packing four consecutive `uint244` LP balances as `Dictionary.Values.BitString(976)`.
type BidaskLpMultitokenTokenChunk = bits976

/// Range-originated mint body that deploys or updates this LP multitoken wallet.
struct (0x250ad226) BidaskMultitokenMint {
    /// Query id propagated from the liquidity provision flow.
    queryId: uint64
    /// Optional code cell; observed Range mint bodies carry the current exotic LP multitoken code cell here.
    code: cell?
    /// Optional second reference named `ref_2` in TL-B; null in the saved Range mint transactions.
    ref2: cell?
    /// LP token chunks to add, keyed by signed 32-bit group index, with raw `bits976` values.
    lpTokens: map<int32, BidaskLpMultitokenTokenChunk>
    /// Number of individual LP bins represented by the mint body.
    binsNumber: uint32
    /// Optional payload forwarded after mint notification.
    forwardPayload: cell?
}

/// User-originated partial burn request.
struct (0x73403c43) BidaskBurn {
    /// Query id propagated to the Range burn callback.
    queryId: uint64
    /// LP token chunks to burn, keyed by signed 32-bit group index, with raw `bits976` values.
    tokensToBurn: map<int32, BidaskLpMultitokenTokenChunk>
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// User-originated request to burn all LP tokens held by this wallet.
struct (0xebd6ec83) BidaskBurnAll {
    /// Query id propagated to the Range burn callback.
    queryId: uint64
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// LP multitoken to Range callback emitted after a burn request is processed.
struct (0x16e09400) BidaskInternalBurn {
    /// Query id copied from the user burn request.
    queryId: uint64
    /// User address that owns the LP tokens being burned.
    ownerAddress: address
    /// Amount of token X already accounted for in the burn flow.
    amountX: coins
    /// Amount of token Y already accounted for in the burn flow.
    amountY: coins
    /// First individual bin covered by the burn operation.
    firstBin: int32
    /// LP token chunks burned, keyed by signed 32-bit group index, with raw `bits976` values.
    tokensToBurn: map<int32, BidaskLpMultitokenTokenChunk>
    /// Optional payload forwarded with withdrawn tokens.
    forwardPayload: cell?
}

/// LP multitoken notification emitted after liquidity is added.
struct (0x0dc8bb28) BidaskLiquidityAddedNotify {
    /// Query id copied from the mint/provide flow.
    queryId: uint64
    /// Optional payload forwarded to the user after minting.
    forwardPayload: cell?
}

/// Internal message bodies accepted by the LP multitoken wallet.
type BidaskLpMultitokenIncomingMessage =
    | BidaskMultitokenMint
    | BidaskBurn
    | BidaskBurnAll

/// Internal message bodies emitted by the LP multitoken wallet.
type BidaskLpMultitokenOutgoingMessage =
    | BidaskInternalBurn
    | BidaskLiquidityAddedNotify

/// Structured result returned by `get_nft_data`.
struct BidaskLpMultitokenNftDataReply {
    /// NFT initialization flag; live wallets return `-1`.
    isInitialized: int
    /// Numeric LP wallet address hash/index returned as a stack integer.
    itemAddressHash: int
    /// Range contract address returned as the NFT collection address.
    rangeAddress: address
    /// Current LP wallet owner address.
    userAddress: address
    /// Off-chain NFT content cell.
    content: cell
}

/// Returns the optional direct LP-token Hashmap root cell.
get fun get_tokens(): cell? {
    throw 0;
}

/// Returns `addr_none`; Bidask LP multitokens do not expose a mutable authority.
get fun get_authority_address(): any_address {
    throw 0;
}

/// Returns NFT-style LP multitoken metadata.
get fun get_nft_data(): BidaskLpMultitokenNftDataReply {
    throw 0;
}

/// Returns zero; the contract behaves like a non-revoked NFT/SBT item.
get fun get_revoked_time(): int {
    throw 0;
}

/// Returns the LP token balance for one individual bin.
get fun get_bin(bin: int): int {
    throw 0;
}

/// Returns the number of initialized LP token bins.
get fun get_bins_number(): int {
    throw 0;
}

/// Returns the raw full storage cell.
get fun get_storage(): cell {
    throw 0;
}
