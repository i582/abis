// Generated from XML ABI schemas.
// Source schema: schemas/nfts.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract NftCollection {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/nfts.xml"
    incomingMessages: NftCollectionIncomingMessage
    outgoingMessages: NftCollectionOutgoingMessage
}

// TL-B message bodies.
struct (0x693d3950) GetRoyaltyParams {
    queryId: uint64
}

struct (0xa8cb00ad) ReportRoyaltyParams {
    queryId: uint64
    numerator: uint16
    denominator: uint16
    destination: address
}

// Message unions used by Acton ABI.
type NftCollectionIncomingMessage = GetRoyaltyParams

type NftCollectionOutgoingMessage = ReportRoyaltyParams

struct GetCollectionDataReply {
    nextItemIndex: int
    collectionContent: cell
    ownerAddress: address
}

get fun get_nft_content(index: int, individualContent: cell): cell {
    return createEmptyCell();
}

get fun get_collection_data(): GetCollectionDataReply {
    return {
        nextItemIndex: 0,
        collectionContent: createEmptyCell(),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

get fun get_nft_address_by_index(index: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
