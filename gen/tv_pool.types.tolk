// Generated from XML ABI schemas.
// Source schema: schemas/tonvalidators.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract TvPool {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tonvalidators.xml"
}

struct GetPoolDataConfigProposalVotings {
}

struct GetPoolDataReply {
    state: int8
    nominatorsCount: uint32
    stakeAmountSent: int64
    validatorAmount: int64
    validatorAddress: uint256
    validatorRewardShare: uint32
    maxNominatorsCount: uint32
    minValidatorStake: int64
    minNominatorStake: int64
    nominators: cell?
    withdrawRequests: cell?
    stakeAt: uint32
    savedValidatorSetHash: uint256
    validatorSetChangesCount: uint32
    validatorSetChangeTime: uint32
    stakeHeldFor: uint32
    configProposalVotings: lisp_list<GetPoolDataConfigProposalVotings>
}

struct ListNominatorsNominators {
    address: uint256
    amount: uint64
    pendingDepositAmount: uint64
    withdrawRequested: bool
}

struct ListVotesVotes {
    proposalHash: uint256
    voteCreateTime: uint32
}

get fun get_pool_data(): GetPoolDataReply {
    return {
        state: 0,
        nominatorsCount: 0,
        stakeAmountSent: 0,
        validatorAmount: 0,
        validatorAddress: 0,
        validatorRewardShare: 0,
        maxNominatorsCount: 0,
        minValidatorStake: 0,
        minNominatorStake: 0,
        nominators: null,
        withdrawRequests: null,
        stakeAt: 0,
        savedValidatorSetHash: 0,
        validatorSetChangesCount: 0,
        validatorSetChangeTime: 0,
        stakeHeldFor: 0,
        configProposalVotings: [],
    };
}

get fun list_nominators(): lisp_list<ListNominatorsNominators> {
    return [];
}

get fun list_votes(): lisp_list<ListVotesVotes> {
    return [];
}
