// Generated from XML ABI schemas.
// Source schema: schemas/storages.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StorageContract {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/storages.xml"
}

struct GetStorageContractDataReply {
    active: bool
    balance: uint64
    provider: address
    merkleHash: int
    fileSize: uint64
    nextProof: uint64
    ratePerMbDay: uint64
    maxSpan: uint32
    lastProofTime: uint32
    client: address
    torrentHash: int
}

struct GetNextProofInfoReply {
    nextProof: uint64
    lastProofTime: uint32
    maxSpan: uint32
}

get fun get_storage_contract_data(): GetStorageContractDataReply {
    return {
        active: false,
        balance: 0,
        provider: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        merkleHash: 0,
        fileSize: 0,
        nextProof: 0,
        ratePerMbDay: 0,
        maxSpan: 0,
        lastProofTime: 0,
        client: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        torrentHash: 0,
    };
}

get fun get_torrent_hash(): int {
    return 0;
}

get fun is_active(): bool {
    return false;
}

get fun get_next_proof_info(): GetNextProofInfoReply {
    return {
        nextProof: 0,
        lastProofTime: 0,
        maxSpan: 0,
    };
}
