// Generated from XML ABI schemas.
// Source schema: schemas/airdrop.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: acd2b8ec4db7414396fa53698653ecc04a416ee3649d8f5b20b41f176ad833f0

contract AirdropInterlockerV1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/airdrop.xml"
}

struct GetContractDataReply {
    isClaimed: bool
    merkleRoot: uint256
    receiver: address
    distributor: address
}

get fun get_contract_data(): GetContractDataReply {
    return {
        isClaimed: false,
        merkleRoot: 0,
        receiver: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        distributor: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}
