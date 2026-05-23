// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiPoolV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
    incomingMessages: StonfiPoolV2IncomingMessage
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

struct StonfiProvideLpV2DexPayloadProvideLpBody {
    minLpOut: coins
    toAddress: address
    bothPositive: uint1
    fwdAmount: coins
    customPayload: cell?
}

struct StonfiProvideLpV2DexPayload {
    transferredOp: uint32
    tokenWallet1: address
    refundAddress: address
    excessesAddress: address
    txDeadline: uint64
    provideLpBody: Cell<StonfiProvideLpV2DexPayloadProvideLpBody>
}

struct StonfiCbAddLiquidityV2AdditionalFields {
    toUserAddress: address
    refundAddress: address
    excessAddress: address
}

// TL-B message bodies.
struct (0x297437cf) StonfiBurnNotificationExtV2 {
    queryId: uint64
    jettonAmount: coins
    fromAddress: address
    responseAddress: address
    maybeCustomPayload: cell?
}

struct (0x6664de2a) StonfiSwapV2 {
    queryId: uint64
    fromUser: address
    leftAmount: coins
    rightAmount: coins
    dexPayload: Cell<StonfiSwapV2DexPayload>
}

struct (0x37c096df) StonfiProvideLpV2 {
    queryId: uint64
    fromUser: address
    leftAmount: coins
    rightAmount: coins
    dexPayload: Cell<StonfiProvideLpV2DexPayload>
}

struct (0x29d22935) PtonResetGas {
    queryId: uint64
}

struct (0x06ecd527) StonfiCbAddLiquidityV2 {
    queryId: uint64
    totAm0: coins
    totAm1: coins
    userAddress: address
    minLpOut: coins
    fwdAmount: coins
    customPayloadCs: cell?
    additionalFields: Cell<StonfiCbAddLiquidityV2AdditionalFields>
}

// Message unions used by Acton ABI.
type StonfiPoolV2IncomingMessage =
    | StonfiBurnNotificationExtV2
    | StonfiSwapV2
    | StonfiProvideLpV2
    | PtonResetGas
    | StonfiCbAddLiquidityV2

get fun get_lp_account_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
