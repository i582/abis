// Generated from XML ABI schemas.
// Source schema: schemas/multisig.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: a01e057fbd4288402b9898d78d67bd4e90254c93c5866879bc2d1d12865436bc

contract MultisigOrderV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/multisig.xml"
}

struct GetOrderDataReply {
    multisigAddress: address
    orderSeqno: int256
    threshold: uint8
    sentForExecution: bool
    signers: cell
    approvalsMask: int256
    approvalsNum: uint8
    expirationDate: uint64
    order: cell
}

enum Errors {
    UnauthorizedInit = 104
    AlreadyInited = 105
    UnauthorizedSign = 106
    AlreadyApproved = 107
    Expired = 111
    AlreadyExecuted = 112
    UnknownOp = 65535
}

get fun get_order_data(): GetOrderDataReply {
    return {
        multisigAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        orderSeqno: 0,
        threshold: 0,
        sentForExecution: false,
        signers: createEmptyCell(),
        approvalsMask: 0,
        approvalsNum: 0,
        expirationDate: 0,
        order: createEmptyCell(),
    };
}
