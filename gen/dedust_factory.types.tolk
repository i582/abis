// Generated from XML ABI schemas.
// Source schema: schemas/dedust.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract DedustFactory {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dedust.xml"
    incomingMessages: DedustFactoryIncomingMessage
}

// TL-B helper types referenced by messages.
struct (0b0000) Native {}

struct (0b0001) Jetton {
    workchainId: int8
    address: bits256
}

struct (0b0010) ExtraCurrency {
    currencyId: int32
}

type DedustAsset =
    | Native
    | Jetton
    | ExtraCurrency

// TL-B message bodies.
struct (0x21cfe02b) DedustCreateVault {
    queryId: uint64
    asset: cell
}

struct (0x97d51f2f) DedustCreateVolatilePool {
    queryId: uint64
    asset0: cell
    asset1: cell
}

// Message unions used by Acton ABI.
type DedustFactoryIncomingMessage =
    | DedustCreateVault
    | DedustCreateVolatilePool

get fun get_vault_address(asset: slice): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_liquidity_deposit_address(ownerAddr: address, poolType: int, asset0: slice, asset1: slice): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
