// Generated from XML ABI schemas.
// Source schema: schemas/payment_channels.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract PaymentChannel {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/payment_channels.xml"
}

// TL-B parser notes:
// - type_3: TL-B declaration is empty.
// - type_4: TL-B declaration is empty.
// - type_5: TL-B declaration is empty.
// - type_6: TL-B declaration is empty.
// - type_7: TL-B declaration is empty.
// - type_9: TL-B declaration is empty.

struct GetChannelDataBalances {
    a: int64
    b: int64
}

struct GetChannelDataKeys {
    a: uint256
    b: uint256
}

struct GetChannelDataClosureConfig {
    quarantinDuration: uint32
    misbehaviorFine: int64
    conditionalCloseDuration: uint32
}

struct GetChannelDataCommittedSeqno {
    a: uint32
    b: uint32
}

struct GetChannelDataAddresses {
    excessFee: int64
    addrA: address
    addrB: address
}

struct GetChannelDataReply {
    state: int8
    balances: GetChannelDataBalances
    keys: GetChannelDataKeys
    channelId: uint128
    closureConfig: GetChannelDataClosureConfig
    committedSeqno: GetChannelDataCommittedSeqno
    quarantine: slice?
    addresses: GetChannelDataAddresses
}

get fun get_channel_data(): GetChannelDataReply {
    return {
        state: 0,
        balances: {
        a: 0,
        b: 0,
    },
        keys: {
        a: 0,
        b: 0,
    },
        channelId: 0,
        closureConfig: {
        quarantinDuration: 0,
        misbehaviorFine: 0,
        conditionalCloseDuration: 0,
    },
        committedSeqno: {
        a: 0,
        b: 0,
    },
        quarantine: null,
        addresses: {
        excessFee: 0,
        addrA: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        addrB: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    },
    };
}
