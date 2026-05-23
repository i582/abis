// Generated from XML ABI schemas.
// Source schema: schemas/locker.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract LockerBill {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/locker.xml"
}

struct GetLockerBillDataReply {
    lockerAddress: address
    totalCoinsDeposit: uint64
    userAddress: address
    lastWithdrawTime: uint32
}

get fun get_locker_bill_data(): GetLockerBillDataReply {
    return {
        lockerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        totalCoinsDeposit: 0,
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        lastWithdrawTime: 0,
    };
}
