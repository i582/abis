// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeStakingVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeStakingVaultIncomingMessage
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
type CoffeeStakingVaultIncomingMessage = CoffeeStakingInit

struct GetStoredDataReply {
    initialized: bool
    owner: address
    jettons: cell
    periods: cell
    masterCode: cell
    itemCode: cell
}

enum Errors {
    InvalidAmount = 80
    InvalidDictionaryValue = 82
    NotInitialized = 99
    AlreadyInitialized = 100
    UnauthorizedAccess = 403
    WrongPeriod = 503
    UnexpectedForwardOpcode = 504
}

get fun get_stored_data(): GetStoredDataReply {
    return {
        initialized: false,
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettons: createEmptyCell(),
        periods: createEmptyCell(),
        masterCode: createEmptyCell(),
        itemCode: createEmptyCell(),
    };
}

get fun get_master_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
