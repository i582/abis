// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeVaultExtra {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeVaultExtraIncomingMessage
    outgoingMessages: CoffeeVaultExtraOutgoingMessage
}

// TL-B helper types referenced by messages.
struct NotificationDataSingle {
    receiver: address
    fwdGas: coins
    payload: cell
}

struct SwapStepParams {
    poolAddressHash: uint256
    minOutputAmount: coins
    next: Cell<CoffeeSwapStepParams>?
}

struct SwapParams {
    deadline: uint32
    recipient: address
    referral: address
    notificationData: Cell<CoffeeNotificationData>?
}

struct DepositLiquidityParams {
    params: Cell<CoffeeDepositLiquidityParamsTrimmed>
    poolParams: Cell<CoffeePoolParams>
}

struct PoolParams {
    first: cell
    second: cell
    amm: cell
    ammSettings: cell?
}

struct PoolCreationParams {
    publicValue: CoffeePublicPoolCreationParams
    privateValue: CoffeePrivatePoolCreationParams
}

struct ContractUpdate {
    code: cell?
    data: cell?
}

struct SwapStepInternalParams {
    previousAmount: coins
    previousAssetHint: cell?
    minOutputAmount: coins
    next: Cell<CoffeeSwapStepParams>?
}

struct NotificationData {
    onSuccess: Cell<CoffeeNotificationDataSingle>?
    onFailure: Cell<CoffeeNotificationDataSingle>?
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

struct (0b000) ConstantProduct {}

struct (0b001) CurveFiStable {}

struct PublicPoolCreationParams {
    recipient: address
    useRecipientOnFailure: int1
    notificationData: cell?
}

struct PrivatePoolCreationParams {
    isActive: uint1
    extraSettings: cell?
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

type CoffeeNotificationDataSingle = NotificationDataSingle

type CoffeeSwapStepParams = SwapStepParams

type CoffeeSwapParams = SwapParams

type CoffeeDepositLiquidityParams = DepositLiquidityParams

type CoffeePoolParams = PoolParams

type CoffeePoolCreationParams = PoolCreationParams

type CoffeeContractUpdate = ContractUpdate

type CoffeeSwapStepInternalParams = SwapStepInternalParams

type CoffeeNotificationData = NotificationData

type CoffeeDepositLiquidityParamsTrimmed = DepositLiquidityParamsTrimmed

type CoffeeAsset =
    | Native
    | Jetton
    | Extra

type CoffeeAmm =
    | ConstantProduct
    | CurveFiStable

type CoffeePublicPoolCreationParams = PublicPoolCreationParams

type CoffeePrivatePoolCreationParams = PrivatePoolCreationParams

type CoffeeDepositLiquidityCondition =
    | None
    | LpQuantity
    | ReservesRatio
    | Complex

// TL-B message bodies.
struct (0xc0ffee21) CoffeePayoutInternal {
    queryId: uint64
    recipient: address
    amount: coins
    notificationData: Cell<CoffeeNotificationDataSingle>?
    proof: cell?
}

struct (0xc0ffee01) CoffeeSwapExtra {
    queryId: uint64
    field2: CoffeeSwapStepParams
    params: Cell<CoffeeSwapParams>
}

struct (0xc0ffee05) CoffeeDepositLiquidityExtra {
    queryId: uint64
    params: CoffeeDepositLiquidityParams
}

struct (0xc0ffee03) CoffeeCreatePoolExtra {
    queryId: uint64
    params: CoffeePoolParams
    creationParams: CoffeePoolCreationParams
}

struct (0xc0ffee2e) CoffeeUpdateContractInternal {
    queryId: uint64
    excessesReceiver: address
    field3: CoffeeContractUpdate
}

struct (0xc0ffee36) CoffeeNotification {
    queryId: uint64
    body: cell
}

struct (0xc0ffee32) CoffeePayout {
    queryId: uint64
}

struct (0xc0ffee20) CoffeeSwapInternal {
    queryId: uint64
    field2: CoffeeSwapStepInternalParams
    params: Cell<CoffeeSwapParams>
    proof: cell
}

struct (0xc0ffee27) CoffeeCreateLiquidityDepositoryRequest {
    queryId: uint64
    amount: coins
    params: CoffeeDepositLiquidityParams
    sender: address
    proof: cell
}

struct (0xc0ffee23) CoffeeCreatePoolCreatorRequest {
    queryId: uint64
    amount: coins
    params: CoffeePoolParams
    creationParams: Cell<CoffeePoolCreationParams>
    sender: address
    proof: cell
}

// Message unions used by Acton ABI.
type CoffeeVaultExtraIncomingMessage =
    | CoffeePayoutInternal
    | CoffeeSwapExtra
    | CoffeeDepositLiquidityExtra
    | CoffeeCreatePoolExtra
    | CoffeeUpdateContractInternal

type CoffeeVaultExtraOutgoingMessage =
    | CoffeeNotification
    | CoffeePayout
    | CoffeeSwapInternal
    | CoffeeCreateLiquidityDepositoryRequest
    | CoffeeCreatePoolCreatorRequest

enum Errors {
    Unexpected = 250
    WrongSender = 252
    NotAFactory = 253
    WrongChain = 255
    WrongAssets = 256
    SameAssets = 257
    WrongSignature = 258
    InvalidBalance = 259
    InvalidAssetType = 267
}

get fun get_asset(): slice {
    return createEmptyCell().beginParse();
}

get fun is_active(): bool {
    return false;
}
