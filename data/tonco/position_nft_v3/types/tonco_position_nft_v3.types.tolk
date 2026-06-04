/// TONCO v1.6 Position NFT item interface for concentrated-liquidity positions.
contract ToncoPositionNftV3 {
    author: "Algebra / TONCO"
    version: "1.6"
    description: "Curated TONCO Position NFT V3 ABI for NFT ownership, position initialization/burn commands, and pool burn callbacks"
    storage: ToncoPositionNftV3Storage
    incomingMessages: ToncoPositionNftV3IncomingMessage
    outgoingMessages: ToncoPositionNftV3OutgoingMessage
}

/// Runtime Position NFT storage loaded from the root data cell.
struct ToncoPositionNftV3Storage {
    /// NFT item index inside the pool NFT collection.
    index: uint64
    /// Pool collection address that owns this Position NFT series.
    poolAddress: address
    /// Current user/position owner tracked by the pool logic.
    userAddress: address
    /// NFT item content cell returned by `get_nft_data`.
    content: cell
    /// Current position liquidity.
    liquidity: uint128
    /// Lower tick boundary for this concentrated-liquidity position.
    tickLower: int24
    /// Upper tick boundary for this concentrated-liquidity position.
    tickUpper: int24
    /// Referenced fee-growth checkpoint values.
    feeGrowthInside: Cell<ToncoPositionNftV3FeeGrowth>
}

/// Referenced position fee-growth checkpoints.
struct ToncoPositionNftV3FeeGrowth {
    /// Last recorded token0 fee growth inside the position range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Last recorded token1 fee growth inside the position range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
}

/// Referenced old-fee and position context cell in the pool-originated position-init message.
struct ToncoPositionNftV3PositionInitOldFeeCell {
    /// Last token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Last token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
    /// NFT item index assigned by the pool.
    nftIndex: uint64
    /// Token0 amount used for the minted position.
    jetton0Amount: coins
    /// Token1 amount used for the minted position.
    jetton1Amount: coins
    /// Pool tick at initialization time.
    tick: int24
}

/// Pool-originated message that initializes the Position NFT state after minting.
struct (0xd5ecca2a) ToncoPositionNftV3PositionInit {
    /// Query id copied from the pool mint flow.
    queryId: uint64
    /// User address that owns the initialized position.
    userAddress: address
    /// Liquidity minted into the position.
    liquidity: uint128
    /// Lower tick boundary for the position.
    tickLower: int24
    /// Upper tick boundary for the position.
    tickUpper: int24
    /// Pool operation sequence number embedded before the fee context ref.
    poolSeqno: uint64
    /// Referenced old fee-growth and mint context values.
    oldFeeCell: Cell<ToncoPositionNftV3PositionInitOldFeeCell>
}

/// Referenced old-fee cell in the user-originated position-burn message.
struct ToncoPositionNftV3PositionBurnOldFeeCell {
    /// Last token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Last token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
}

/// User-originated message that requests burning part of a position.
struct (0x46ca335a) ToncoPositionNftV3PositionBurn {
    /// Query id propagated to the pool burn callback.
    queryId: uint64
    /// Current NFT owner requesting the burn.
    nftOwner: address
    /// Liquidity amount to burn.
    liquidity2Burn: uint128
    /// Lower tick boundary of the position.
    tickLower: int24
    /// Upper tick boundary of the position.
    tickUpper: int24
    /// Referenced old fee-growth checkpoints supplied to the pool.
    oldFeeCell: Cell<ToncoPositionNftV3PositionBurnOldFeeCell>
}

/// Standard NFT transfer message accepted by Position NFT items.
struct (0x5fcc3d14) ToncoPositionNftV3Transfer {
    /// Query id for the NFT transfer.
    queryId: uint64
    /// New NFT owner address.
    newOwnerAddress: address
    /// Optional response destination; `addr_none` is encoded as null.
    responseDestination: address?
    /// Optional custom payload reference.
    customPayload: cell?
    /// TON amount forwarded to the new owner.
    forwardTonAmount: coins
    /// Remaining forward payload bits/refs copied into the ownership callback.
    forwardPayload: RemainingBitsAndRefs
}

/// NFT ownership-assigned notification emitted to the new owner.
struct (0x05138d91) ToncoPositionNftV3OwnershipAssigned {
    /// Query id copied from the transfer.
    queryId: uint64
    /// Previous owner address.
    previousOwnerAddress: address
    /// Forward payload copied from the transfer body.
    forwardPayload: RemainingBitsAndRefs
}

/// Static data report emitted for standard NFT static-data requests.
struct (0x8b771735) ToncoPositionNftV3ReportStaticData {
    /// Query id copied from the static-data request.
    queryId: uint64
    /// NFT item index encoded as a 256-bit integer by the standard message.
    itemIndex: uint256
    /// Collection address, which is the TONCO Pool address for Position NFTs.
    collectionAddress: address
}

/// Standard excesses message emitted after transfer handling.
struct (0xd53276db) ToncoPositionNftV3Excesses {
    /// Query id copied from the triggering transfer.
    queryId: uint64
}

/// Referenced old fee-growth cell forwarded to the Pool burn callback.
struct Poolv3BurnOldFeeCell {
    /// Last token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0LastX128: uint256
    /// Last token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1LastX128: uint256
}

/// Referenced current fee-growth cell forwarded to the Pool burn callback.
struct Poolv3BurnNewFeeCell {
    /// Current token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0CurrentX128: uint256
    /// Current token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1CurrentX128: uint256
}

/// PositionNFT-to-Pool callback that executes the requested position burn.
struct (0xd73ac09d) Poolv3Burn {
    /// Query id copied from the position burn request.
    queryId: uint64
    /// Address that receives withdrawn token amounts.
    recipient: address
    /// NFT item index being burned.
    burnedIndex: uint64
    /// Position liquidity before the burn.
    liquidity: uint128
    /// Lower tick boundary of the position.
    tickLower: int24
    /// Upper tick boundary of the position.
    tickUpper: int24
    /// Liquidity amount requested to burn.
    liquidity2Burn: uint128
    /// Referenced previous fee-growth checkpoints.
    oldFeeCell: Cell<Poolv3BurnOldFeeCell>
    /// Referenced current fee-growth checkpoints.
    newFeeCell: Cell<Poolv3BurnNewFeeCell>
}

/// Internal message bodies accepted by TONCO Position NFT V3.
type ToncoPositionNftV3IncomingMessage =
    | ToncoPositionNftV3PositionInit
    | ToncoPositionNftV3PositionBurn
    | ToncoPositionNftV3Transfer

/// Internal message bodies emitted by TONCO Position NFT V3.
type ToncoPositionNftV3OutgoingMessage =
    | Poolv3Burn
    | ToncoPositionNftV3OwnershipAssigned
    | ToncoPositionNftV3ReportStaticData
    | ToncoPositionNftV3Excesses

/// Structured return value of `getPositionInfo`.
struct ToncoPositionNftV3InfoReply {
    /// Current position liquidity.
    liquidity: int
    /// Lower tick boundary.
    tickLower: int
    /// Upper tick boundary.
    tickUpper: int
    /// Last token0 fee growth inside the range, Q128-scaled.
    feeGrowthInside0LastX128: int
    /// Last token1 fee growth inside the range, Q128-scaled.
    feeGrowthInside1LastX128: int
}

/// Structured standard NFT data returned by `get_nft_data`.
struct ToncoPositionNftV3DataReply {
    /// True when the NFT item is initialized.
    isInitialized: bool
    /// NFT item index.
    itemIndex: int
    /// Collection address, equal to the TONCO Pool address.
    collectionAddress: address
    /// Optional current NFT owner address.
    ownerAddress: address?
    /// Optional NFT item content cell.
    content: cell?
}

/// Return the pool collection address for this Position NFT.
get fun getPoolAddress(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the user/position owner tracked by the pool logic.
get fun getUserAddress(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return position liquidity, ticks, and fee-growth checkpoints.
get fun getPositionInfo(): ToncoPositionNftV3InfoReply {
    return {
        liquidity: 0,
        tickLower: 0,
        tickUpper: 0,
        feeGrowthInside0LastX128: 0,
        feeGrowthInside1LastX128: 0,
    };
}

/// Return standard NFT item data for the Position NFT.
get fun get_nft_data(): ToncoPositionNftV3DataReply {
    return {
        isInitialized: false,
        itemIndex: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: null,
        content: null,
    };
}
