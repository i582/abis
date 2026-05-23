// Generated from XML ABI schemas.
// Source schema: schemas/liquid_stacking.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract ValidatorController {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/liquid_stacking.xml"
}

struct GetValidatorControllerDataReply {
    state: int32
    halted: bool
    approved: bool
    stakeAmountSent: int64
    stakeAt: uint32
    savedValidatorSetHash: uint256
    validatorSetChangesCount: int32
    validatorSetChangeTime: uint32
    stakeHeldFor: uint32
    borrowedAmount: int64
    borrowingTime: uint32
    validator: address
    pool: address
    sudoer: address
}

get fun get_validator_controller_data(): GetValidatorControllerDataReply {
    return {
        state: 0,
        halted: false,
        approved: false,
        stakeAmountSent: 0,
        stakeAt: 0,
        savedValidatorSetHash: 0,
        validatorSetChangesCount: 0,
        validatorSetChangeTime: 0,
        stakeHeldFor: 0,
        borrowedAmount: 0,
        borrowingTime: 0,
        validator: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        pool: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        sudoer: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}
