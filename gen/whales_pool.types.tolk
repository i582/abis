// Generated from XML ABI schemas.
// Source schema: schemas/whales.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract WhalesPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/whales.xml"
    incomingMessages: WhalesPoolIncomingMessage
    outgoingMessages: WhalesPoolOutgoingMessage
}

// TL-B message bodies.
struct (0xda803efd) WhalesNominatorsWithdraw {
    queryId: int64
    gas: coins
    amount: coins
}

struct (0x7bcd1fef) WhalesNominatorsDeposit {
    queryId: int64
    gas: coins
}

struct (0xa2065f2c) WhalesNominatorsSendStake {
    queryId: uint64
    gasLimit: coins
    stake: coins
    validatorPubkey: bits256
    stakeAt: uint32
    maxFactor: uint32
    adnlAddr: bits256
    signature: Cell<bits512>
}

struct (0x251d6a98) WhalesNominatorsWithdrawUnowned {
    queryId: uint64
    gasLimit: coins
}

struct (0x1596920c) WhalesNominatorsForceKick {
    queryId: int64
}

struct (0x99a811fb) WhalesNominatorsAcceptStake {
    queryId: uint64
    members: cell
}

struct (0xa19fd934) WhalesNominatorsAcceptWithdraws {
    queryId: uint64
    members: cell
}

struct (0x1d1715bf) WhalesNominatorsWithdrawUnownedResponse {
    queryId: uint64
}

struct (0x23d421e1) WhalesNominatorsStakeWithdrawCompleted {
    queryId: int64
}

// Message unions used by Acton ABI.
type WhalesPoolIncomingMessage =
    | WhalesNominatorsWithdraw
    | WhalesNominatorsDeposit
    | WhalesNominatorsSendStake
    | WhalesNominatorsWithdrawUnowned
    | WhalesNominatorsForceKick

type WhalesPoolOutgoingMessage =
    | WhalesNominatorsAcceptStake
    | WhalesNominatorsAcceptWithdraws
    | WhalesNominatorsWithdrawUnownedResponse
    | WhalesNominatorsStakeWithdrawCompleted

struct GetStakingStatusReply {
    stakeAt: uint32
    stakeUntil: uint32
    stakeSent: uint64
    querySent: bool
    couldUnlock: bool
    locked: bool
    proxyStakeLockFinal: bool
}

struct GetPoolStatusReply {
    balance: int64
    balanceSent: int64
    balancePendingDeposits: int64
    balancePendingWithdraw: int64
    balanceWithdraw: int64
}

struct GetParamsReply {
    enabled: bool
    updatesEnables: bool
    minStake: int64
    depositFee: int64
    withdrawFee: int64
    poolFee: int64
    receiptPrice: int64
}

get fun get_staking_status(): GetStakingStatusReply {
    return {
        stakeAt: 0,
        stakeUntil: 0,
        stakeSent: 0,
        querySent: false,
        couldUnlock: false,
        locked: false,
        proxyStakeLockFinal: false,
    };
}

get fun get_pool_status(): GetPoolStatusReply {
    return {
        balance: 0,
        balanceSent: 0,
        balancePendingDeposits: 0,
        balancePendingWithdraw: 0,
        balanceWithdraw: 0,
    };
}

get fun get_params(): GetParamsReply {
    return {
        enabled: false,
        updatesEnables: false,
        minStake: 0,
        depositFee: 0,
        withdrawFee: 0,
        poolFee: 0,
        receiptPrice: 0,
    };
}
