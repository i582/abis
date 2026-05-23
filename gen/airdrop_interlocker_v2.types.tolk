// Generated from XML ABI schemas.
// Source schema: schemas/airdrop.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 0ff44a96fc2481111236d8d9920fd6e29b6108215e3ec5ba761ead9602adada4

contract AirdropInterlockerV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/airdrop.xml"
}

struct GetDistributionInfoReply {
    merkleRoot: uint256
    receiver: address
    distributor: address
    minCommission: int
}

struct GetUnlocksInfoReply {
    claimed: bool
    totalAmount: int
    claimedAmount: int
    unlocks: cell
}

get fun get_distribution_info(): GetDistributionInfoReply {
    return {
        merkleRoot: 0,
        receiver: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        distributor: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        minCommission: 0,
    };
}

get fun get_unlocks_info(): GetUnlocksInfoReply {
    return {
        claimed: false,
        totalAmount: 0,
        claimedAmount: 0,
        unlocks: createEmptyCell(),
    };
}

get fun get_available_claim_amount(): int {
    return 0;
}
