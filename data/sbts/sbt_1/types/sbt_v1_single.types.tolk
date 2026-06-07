/// Getgems TEP-85 SBT v1 single-token interface.
contract SbtV1Single {
    author: "Getgems"
    version: "1"
    description: "Curated TEP-85 single SBT interface with editable content and editorship"
    storage: SbtV1SingleStorage
    incomingMessages: SbtV1SingleIncomingMessage
    outgoingMessages: SbtV1SingleOutgoingMessage
    thrownErrors: SbtV1SingleErrors
}

/// Runtime storage for the Getgems single SBT variant.
struct SbtV1SingleStorage {
    /// Current owner address, or `addr_none` after `destroy`.
    ownerAddress: address?
    /// Current editor address authorized to update content and transfer editorship.
    editorAddress: address
    /// Referenced individual SBT content cell.
    content: cell
    /// Authority address allowed to revoke the SBT, or `addr_none` when unset.
    authorityAddress: address?
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
}

/// Rejected TEP-62 transfer request kept in ABI because TEP-85 requires NFT compatibility.
struct (0x5fcc3d14) SbtV1SingleTransfer {
    /// Caller-selected query id parsed before the source rejects transfer with exit code 413.
    queryId: uint64
    /// New owner address from the inherited NFT transfer layout.
    newOwnerAddress: address
    /// Optional response destination from the inherited NFT transfer layout.
    responseDestination: address?
    /// Optional custom payload from the inherited NFT transfer layout.
    customPayload: cell?
    /// Nanotons from the inherited NFT transfer layout.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Request for static item data emitted back to the caller.
struct (0x2fcb26a2) SbtV1SingleGetStaticData {
    /// Caller-selected query id copied into `report_static_data`.
    queryId: uint64
}

/// Open SBT owner lookup request defined by TEP-85.
struct (0xd0c3bfea) SbtV1SingleRequestOwner {
    /// Caller-selected query id copied into `owner_info`.
    queryId: uint64
    /// Destination that receives the owner information response.
    destination: address
    /// Referenced payload copied into the outgoing `owner_info` data field.
    forwardPayload: cell
    /// True when the outgoing response should include the SBT content ref.
    withContent: bool
}

/// Owner-only TEP-85 ownership proof request.
struct (0x04ded148) SbtV1SingleProveOwnership {
    /// Caller-selected query id copied into `ownership_proof`.
    queryId: uint64
    /// Destination that receives the ownership proof response.
    destination: address
    /// Referenced payload copied into the outgoing `ownership_proof` data field.
    forwardPayload: cell
    /// True when the outgoing proof should include the SBT content ref.
    withContent: bool
}

/// Editor-originated request to transfer editorship.
struct (0x1c04412a) SbtV1SingleTransferEditorship {
    /// Caller-selected query id copied into outgoing responses.
    queryId: uint64
    /// New editor address; source restricts it to the base workchain.
    newEditorAddress: address
    /// Optional response destination for `excesses`; `addr_none` means no response.
    responseDestination: address?
    /// Raw custom-payload presence bit; this source does not read a custom payload ref.
    hasCustomPayload: bool
    /// Nanotons forwarded to the new editor notification.
    forwardTonAmount: coins
    /// Raw `Either Cell ^Cell` forward payload tail copied to `editorship_assigned`.
    forwardPayload: RemainingBitsAndRefs
}

/// Editor-originated request to replace the stored content cell.
struct (0x1a0b9d51) SbtV1SingleEditContent {
    /// Caller-selected query id parsed before the content ref.
    queryId: uint64
    /// Replacement individual SBT content cell.
    content: cell
}

/// Owner-only request to destroy the SBT by clearing owner and authority addresses.
struct (0x1f04537a) SbtV1SingleDestroy {
    /// Caller-selected query id copied into the outgoing `excesses` response.
    queryId: uint64
}

/// Authority-only request to revoke the SBT by setting `revokedAt` to `now()`.
struct (0x6f89f5e3) SbtV1SingleRevoke {
    /// Caller-selected query id parsed by the source before revocation checks.
    queryId: uint64
}

/// Owner-only request to reserve storage funds and return excess balance.
struct (0xd136d3b3) SbtV1SingleTakeExcess {
    /// Caller-selected query id copied into the outgoing `excesses` response.
    queryId: uint64
}

/// Static-data response sent to the requester.
struct (0x8b771735) SbtV1SingleReportStaticData {
    /// Query id copied from `get_static_data`.
    queryId: uint64
    /// Single SBT item id, always zero in this source.
    itemIndex: uint256
    /// Collection address, emitted as `addr_none` by this source.
    collectionAddress: address?
}

/// Owner-information response emitted for open `request_owner` calls.
struct (0x0dd607e3) SbtV1SingleOwnerInfo {
    /// Query id copied from `request_owner`.
    queryId: uint64
    /// Single SBT item id, always zero in this source.
    itemId: uint256
    /// Address that initiated the `request_owner` call.
    initiatorAddress: address
    /// Current owner address, or `addr_none` after `destroy`.
    ownerAddress: address?
    /// Referenced payload copied from `request_owner`.
    data: cell
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
    /// Optional content ref included only when `withContent` was true.
    content: cell?
}

/// Ownership proof response emitted for owner-only `prove_ownership` calls.
struct (0x0524c7ae) SbtV1SingleOwnershipProof {
    /// Query id copied from `prove_ownership`.
    queryId: uint64
    /// Single SBT item id, always zero in this source.
    itemId: uint256
    /// Current owner address that authorized the proof.
    ownerAddress: address
    /// Referenced payload copied from `prove_ownership`.
    data: cell
    /// Unix timestamp of revocation, or zero when the SBT is not revoked.
    revokedAt: uint64
    /// Optional content ref included only when `withContent` was true.
    content: cell?
}

/// Bounce-routed ownership proof failure notification sent back to the owner.
struct (0xc18e86d2) SbtV1SingleOwnershipProofBounced {
    /// Query id copied from the bounced `ownership_proof` body.
    queryId: uint64
}

/// Excess-value response emitted after destroy, take-excess, or editorship transfer requests.
struct (0xd53276db) SbtV1SingleExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Editorship assignment notification sent to the new editor.
struct (0x511a4463) SbtV1SingleEditorshipAssigned {
    /// Query id copied from the editorship transfer request.
    queryId: uint64
    /// Previous editor address.
    previousEditorAddress: address
    /// Raw forwarded payload copied from the editorship transfer request.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the single SBT variant.
type SbtV1SingleIncomingMessage =
    | SbtV1SingleTransfer
    | SbtV1SingleGetStaticData
    | SbtV1SingleRequestOwner
    | SbtV1SingleProveOwnership
    | SbtV1SingleTransferEditorship
    | SbtV1SingleEditContent
    | SbtV1SingleDestroy
    | SbtV1SingleRevoke
    | SbtV1SingleTakeExcess

/// Internal message bodies emitted by the single SBT variant.
type SbtV1SingleOutgoingMessage =
    | SbtV1SingleReportStaticData
    | SbtV1SingleOwnerInfo
    | SbtV1SingleOwnershipProof
    | SbtV1SingleOwnershipProofBounced
    | SbtV1SingleExcesses
    | SbtV1SingleEditorshipAssigned

/// Structured result returned by `get_nft_data`.
struct SbtV1SingleDataReply {
    /// Always true for the single variant because storage has no deployment split.
    isInitialized: bool
    /// Single SBT item index, always zero in this source.
    itemIndex: int
    /// Collection stack `MsgAddress`, returned as `addr_none` because single SBTs are collectionless.
    collectionAddress: any_address
    /// Current owner address, or null after `destroy`.
    ownerAddress: address?
    /// Referenced individual content cell.
    content: cell
}

/// Single SBT exit-code catalog from Getgems FunC source.
enum SbtV1SingleErrors {
    /// New editor address is outside the configured base workchain.
    InvalidWorkchain = 333
    /// Sender is not authorized for owner-only, authority-only, or editor-only operations.
    UnauthorizedOwnerAuthorityOrEditor = 401
    /// Remaining balance after storage, forward amount, and fees would be negative.
    InsufficientRestAmount = 402
    /// Revoke was requested after the SBT had already been revoked.
    AlreadyRevoked = 403
    /// Content update sender is not the current editor.
    UnauthorizedEditContent = 410
    /// TEP-62 transfer is intentionally rejected for SBT.
    TransferRejected = 413
    /// Incoming internal message opcode is not supported by the initialized item.
    UnsupportedOperation = 65535
}

/// Return item initialization flag, zero index, null collection, owner, and content.
get fun get_nft_data(): SbtV1SingleDataReply {
    throw 0;
}

/// Return the current editor address.
get fun get_editor(): address {
    throw 0;
}

/// Return the authority stack `MsgAddress`, or `addr_none` when no authority exists.
get fun get_authority_address(): any_address {
    throw 0;
}

/// Return the unix timestamp of revocation, or zero when the SBT is not revoked.
get fun get_revoked_time(): uint64 {
    throw 0;
}
