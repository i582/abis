// Generated from XML ABI schemas.
// Source schema: schemas/multisig.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: d3d14da9a627f0ec3533341829762af92b9540b21bf03665fac09c2b46eabbac

contract MultisigV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/multisig.xml"
}

struct GetMultisigDataReply {
    seqno: int
    threshold: uint8
    signers: cell
    proposers: cell?
}

enum Errors {
    UnauthorizedProposer = 1007
    InvalidNewOrder = 1008
    NotEnoughTon = 100
    UnauthorizedExecute = 101
    SignersOutdated = 102
    InvalidDictionarySequence = 103
    InconsistentData = 108
    InvalidThreshold = 109
    InvalidSigners = 110
    Expired = 111
}

get fun get_multisig_data(): GetMultisigDataReply {
    return {
        seqno: 0,
        threshold: 0,
        signers: createEmptyCell(),
        proposers: null,
    };
}

get fun get_order_address(orderSeqno: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
