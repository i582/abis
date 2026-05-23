// Generated from XML ABI schemas.
// Source schema: schemas/lockup-wallet.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract LockupVesting {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/lockup-wallet.xml"
}

struct GetLockupDataReply {
    startTime: int64
    totalDuration: int64
    unlockPeriod: int64
    cliffDiration: int64
    totalAmount: int64
    allowElector: int64
}

get fun get_lockup_data(): GetLockupDataReply {
    return {
        startTime: 0,
        totalDuration: 0,
        unlockPeriod: 0,
        cliffDiration: 0,
        totalAmount: 0,
        allowElector: 0,
    };
}
