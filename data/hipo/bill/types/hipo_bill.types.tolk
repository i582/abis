/// Hipo Finance per-bill NFT/SBT-style contract for deposit and withdrawal accounting.
contract HipoBill {
    author: "Hipo Finance"
    version: "1.0"
    description: "Curated interface for Hipo Finance Bill item contracts"
    storage: HipoBillStorage
    incomingMessages: HipoBillIncomingMessage
    outgoingMessages: HipoBillOutgoingMessage
    thrownErrors: HipoBillErrors
}

/// Persistent Bill state stored in the root data cell by `load_data`/`save_data`.
struct HipoBillStorage {
    /// Bill index stored as uint64; Hipo collections can reuse index zero across collection epochs.
    index: uint64
    /// Collection address authorized to assign and burn this bill.
    collection: address
    /// Unix revocation timestamp stored as uint32; zero means the bill is not revoked.
    revokedAt: uint32
    /// Parent address related to the wallet/round, or `addr_none` before assignment.
    parent: address?
    /// Owner address that can request proofs or destroy a revoked bill, or `addr_none` before assignment.
    owner: address?
    /// True for withdrawal/unstake bills; false for deposit/mint bills.
    unstake: bool
    /// Bill amount in nanotons or hTON nano-units depending on `unstake`.
    amount: coins
}

/// Collection-to-Bill assignment body accepted only from the stored collection address.
struct (0x3275dfc2) HipoBillAssign {
    /// Query id copied into the optional ownership-assigned notification.
    queryId: uint64
    /// Amount stored by the bill after assignment.
    amount: coins
    /// True for withdrawal/unstake bills; false for deposit/mint bills.
    unstake: bool
    /// Owner address stored by the bill; source accepts a raw MsgAddress, so `addr_none` is representable.
    owner: address?
    /// Parent address stored by the bill; source accepts a raw MsgAddress, so `addr_none` is representable.
    parent: address?
    /// Nanotons sent to the owner as an `ownership_assigned` notification; zero suppresses the send.
    notify: coins
}

/// Collection-to-Bill burn/revoke request accepted only from the stored collection address.
struct (0x6f89f5e3) HipoBillBurn {
    /// Query id copied into the outgoing `bill_burned` report.
    queryId: uint64
}

/// Owner-only destroy request accepted only after the bill was revoked.
struct (0x1f04537a) HipoBillDestroy {
    /// Query id copied into the outgoing `gas_excess` response.
    queryId: uint64
}

/// Owner-only TEP-85 ownership proof request.
struct (0x04ded148) HipoBillProveOwnership {
    /// Query id copied into `ownership_proof`.
    queryId: uint64
    /// Destination that receives the ownership proof response.
    destination: address
    /// Referenced payload copied into the outgoing proof.
    forwardPayload: cell
    /// True when the proof should include generated on-chain Bill metadata.
    withContent: bool
}

/// Open TEP-85 owner lookup request.
struct (0xd0c3bfea) HipoBillRequestOwner {
    /// Query id copied into `owner_info`.
    queryId: uint64
    /// Destination that receives the owner information response.
    destination: address
    /// Referenced payload copied into the outgoing owner-info response.
    forwardPayload: cell
    /// True when the response should include generated on-chain Bill metadata.
    withContent: bool
}

/// TEP-62 static-data request handled by the Bill item.
struct (0x2fcb26a2) HipoBillGetStaticData {
    /// Query id copied into `report_static_data`.
    queryId: uint64
}

/// Notification optionally emitted to the assigned owner after `assign_bill`.
struct (0x05138d91) HipoBillOwnershipAssigned {
    /// Query id copied from `assign_bill`.
    queryId: uint64
    /// Previous owner address; Hipo Bill source currently emits `addr_none`.
    previousOwner: address?
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; current source emits inline empty payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Burn report emitted to the collection when a Bill is revoked.
struct (0x840f6369) HipoBillBurned {
    /// Query id copied from `burn_bill`.
    queryId: uint64
    /// Amount stored by the bill at burn time.
    amount: coins
    /// True for withdrawal/unstake bills; false for deposit/mint bills.
    unstake: bool
    /// Owner stored by the bill at burn time, or `addr_none` if never assigned.
    owner: address?
    /// Parent stored by the bill at burn time, or `addr_none` if never assigned.
    parent: address?
    /// Bill index reported to the collection as uint64.
    index: uint64
}

/// Excess-value response emitted after a successful owner-only destroy.
struct (0xd53276db) HipoBillGasExcess {
    /// Query id copied from `destroy`.
    queryId: uint64
}

/// Ownership proof response emitted for owner-only `prove_ownership` calls.
struct (0x0524c7ae) HipoBillOwnershipProof {
    /// Query id copied from `prove_ownership`.
    queryId: uint64
    /// Bill index encoded as uint256 by the source.
    index: uint256
    /// Owner address that authorized the proof, or `addr_none` if storage was already cleared.
    owner: address?
    /// Referenced payload copied from the request.
    forwardPayload: cell
    /// Revocation timestamp widened to uint64 in the outgoing SBT-compatible body.
    revokedAt: uint64
    /// Optional generated metadata cell included only when `withContent` was true.
    content: cell?
}

/// Owner information response emitted for open `request_owner` calls.
struct (0x0dd607e3) HipoBillOwnerInfo {
    /// Query id copied from `request_owner`.
    queryId: uint64
    /// Bill index encoded as uint256 by the source.
    index: uint256
    /// Address that initiated the owner lookup.
    initiator: address?
    /// Current owner address, or `addr_none` before assignment or after destroy.
    owner: address?
    /// Referenced payload copied from the request.
    forwardPayload: cell
    /// Revocation timestamp widened to uint64 in the outgoing SBT-compatible body.
    revokedAt: uint64
    /// Optional generated metadata cell included only when `withContent` was true.
    content: cell?
}

/// TEP-62 static-data response emitted to the requester.
struct (0x8b771735) HipoBillReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// Bill index encoded as uint256 by the source.
    index: uint256
    /// Collection address stored by the bill.
    collection: address
}

/// Bounce-routed notification emitted to the owner when an ownership proof bounces.
struct (0xc18e86d2) HipoBillOwnershipProofBounced {
    /// Query id copied from the bounced `ownership_proof` body.
    queryId: uint64
}

/// Internal message bodies accepted by Hipo Bill.
type HipoBillIncomingMessage =
    | HipoBillAssign
    | HipoBillBurn
    | HipoBillDestroy
    | HipoBillProveOwnership
    | HipoBillRequestOwner
    | HipoBillGetStaticData

/// Internal message bodies emitted by Hipo Bill.
type HipoBillOutgoingMessage =
    | HipoBillOwnershipAssigned
    | HipoBillBurned
    | HipoBillGasExcess
    | HipoBillOwnershipProof
    | HipoBillOwnerInfo
    | HipoBillReportStaticData
    | HipoBillOwnershipProofBounced

/// Structured result returned by `get_nft_data`.
struct HipoBillNftDataReply {
    /// True when the bill has a non-`addr_none` parent, matching `~ parent.addr_none?()`.
    isInitialized: bool
    /// Bill index returned as a TVM stack integer.
    index: int
    /// Collection address stored by the bill.
    collection: address
    /// Owner stack MsgAddress; can be `addr_none` before assignment or after destroy.
    owner: any_address
    /// Generated TEP-64 on-chain metadata cell for this bill.
    content: cell
}

/// Bill exit-code catalog from Hipo Finance `constants.fc`.
enum HipoBillErrors {
    /// Sender is not the stored collection for collection-only ops or not the stored owner for owner-only ops.
    AccessDenied = 103
    /// Burn was requested after the bill had already been revoked.
    Stopped = 106
    /// Incoming internal message opcode is not handled by Bill.
    InvalidOp = 107
}

/// Return Bill initialization flag, index, collection, owner, and generated content.
get fun get_nft_data(): HipoBillNftDataReply {
    throw 0;
}

/// Return the collection/authority address that controls assignment and revocation.
get fun get_authority_address(): address {
    throw 0;
}

/// Return the uint32 revocation timestamp, or zero while the bill is active.
get fun get_revoked_time(): uint32 {
    throw 0;
}
