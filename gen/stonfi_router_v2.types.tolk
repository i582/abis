// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiRouterV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
    incomingMessages: StonfiRouterV2IncomingMessage
    outgoingMessages: StonfiRouterV2OutgoingMessage
}

struct StonfiPayToV2AdditionalInfo {
    fwdTonAmount: coins
    amount0Out: coins
    token0Address: address
    amount1Out: coins
    token1Address: address
}

struct StonfiPayVaultV2AdditionalInfo {
    amount0Out: coins
    token0Address: address
    amount1Out: coins
    token1Address: address
}

struct StonfiSwapV2DexPayloadSwapBody {
    minOut: coins
    receiver: address
    fwdGas: coins
    customPayload: cell?
    refundFwdGas: coins
    refundPayload: cell?
    refFee: uint16
    refAddress: address
}

struct StonfiSwapV2DexPayload {
    transferredOp: uint32
    tokenWallet1: address
    refundAddress: address
    excessesAddress: address
    txDeadline: uint64
    swapBody: Cell<StonfiSwapV2DexPayloadSwapBody>
}

// TL-B message bodies.
struct (0x29d22935) PtonResetGas {
    queryId: uint64
}

struct (0x657b54f5) StonfiPayToV2 {
    queryId: uint64
    toAddress: address
    excessesAddress: address
    originalCaller: address
    exitCode: uint32
    customPayload: cell?
    additionalInfo: Cell<StonfiPayToV2AdditionalInfo>
}

struct (0x63381632) StonfiPayVaultV2 {
    queryId: uint64
    owner: address
    excessesAddress: address
    additionalInfo: Cell<StonfiPayVaultV2AdditionalInfo>
}

struct (0x2100c922) StonfiVaultPayToV2 {
    queryId: uint64
    amountOut: coins
    tokenAddress: address
    toAddress: address
}

struct (0x0490f09b) StonfiDepositRefFeeV2 {
    queryId: uint64
    jettonAmount: coins
    excessesAddress: address
}

struct (0x6664de2a) StonfiSwapV2 {
    queryId: uint64
    fromUser: address
    leftAmount: coins
    rightAmount: coins
    dexPayload: Cell<StonfiSwapV2DexPayload>
}

// Message unions used by Acton ABI.
type StonfiRouterV2IncomingMessage =
    | PtonResetGas
    | StonfiPayToV2
    | StonfiPayVaultV2
    | StonfiVaultPayToV2

type StonfiRouterV2OutgoingMessage =
    | StonfiDepositRefFeeV2
    | StonfiSwapV2

struct GetRouterDataReply {
    id: uint32
    dexType: string
    isLocked: bool
    adminAddress: address
    tempUpgrade: cell
    poolCode: cell
    jettonLpWalletCode: cell
    lpAccountCode: cell
    vaultCode: cell
}

struct GetRouterVersionReply {
    major: uint32
    minor: uint32
    development: string
}

get fun get_router_data(): GetRouterDataReply {
    return {
        id: 0,
        dexType: "",
        isLocked: false,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        tempUpgrade: createEmptyCell(),
        poolCode: createEmptyCell(),
        jettonLpWalletCode: createEmptyCell(),
        lpAccountCode: createEmptyCell(),
        vaultCode: createEmptyCell(),
    };
}

get fun get_router_version(): GetRouterVersionReply {
    return {
        major: 0,
        minor: 0,
        development: "",
    };
}
