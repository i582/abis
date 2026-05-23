// Generated from XML ABI schemas.
// Source schema: schemas/nfts.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 4c9123828682fa6f43797ab41732bca890cae01766e0674100250516e0bf8d42

contract NftItemSimple {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/nfts.xml"
    incomingMessages: NftItemSimpleIncomingMessage
    outgoingMessages: NftItemSimpleOutgoingMessage
}

// TL-B message bodies.
struct (0x5fcc3d14) NftTransfer {
    queryId: uint64
    newOwner: address
    responseDestination: address
    customPayload: cell?
    forwardAmount: coins
    forwardPayload: RemainingBitsAndRefs
}

struct (0x2fcb26a2) GetStaticData {
    queryId: uint64
}

struct (0x05138d91) NftOwnershipAssigned {
    queryId: uint64
    prevOwner: address
    forwardPayload: RemainingBitsAndRefs
}

struct (0x8b771735) ReportStaticData {
    queryId: uint64
    index: uint256
    collection: address
}

// Message unions used by Acton ABI.
type NftItemSimpleIncomingMessage =
    | NftTransfer
    | GetStaticData

type NftItemSimpleOutgoingMessage =
    | NftOwnershipAssigned
    | ReportStaticData

struct GetNftDataReply {
    init: bool
    index: int
    collectionAddress: address
    ownerAddress: address
    individualContent: cell
}

get fun get_nft_data(): GetNftDataReply {
    return {
        init: false,
        index: 0,
        collectionAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        individualContent: createEmptyCell(),
    };
}
