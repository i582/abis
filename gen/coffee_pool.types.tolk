// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeePool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeePoolIncomingMessage
    outgoingMessages: CoffeePoolOutgoingMessage
}

// TL-B helper types referenced by messages.
struct SwapStepInternalParams {
    previousAmount: coins
    previousAssetHint: cell?
    minOutputAmount: coins
    next: Cell<CoffeeSwapStepParams>?
}

struct SwapParams {
    deadline: uint32
    recipient: address
    referral: address
    notificationData: Cell<CoffeeNotificationData>?
}

struct DepositLiquidityParamsTrimmed {
    recipient: address
    useRecipientOnFailure: int1
    referral: address
    deadline: uint32
    condition: cell
    extraSettings: cell?
    notificationData: Cell<CoffeeNotificationData>?
}

struct (0b00) Native {}

struct (0b01) Jetton {
    chain: uint8
    hash: uint256
}

struct (0b10) Extra {
    id: uint32
}

struct ContractUpdate {
    code: cell?
    data: cell?
}

struct NotificationData {
    onSuccess: Cell<CoffeeNotificationDataSingle>?
    onFailure: Cell<CoffeeNotificationDataSingle>?
}

struct NotificationDataSingle {
    receiver: address
    fwdGas: coins
    payload: cell
}

struct PoolReserves {
    inputReserve: coins
    outputReserve: coins
}

struct SwapStepParams {
    poolAddressHash: uint256
    minOutputAmount: coins
    next: Cell<CoffeeSwapStepParams>?
}

struct (0b00) None {}

struct (0b01) LpQuantity {
    minLpAmount: coins
}

struct (0b10) ReservesRatio {
    denominator: uint16
    minNominator: uint16
    maxNominator: uint16
}

struct (0b11) Complex {
    minLpAmount: coins
    denominator: uint16
    minNominator: uint16
    maxNominator: uint16
}

type CoffeeSwapStepInternalParams = SwapStepInternalParams

type CoffeeSwapParams = SwapParams

type CoffeeDepositLiquidityParamsTrimmed = DepositLiquidityParamsTrimmed

type CoffeeAsset =
    | Native
    | Jetton
    | Extra

type CoffeeContractUpdate = ContractUpdate

type CoffeeNotificationData = NotificationData

type CoffeeNotificationDataSingle = NotificationDataSingle

type CoffeePoolReserves = PoolReserves

type CoffeeSwapStepParams = SwapStepParams

type CoffeeDepositLiquidityCondition =
    | None
    | LpQuantity
    | ReservesRatio
    | Complex

// TL-B message bodies.
struct (0xc0ffee20) CoffeeSwapInternal {
    queryId: uint64
    field2: CoffeeSwapStepInternalParams
    params: Cell<CoffeeSwapParams>
    proof: cell
}

struct (0xc0ffee29) CoffeeDepositLiquidityInternal {
    queryId: uint64
    amount1: coins
    amount2: coins
    txInitiator: address
    params: Cell<CoffeeDepositLiquidityParamsTrimmed>
    proof: cell
}

struct (0xc0ffee2d) CoffeeWithdrawInternal {
    queryId: uint64
    asset: cell
    amount: coins
    receiver: address
}

struct (0xc0ffee2e) CoffeeUpdateContractInternal {
    queryId: uint64
    excessesReceiver: address
    field3: CoffeeContractUpdate
}

struct (0xc0ffee26) CoffeeCreatePoolInternal {
    queryId: uint64
    amount1: coins
    amount2: coins
    txInitiator: address
    recipient: address
    useRecipientOnFailure: int1
    extraSettings: cell?
    notificationData: Cell<CoffeeNotificationData>?
}

struct (0xc0ffee22) CoffeeDeploy {
    code: cell
    data: cell
    action: cell?
}

struct (0xc0ffee21) CoffeePayoutInternal {
    queryId: uint64
    recipient: address
    amount: coins
    notificationData: Cell<CoffeeNotificationDataSingle>?
    proof: cell?
}

struct (0xc0ffee36) CoffeeNotification {
    queryId: uint64
    body: cell
}

struct (0xc0ffee30) CoffeeSwapSucceeded {
    queryId: uint64
    input: cell
    inputAmount: coins
    outputAmount: coins
    reserves: CoffeePoolReserves
    protocolFee: coins
}

struct (0xc0ffee31) CoffeeSwapFailed {
    queryId: uint64
    input: cell
    inputAmount: coins
    reserves: Cell<CoffeePoolReserves>?
}

struct (0xc0ffee33) CoffeeDepositLiquiditySucceeded {
    queryId: uint64
    amount1: coins
    amount2: coins
    lpAmount: coins
    totalSupply: CoffeePoolReserves
    reserves: CoffeePoolReserves
}

struct (0xc0ffee34) CoffeeDepositLiquidityFailed {
    queryId: uint64
    amount1: coins
    amount2: coins
    minLpAmount: coins
    totalSupply: coins
    reserves: CoffeePoolReserves
}

struct (0xc0ffee35) CoffeeWithdrawLiquiditySucceeded {
    queryId: uint64
    amount1: coins
    amount2: coins
    lpAmount: coins
    totalSupply: CoffeePoolReserves
    reserves: CoffeePoolReserves
}

// Message unions used by Acton ABI.
type CoffeePoolIncomingMessage =
    | CoffeeSwapInternal
    | CoffeeDepositLiquidityInternal
    | CoffeeWithdrawInternal
    | CoffeeUpdateContractInternal
    | CoffeeCreatePoolInternal
    | CoffeeDeploy

type CoffeePoolOutgoingMessage =
    | CoffeePayoutInternal
    | CoffeeSwapInternal
    | CoffeeNotification
    | CoffeeSwapSucceeded
    | CoffeeSwapFailed
    | CoffeeDepositLiquiditySucceeded
    | CoffeeDepositLiquidityFailed
    | CoffeeWithdrawLiquiditySucceeded

struct GetPoolDataReply {
    poolVersion: int
    asset1: slice
    asset2: slice
    amm: int
    ammSettings: cell?
    active: bool
    reserve1: int
    reserve2: int
    totalSupply: int
    protocolFee: int
    lpFee: int
}

struct EstimateSwapAmountReply {
    inputAmount: int
    outputAmount: int
}

struct EstimateLiquidityWithdrawAmountReply {
    amount1: int
    amount2: int
}

struct EstimateLiquidityDepositAmountReply {
    amount1Used: int
    amount2Used: int
    lpAmount: int
    lpToLock: int
}

enum Errors {
    Unexpected = 250
    WrongSender = 252
    WrongChain = 255
    WrongAssets = 256
    WrongSignature = 258
    AmmFailed = 262
    InvalidAmmSettings = 263
    InvalidLiquidity = 264
    InvalidFee = 265
    InvalidCondition = 266
    InvalidAssetType = 267
    DeadlineExceeded = 268
    SlippageTolerated = 269
    PoolAlreadyExists = 270
    ReservesRatioFailed = 271
    AlreadyActive = 272
    NotActive = 273
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        poolVersion: 0,
        asset1: createEmptyCell().beginParse(),
        asset2: createEmptyCell().beginParse(),
        amm: 0,
        ammSettings: null,
        active: false,
        reserve1: 0,
        reserve2: 0,
        totalSupply: 0,
        protocolFee: 0,
        lpFee: 0,
    };
}

get fun estimate_swap_amount(asset: slice, amount: int): EstimateSwapAmountReply {
    return {
        inputAmount: 0,
        outputAmount: 0,
    };
}

get fun estimate_liquidity_withdraw_amount(lpAmount: int): EstimateLiquidityWithdrawAmountReply {
    return {
        amount1: 0,
        amount2: 0,
    };
}

get fun estimate_liquidity_deposit_amount(amount1: int, amount2: int): EstimateLiquidityDepositAmountReply {
    return {
        amount1Used: 0,
        amount2Used: 0,
        lpAmount: 0,
        lpToLock: 0,
    };
}
