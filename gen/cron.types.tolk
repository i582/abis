// Generated from XML ABI schemas.
// Source schema: schemas/cron.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Cron {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/cron.xml"
    incomingExternal: CronIncomingExternalMessage
}

// TL-B message bodies.
struct (0x2114702d) CronTrigger {
    rewardAddress: address
    salt: uint32
}

// Message unions used by Acton ABI.
type CronIncomingExternalMessage = CronTrigger

struct GetCronInfoReply {
    nextCallTime: uint32
    reward: coins
    balanceMinusAmounts: int64
    repeatEvery: uint32
}

get fun get_cron_info(): GetCronInfoReply {
    return {
        nextCallTime: 0,
        reward: 0,
        balanceMinusAmounts: 0,
        repeatEvery: 0,
    };
}
