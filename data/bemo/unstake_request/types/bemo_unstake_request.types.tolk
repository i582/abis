/// Bemo v2 per-user Unstake Request contract.
contract BemoUnstakeRequest {
    author: "Bemo"
    version: "2.0"
    description: "Curated interface for Bemo v2 delayed Unstake Request contracts"
    storage: BemoUnstakeRequestStorage
    incomingMessages: BemoUnstakeRequestIncomingMessage
    outgoingMessages: BemoUnstakeRequestOutgoingMessage
}

/// Persistent Unstake Request state stored in the root data cell.
struct BemoUnstakeRequestStorage {
    /// Sequential request index assigned by Financial.
    index: uint64
    /// Financial contract address authorized to update or return this request.
    financial: address
    /// User address that receives unstaked TON.
    owner: address
    /// TON amount withdrawable after the lockup, in nanotons.
    tonAmount: coins
    /// Burned bmTON amount associated with the request.
    jettonAmount: coins
    /// Optional payload copied into the Financial unstake message.
    forwardPayload: cell?
    /// Unix timestamp when the request may send `BemoUnstakeRequestUnstake`; zero after it has fired.
    unlockTimestamp: uint32
}

/// Body sent by Financial to initialize or update a request.
struct (0x10a1ce75) BemoUnstakeRequestDeploy {
    /// User address stored as the request owner.
    ownerAddress: address
    /// TON amount withdrawable after lockup.
    withdrawTonAmount: coins
    /// Burned bmTON amount associated with the request.
    withdrawJettonAmount: coins
    /// Optional payload stored and later sent back to Financial.
    forwardPayload: cell?
    /// Unix timestamp when this request may be executed.
    lockupTimestamp: uint32
}

/// Body sent by Financial when the request should retry later.
struct (0x38633538) BemoUnstakeRequestReturn {
    /// Replacement Unix timestamp for the next retry attempt.
    lockupTimestamp: uint32
}

/// Unstake body emitted to Financial once this request unlocks.
struct (0x492ab1b3) BemoUnstakeRequestUnstake {
    /// Sequential request index stored in this contract.
    index: uint64
    /// User address that should receive unstaked TON.
    owner: address
    /// TON amount requested for withdrawal, in nanotons.
    tonAmount: coins
    /// Burned bmTON amount associated with the request.
    jettonAmount: coins
    /// Optional payload copied from request storage.
    forwardPayload: cell?
}

/// Internal message bodies accepted from Financial.
type BemoUnstakeRequestIncomingMessage =
    | BemoUnstakeRequestDeploy
    | BemoUnstakeRequestReturn

/// Internal message bodies emitted by an Unstake Request.
type BemoUnstakeRequestOutgoingMessage = BemoUnstakeRequestUnstake

/// Structured result returned by `get_unstake_data`.
struct BemoUnstakeRequestDataReply {
    /// Sequential request index stored in this contract.
    index: uint64
    /// Financial contract address authorized for updates.
    financial: address
    /// User address that receives unstaked TON.
    owner: address
    /// TON amount withdrawable after lockup.
    tonAmount: coins
    /// Burned bmTON amount associated with the request.
    jettonAmount: coins
    /// Unix timestamp when execution is allowed; zero after the request has fired.
    unlockTimestamp: uint32
    /// Optional payload copied into the outgoing unstake body.
    forwardPayload: cell?
}

/// Unstake Request exit-code catalog proven from the verified library decompile.
enum BemoUnstakeRequestErrors {
    /// Financial sent a body opcode other than deploy/update or return.
    UnsupportedFinancialOperation = 65535
    /// Unlock was attempted after this request had already fired or was not initialized.
    RequestAlreadyConsumed = 50
    /// Unlock was attempted before `unlockTimestamp`.
    RequestStillLocked = 51
    /// Attached value is below the required forward, compute, and storage-fee budget.
    NotEnoughValue = 48
}

/// Return request index, Financial address, owner, TON amount, bmTON amount, unlock timestamp, and payload.
get fun get_unstake_data(): BemoUnstakeRequestDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw BemoUnstakeRequestErrors.UnsupportedFinancialOperation;
    assert (true) throw BemoUnstakeRequestErrors.RequestAlreadyConsumed;
    assert (true) throw BemoUnstakeRequestErrors.RequestStillLocked;
    assert (true) throw BemoUnstakeRequestErrors.NotEnoughValue;
    return {
        index: 0,
        financial: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        owner: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        tonAmount: 0,
        jettonAmount: 0,
        unlockTimestamp: 0,
        forwardPayload: null,
    };
}
