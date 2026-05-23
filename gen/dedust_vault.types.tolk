// Generated from XML ABI schemas.
// Source schema: schemas/dedust.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DedustVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dedust.xml"
    incomingMessages: DedustVaultIncomingMessage
    outgoingMessages: DedustVaultOutgoingMessage
}

struct DedustDepositLiquidityParams {
    minLpAmount: coins
    asset0TargetBalance: coins
    asset1TargetBalance: coins
}

// TL-B helper types referenced by messages.
struct Step {
    poolAddr: address
    params: DedustSwapStepParams
}

struct SwapParams {
    deadline: uint32
    recipientAddr: address
    referralAddr: address
    fulfillPayload: cell?
    rejectPayload: cell?
}

struct PoolParams {
    poolType: cell
    asset0: cell
    asset1: cell
}

struct StepParams {
    kindOut: bool
    limit: coins
    next: Cell<DedustSwapStep>?
}

struct (0b0) Volatile {}

struct (0b1) Stable {}

struct (0b0000) Native {}

struct (0b0001) Jetton {
    workchainId: int8
    address: bits256
}

struct (0b0010) ExtraCurrency {
    currencyId: int32
}

type DedustSwapStep = Step

type DedustSwapParams = SwapParams

type DedustPoolParams = PoolParams

type DedustSwapStepParams = StepParams

type DedustPoolType =
    | Volatile
    | Stable

type DedustAsset =
    | Native
    | Jetton
    | ExtraCurrency

// TL-B message bodies.
struct (0xea06185d) DedustSwap {
    queryId: uint64
    amount: coins
    step: DedustSwapStep
    swapParams: Cell<DedustSwapParams>
}

struct (0xd55e4686) DedustDepositLiquidity {
    queryId: uint64
    amount: coins
    poolParams: DedustPoolParams
    params: Cell<DedustDepositLiquidityParams>
    fulfillPayload: cell?
    rejectPayload: cell?
}

struct (0xad4eb6f5) DedustPayoutFromPool {
    queryId: uint64
    proof: cell
    amount: coins
    recipientAddr: address
    payload: cell?
}

struct (0x61ee542d) DedustSwapExternal {
    queryId: uint64
    proof: cell
    amount: coins
    senderAddr: address
    current: DedustSwapStepParams
    swapParams: Cell<DedustSwapParams>
}

struct (0x474f86cf) DedustPayout {
    queryId: uint64
    payload: cell?
}

// Message unions used by Acton ABI.
type DedustVaultIncomingMessage =
    | DedustSwap
    | DedustDepositLiquidity
    | DedustPayoutFromPool

type DedustVaultOutgoingMessage =
    | DedustSwapExternal
    | DedustPayout

get fun get_asset(): slice {
    return createEmptyCell().beginParse();
}
