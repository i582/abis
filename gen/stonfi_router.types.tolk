// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiRouter {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
}

struct GetRouterDataReply {
    isLocked: bool
    adminAddress: address
    tempUpgrade: cell
    poolCode: cell
    jettonLpWalletCode: cell
    lpAccountCode: cell
}

get fun get_router_data(): GetRouterDataReply {
    return {
        isLocked: false,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        tempUpgrade: createEmptyCell(),
        poolCode: createEmptyCell(),
        jettonLpWalletCode: createEmptyCell(),
        lpAccountCode: createEmptyCell(),
    };
}
