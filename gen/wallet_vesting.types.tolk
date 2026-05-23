// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: b48b531abec3b714638291f7d77ed6dc9f6a2729efca20477137374d4ae8b590

contract WalletVesting {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
}

struct GetVestingDataReply {
    vestingStartTime: int32
    vestingTotalDuration: int32
    unlockPeriod: int32
    cliffDuration: int32
    vestingTotalAmount: int64
    vestingSenderAddress: address
    ownerAddress: address
    whitelist: cell
}

get fun seqno(): uint32 {
    return 0;
}

get fun get_public_key(): int {
    return 0;
}

get fun get_vesting_data(): GetVestingDataReply {
    return {
        vestingStartTime: 0,
        vestingTotalDuration: 0,
        unlockPeriod: 0,
        cliffDuration: 0,
        vestingTotalAmount: 0,
        vestingSenderAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        whitelist: createEmptyCell(),
    };
}
