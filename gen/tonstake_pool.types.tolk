// Generated from XML ABI schemas.
// Source schema: schemas/liquid_stacking.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract TonstakePool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/liquid_stacking.xml"
}

struct GetPoolFullDataPrevRoundBorrowers {
    borrowersDict: slice?
    roundId: int32
    activeBorrowers: int32
    borrowed: int64
    expected: int64
    retured: int64
    profit: int64
}

struct GetPoolFullDataCurrentRoundBorrowers {
    borrowersDict: cell?
    roundId: int32
    activeBorrowers: int32
    borrowed: int64
    expected: int64
    retured: int64
    profit: int64
}

struct GetPoolFullDataReply {
    state: int32
    halted: bool
    totalBalance: int64
    interestRate: int32
    optimisticDepositWithdrawals: int64
    depositsOpen: bool
    savedValidatorSetHash: uint256
    prevRoundBorrowers: GetPoolFullDataPrevRoundBorrowers
    currentRoundBorrowers: GetPoolFullDataCurrentRoundBorrowers
    minLoanPerValidator: int64
    maxLoanPerValidator: int64
    governanceFee: int32
    jettonMinter: address
    supply: int64
    depositPayout: address?
    requestedForDeposit: int64
    withdrawalPayout: address?
    requestedForWithdrawal: int64
    sudoer: address?
    sudoerSetAt: int32
    governor: address?
    governorUpdateAfter: int64
    interestManager: address?
    halter: address?
    approver: address?
    controllerCode: cell
    poolJettonWalletCode: cell
    payoutMinterCode: cell
    projectedBalance: int64
    projectedSupply: int64
}

get fun get_pool_full_data(): GetPoolFullDataReply {
    return {
        state: 0,
        halted: false,
        totalBalance: 0,
        interestRate: 0,
        optimisticDepositWithdrawals: 0,
        depositsOpen: false,
        savedValidatorSetHash: 0,
        prevRoundBorrowers: {
        borrowersDict: null,
        roundId: 0,
        activeBorrowers: 0,
        borrowed: 0,
        expected: 0,
        retured: 0,
        profit: 0,
    },
        currentRoundBorrowers: {
        borrowersDict: null,
        roundId: 0,
        activeBorrowers: 0,
        borrowed: 0,
        expected: 0,
        retured: 0,
        profit: 0,
    },
        minLoanPerValidator: 0,
        maxLoanPerValidator: 0,
        governanceFee: 0,
        jettonMinter: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        supply: 0,
        depositPayout: null,
        requestedForDeposit: 0,
        withdrawalPayout: null,
        requestedForWithdrawal: 0,
        sudoer: null,
        sudoerSetAt: 0,
        governor: null,
        governorUpdateAfter: 0,
        interestManager: null,
        halter: null,
        approver: null,
        controllerCode: createEmptyCell(),
        poolJettonWalletCode: createEmptyCell(),
        payoutMinterCode: createEmptyCell(),
        projectedBalance: 0,
        projectedSupply: 0,
    };
}
