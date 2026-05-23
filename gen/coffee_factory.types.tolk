// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeFactory {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
    incomingMessages: CoffeeFactoryIncomingMessage
    outgoingMessages: CoffeeFactoryOutgoingMessage
}

// TL-B helper types referenced by messages.
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

struct DepositLiquidityParams {
    params: Cell<CoffeeDepositLiquidityParamsTrimmed>
    poolParams: Cell<CoffeePoolParams>
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

struct DepositLiquidityParamsTrimmed {
    recipient: address
    useRecipientOnFailure: int1
    referral: address
    deadline: uint32
    condition: cell
    extraSettings: cell?
    notificationData: Cell<CoffeeNotificationData>?
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

struct NotificationData {
    onSuccess: Cell<CoffeeNotificationDataSingle>?
    onFailure: Cell<CoffeeNotificationDataSingle>?
}

struct NotificationDataSingle {
    receiver: address
    fwdGas: coins
    payload: cell
}

type CoffeePoolParams = PoolParams

type CoffeePoolCreationParams = PoolCreationParams

type CoffeeDepositLiquidityParams = DepositLiquidityParams

type CoffeeAsset =
    | Native
    | Jetton
    | Extra

type CoffeeContractUpdate = ContractUpdate

type CoffeeAmm =
    | ConstantProduct
    | CurveFiStable

type CoffeePublicPoolCreationParams = PublicPoolCreationParams

type CoffeePrivatePoolCreationParams = PrivatePoolCreationParams

type CoffeeDepositLiquidityParamsTrimmed = DepositLiquidityParamsTrimmed

type CoffeeDepositLiquidityCondition =
    | None
    | LpQuantity
    | ReservesRatio
    | Complex

type CoffeeNotificationData = NotificationData

type CoffeeNotificationDataSingle = NotificationDataSingle

// TL-B message bodies.
struct (0xc0ffee23) CoffeeCreatePoolCreatorRequest {
    queryId: uint64
    amount: coins
    params: CoffeePoolParams
    creationParams: Cell<CoffeePoolCreationParams>
    sender: address
    proof: cell
}

struct (0xc0ffee27) CoffeeCreateLiquidityDepositoryRequest {
    queryId: uint64
    amount: coins
    params: CoffeeDepositLiquidityParams
    sender: address
    proof: cell
}

struct (0xc0ffee25) CoffeeCreatePoolRequest {
    queryId: uint64
    amount1: coins
    amount2: coins
    txInitiator: address
    creationParams: Cell<CoffeePoolCreationParams>
    proof: cell
}

struct (0xc0ffee06) CoffeeCreateVault {
    queryId: uint64
    asset: cell
}

struct (0xc0ffee40) CoffeeUpdateAdmin {
    queryId: uint64
    address: address
}

struct (0xc0ffee46) CoffeeUpdateWithdrawer {
    queryId: uint64
    address: address
}

struct (0xc0ffee44) CoffeeUpdateCodeCells {
    queryId: uint64
    first: cell
    second: cell
}

struct (0xc0ffee45) CoffeeUpdateContract {
    queryId: uint64
    contractAddress: address
    field3: CoffeeContractUpdate
}

struct (0xc0ffee42) CoffeeActivateVault {
    queryId: uint64
    asset: cell
    wallet: address
}

struct (0xc0ffee43) CoffeeWithdraw {
    queryId: uint64
    poolAddress: address
    asset: cell
    amount: coins
    receiver: address
}

struct (0xc0ffee22) CoffeeDeploy {
    code: cell
    data: cell
    action: cell?
}

struct (0xc0ffee2e) CoffeeUpdateContractInternal {
    queryId: uint64
    excessesReceiver: address
    field3: CoffeeContractUpdate
}

struct (0xc0ffee2c) CoffeeActivateVaultInternal {
    queryId: uint64
    wallet: address
}

struct (0xc0ffee2d) CoffeeWithdrawInternal {
    queryId: uint64
    asset: cell
    amount: coins
    receiver: address
}

// Message unions used by Acton ABI.
type CoffeeFactoryIncomingMessage =
    | CoffeeCreatePoolCreatorRequest
    | CoffeeCreateLiquidityDepositoryRequest
    | CoffeeCreatePoolRequest
    | CoffeeCreateVault
    | CoffeeUpdateAdmin
    | CoffeeUpdateWithdrawer
    | CoffeeUpdateCodeCells
    | CoffeeUpdateContract
    | CoffeeActivateVault
    | CoffeeWithdraw

type CoffeeFactoryOutgoingMessage =
    | CoffeeDeploy
    | CoffeeUpdateContractInternal
    | CoffeeActivateVaultInternal
    | CoffeeWithdrawInternal

struct GetPoolAddressNoSettingsReply {
    address: address
    hash: int
}

struct GetPoolCreatorAddressReply {
    address: address
    hash: int
}

struct GetPoolCreatorAddressNoSettingsReply {
    address: address
    hash: int
}

struct GetLiquidityDepositoryAddressReply {
    address: address
    hash: int
}

struct GetLiquidityDepositoryAddressNoSettingsReply {
    address: address
    hash: int
}

struct GetCodeReply {
    first: cell
    second: cell
}

enum Errors {
    Unexpected = 250
    WrongSender = 252
    NotAnAdmin = 254
    WrongChain = 255
    WrongAssets = 256
    SameAssets = 257
    WrongSignature = 258
    InvalidAssetType = 267
}

get fun get_pool_address_no_settings(asset1: slice, asset2: slice, amm: int): GetPoolAddressNoSettingsReply {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

get fun get_pool_creator_address(owner: address, asset1: slice, asset2: slice, amm: int, ammSettings: cell): GetPoolCreatorAddressReply {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

get fun get_pool_creator_address_no_settings(owner: address, asset1: slice, asset2: slice, amm: int): GetPoolCreatorAddressNoSettingsReply {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

get fun get_liquidity_depository_address(owner: address, asset1: slice, asset2: slice, amm: int, ammSettings: cell): GetLiquidityDepositoryAddressReply {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

get fun get_liquidity_depository_address_no_settings(owner: address, asset1: slice, asset2: slice, amm: int): GetLiquidityDepositoryAddressNoSettingsReply {
    return {
        address: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        hash: 0,
    };
}

get fun get_admin_address(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_code(): GetCodeReply {
    return {
        first: createEmptyCell(),
        second: createEmptyCell(),
    };
}
