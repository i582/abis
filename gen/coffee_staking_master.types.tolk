// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeStakingMaster {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeStakingMasterIncomingMessage
    outgoingMessages: CoffeeStakingMasterOutgoingMessage
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

struct StakingForwardData {
    gas: coins
    payload: cell
}

type CoffeeStakingAssetData = StakingAssetData

type CoffeeStakingPositionData = StakingPositionData

type CoffeeStakingForwardData = StakingForwardData

// TL-B message bodies.
struct (0xbe5a7595) CoffeeStakingInit {
    queryId: uint64
    owner: address
    jettonData: Cell<CoffeeStakingAssetData>
    positionData: Cell<CoffeeStakingPositionData>
    periods: cell
}

struct (0xf9471134) CoffeeStakingDeposit {
    queryId: uint64
    sender: address
    jettonAmount: coins
    fromUser: address
    periodId: uint32
}

struct (0x0a9577f0) CoffeeStakingUpdateRewards {
    queryId: uint64
    jettonWallet: address
    jettonAmount: coins
    duration: uint64
}

struct (0xb30c7310) CoffeeStakingClaimRewards {
    queryId: uint64
    jettonWallet: address
    jettonAmount: coins
    receiver: address
    payload: Cell<CoffeeStakingForwardData>?
}

struct (0x0a9577f0) CoffeeStakingRewardsUpdated {
    queryId: uint64
    jettonWallet: address
    duration: uint64
    finishAt: uint64
    rewardsRate: coins
}

struct (0xb30c7310) CoffeeStakingRewardsClaimed {
    queryId: uint64
    jettonWallet: address
    amount: coins
    receiver: address
}

// Message unions used by Acton ABI.
type CoffeeStakingMasterIncomingMessage =
    | CoffeeStakingInit
    | CoffeeStakingDeposit
    | CoffeeStakingUpdateRewards
    | CoffeeStakingClaimRewards

type CoffeeStakingMasterOutgoingMessage =
    | CoffeeStakingInit
    | CoffeeStakingRewardsUpdated
    | CoffeeStakingRewardsClaimed

struct GetStoredDataReply {
    initialized: bool
    owner: address
    distributor: address
    vault: address
    state: cell
    rewards: cell
    jettons: cell
    periods: cell
}

enum Errors {
    UnknownJettonWallet = 81
    NotInitialized = 99
    AlreadyInitialized = 100
    MismatchingDuration = 110
    ZeroRewardRate = 111
    TokenNotDistributed = 200
}

get fun get_stored_data(): GetStoredDataReply {
    return {
        initialized: false,
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        distributor: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        vault: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        state: createEmptyCell(),
        rewards: createEmptyCell(),
        jettons: createEmptyCell(),
        periods: createEmptyCell(),
    };
}
