// Generated from XML ABI schemas.
// Source schema: schemas/storages.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StorageProvider {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storages.xml"
}

struct GetWalletParamsReply {
    seqno: uint32
    subwallet: uint32
    publicKey: int
}

struct GetStorageParamsReply {
    acceptNewContracts: bool
    ratePerMbDay: uint64
    maxSpan: uint32
    minimalFileSize: uint64
    maximalFileSize: uint64
}

get fun get_wallet_params(): GetWalletParamsReply {
    return {
        seqno: 0,
        subwallet: 0,
        publicKey: 0,
    };
}

get fun get_storage_params(): GetStorageParamsReply {
    return {
        acceptNewContracts: false,
        ratePerMbDay: 0,
        maxSpan: 0,
        minimalFileSize: 0,
        maximalFileSize: 0,
    };
}

get fun get_storage_contract_address(merkleHash: int, fileSize: uint64, client: address, torrentHash: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
