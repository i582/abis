// Generated from XML ABI schemas.
// Source schema: schemas/locker.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Locker {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/locker.xml"
}

struct GetLockerDataReply {
    totalCoinsLocked: uint64
    totalReward: uint64
    depositsEndTime: uint32
    vestingStartTime: uint32
    vestingTotalDuration: uint32
    unlockPeriod: uint32
}

get fun get_locker_data(): GetLockerDataReply {
    return {
        totalCoinsLocked: 0,
        totalReward: 0,
        depositsEndTime: 0,
        vestingStartTime: 0,
        vestingTotalDuration: 0,
        unlockPeriod: 0,
    };
}

get fun get_bill_address(userAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
