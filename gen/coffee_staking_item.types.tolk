// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeStakingItem {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeStakingItemIncomingMessage
}

// TL-B helper types referenced by messages.
struct StakingAssetData {
    wallet: address
    amount: coins
}

struct StakingPositionData {
    userPoints: coins
    additionalPoints: coins
    startTimestamp: uint64
    endTimestamp: uint64
    periodId: uint32
}

type CoffeeStakingAssetData = StakingAssetData

type CoffeeStakingPositionData = StakingPositionData

// TL-B message bodies.
struct (0xbe5a7595) CoffeeStakingInit {
    queryId: uint64
    owner: address
    jettonData: Cell<CoffeeStakingAssetData>
    positionData: Cell<CoffeeStakingPositionData>
    periods: cell
}

// Message unions used by Acton ABI.
type CoffeeStakingItemIncomingMessage = CoffeeStakingInit

struct GetStoredDataReply {
    initialized: bool
    nftId: uint64
    master: address
    owner: address
    asset: cell
    info: cell
    periods: cell
}

enum Errors {
    NotInitialized = 99
    AlreadyInitialized = 100
    TooEarlyToUnlock = 500
    TooLateToExtend = 501
    ZeroPoints = 502
}

get fun get_stored_data(): GetStoredDataReply {
    return {
        initialized: false,
        nftId: 0,
        master: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        asset: createEmptyCell(),
        info: createEmptyCell(),
        periods: createEmptyCell(),
    };
}
