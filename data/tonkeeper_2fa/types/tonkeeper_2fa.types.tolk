/// Tonkeeper 2FA extension interface with signed request bodies, wallet-extension requests, storage, getters, and exit codes.
contract Tonkeeper2fa {
    author: "Tonkeeper"
    version: "1.0"
    description: "Curated Tonkeeper 2FA extension interface"
    storage: Tonkeeper2faStorage
    storageAtDeployment: Tonkeeper2faDeploymentStorage
    incomingMessages: Tonkeeper2faIncomingMessage
    incomingExternal: Tonkeeper2faIncomingExternalMessage
    outgoingMessages: Tonkeeper2faOutgoingMessage
    forceAbiExport: Tonkeeper2faDelegationStateNone
        | Tonkeeper2faDelegationStateActive
        | Tonkeeper2faEmptyRefill
        | Tonkeeper2faWalletOutActionSendMsg
        | Tonkeeper2faWalletSetSignatureAuthAction
        | Tonkeeper2faWalletAddExtensionAction
        | Tonkeeper2faWalletDeleteExtensionAction
    thrownErrors: Tonkeeper2faErrors
}

/// Pre-install data cell used when the extension address is derived and deployed.
struct Tonkeeper2faDeploymentStorage {
    /// Replay-protection sequence number, zero before install.
    seqno: uint32
    /// Wallet address that must send the install message.
    wallet: address
    /// Root CA Ed25519 public key slot, zero before install.
    rootCaPubkey: uint256
    /// Seed Ed25519 public key slot, zero before install.
    seedPubkey: uint256
    /// Delegation flag slot, false before install.
    delegationStarted: bool
    /// Reserved zero bit present in the deploy helper's initial data.
    deploymentReservedBit: bool
    /// Recovery retry timestamp slot, zero before install.
    recoveryBlockedUntil: uint64
}

/// Runtime data cell after install.
struct Tonkeeper2faStorage {
    /// Replay-protection sequence number incremented after accepted signed requests.
    seqno: uint32
    /// Wallet controlled by this extension.
    wallet: address
    /// Root CA Ed25519 public key used to authenticate certificates.
    rootCaPubkey: uint256
    /// Seed Ed25519 public key used to authenticate seed-signed requests.
    seedPubkey: uint256
    /// Whether delegation recovery state is active.
    delegationStarted: bool
    /// If inactive: `recoveryBlockedUntil:uint64`; if active: that timestamp plus `^StateInit` and `Coins`.
    delegationState: RemainingBitsAndRefs
}

/// Runtime delegation tail when no delegation is active.
struct Tonkeeper2faDelegationStateNone {
    /// Unix timestamp before which a new delegation request is blocked.
    recoveryBlockedUntil: uint64
}

/// Runtime delegation tail while recovery delegation is active.
struct Tonkeeper2faDelegationStateActive {
    /// Unix timestamp after which the second delegation request may complete recovery.
    recoveryBlockedUntil: uint64
    /// StateInit for the replacement extension.
    newStateInit: Cell<StateInit>
    /// Nanotons forwarded to the replacement extension deployment.
    forwardAmount: coins
}

/// Empty internal body accepted as a balance refill.
struct Tonkeeper2faEmptyRefill {}

/// Tonkeeper certificate payload signed by the root CA key.
struct Tonkeeper2faCertificate {
    /// Certificate expiry timestamp.
    validUntil: uint64
    /// Certificate Ed25519 public key.
    pubkey: uint256
    /// Root CA signature over the certificate data.
    signature: bits512
}

/// Referenced seed signature used by 2FA-signed requests.
struct Tonkeeper2faRefWithSeedSignature {
    /// Seed signature over the signed request payload.
    seedSignature: bits512
}

/// 2FA-signed `send_actions` payload.
struct (0xb15f2c8c) Tonkeeper2faSendActions {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp after which the request expires.
    validUntil: uint64
    /// Raw message cell forwarded unchanged through `send_raw_message`.
    msg: cell
    /// Raw send mode passed to `send_raw_message`.
    mode: uint8
}

/// 2FA-signed request that asks the wallet to remove this extension.
struct (0x9d8084d6) Tonkeeper2faRemoveExtension {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp after which the request expires.
    validUntil: uint64
}

/// Seed-signed request that starts or completes recovery delegation.
struct (0x23d9c15c) Tonkeeper2faDelegation {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp after which the request expires.
    validUntil: uint64
    /// StateInit for the replacement extension.
    newStateInit: Cell<StateInit>
    /// Nanotons forwarded to the replacement extension deployment.
    forwardAmount: coins
}

/// Seed-signed request that cancels an active delegation.
struct (0xde82b501) Tonkeeper2faCancelDelegation {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp after which the request expires.
    validUntil: uint64
}

/// Payload variants that require both seed and certificate signatures.
type Tonkeeper2faSigned2faPayload =
    | Tonkeeper2faSendActions
    | Tonkeeper2faRemoveExtension

/// Payload variants that require only a seed signature.
type Tonkeeper2faSeedPayload =
    | Tonkeeper2faDelegation
    | Tonkeeper2faCancelDelegation

/// External-in request authenticated by both the seed key and a Tonkeeper certificate.
struct Tonkeeper2faSigned2faExternal {
    /// Referenced Tonkeeper certificate.
    certificate: Cell<Tonkeeper2faCertificate>
    /// Referenced seed signature.
    seedSignature: Cell<Tonkeeper2faRefWithSeedSignature>
    /// Signed operation payload.
    payload: Tonkeeper2faSigned2faPayload
    /// Certificate-key signature over the signed request payload.
    certificateSignature: bits512
}

/// External-in request authenticated only by the seed key.
struct Tonkeeper2faSignedSeedExternal {
    /// Signed recovery payload.
    payload: Tonkeeper2faSeedPayload
    /// Seed signature over the signed request payload.
    seedSignature: bits512
}

/// Install request sent by the wallet that owns the extension.
struct (0x43563174) Tonkeeper2faInstall {
    /// Root CA Ed25519 public key to store.
    rootCaPubkey: uint256
    /// Seed Ed25519 public key to store.
    seedPubkey: uint256
}

/// Internal wrapper for a 2FA-signed request.
struct (0x53684037) Tonkeeper2faInternalSigned {
    /// Referenced Tonkeeper certificate.
    certificate: Cell<Tonkeeper2faCertificate>
    /// Referenced seed signature.
    seedSignature: Cell<Tonkeeper2faRefWithSeedSignature>
    /// Signed operation payload.
    payload: Tonkeeper2faSigned2faPayload
    /// Certificate-key signature over the signed request payload.
    certificateSignature: bits512
}

/// Confirmation body sent back after the wallet removes this extension.
struct (0xc2d7f22b) Tonkeeper2faConfirmRemoval {}

/// Wallet V5 extension request body emitted to the controlled wallet.
struct (0x6578746e) Tonkeeper2faWalletRequestByExtension {
    /// Query id; the extension emits zero.
    queryId: uint64
    /// Optional raw Wallet V5 out-action list.
    outActions: cell?
    /// Raw Wallet V5 extended-action tail after the out-action list.
    extendedActions: RemainingBitsAndRefs
}

/// Wallet V5 send-message action cell used inside the raw out-action list.
struct Tonkeeper2faWalletOutActionSendMsg {
    /// Previous linked action cell, empty at the start of the list.
    previous: cell
    /// Wallet out-action tag for `send_msg`.
    action: uint32
    /// Send mode for the nested message.
    mode: uint8
    /// Raw nested outbound message cell.
    message: cell
}

/// Wallet V5 extended action that toggles public-key signature authentication.
struct Tonkeeper2faWalletSetSignatureAuthAction {
    /// Wallet extended-action tag for signature-auth mode.
    action: uint8
    /// New signature-authentication mode.
    allow: bool
    /// Optional continuation action cell.
    next: cell?
}

/// Wallet V5 extended action that adds a replacement extension.
struct Tonkeeper2faWalletAddExtensionAction {
    /// Wallet extended-action tag for adding an extension.
    action: uint8
    /// Replacement extension address.
    extension: address
    /// Continuation action cell.
    next: cell
}

/// Wallet V5 extended action that deletes an extension.
struct Tonkeeper2faWalletDeleteExtensionAction {
    /// Wallet extended-action tag for deleting an extension.
    action: uint8
    /// Extension address to remove.
    extension: address
    /// Optional continuation action cell.
    next: cell?
}

/// Internal message bodies accepted by the extension.
type Tonkeeper2faIncomingMessage =
    | Tonkeeper2faInstall
    | Tonkeeper2faInternalSigned
    | Tonkeeper2faConfirmRemoval

/// External-in message bodies accepted by the extension.
type Tonkeeper2faIncomingExternalMessage =
    | Tonkeeper2faSigned2faExternal
    | Tonkeeper2faSignedSeedExternal

/// Structured wallet request bodies emitted directly or forwarded by the extension.
type Tonkeeper2faOutgoingMessage = Tonkeeper2faWalletRequestByExtension

/// Getter return for delegation state; the third stack item is a raw TVM tuple.
struct Tonkeeper2faDelegationStateReply {
    /// True when delegation recovery has been initiated.
    delegationStarted: bool
    /// Unix timestamp controlling delegation retry or completion.
    recoveryBlockedUntil: uint64
    /// Empty tuple when inactive; otherwise `new_state_init` and `forward_amount`.
    stateParams: tuple
}

/// Tonkeeper 2FA exit-code catalog.
enum Tonkeeper2faErrors {
    /// Install was attempted after the extension had already been installed.
    ExtensionAlreadyInstalled = 160
    /// Internal sender is not the controlled wallet.
    SenderIsNotOwner = 161
    /// Certificate-key signature is invalid.
    WrongCertificateSignature = 162
    /// Root CA signature over the certificate is invalid.
    WrongRootCaSignature = 163
    /// Seed signature is invalid.
    WrongSeedSignature = 164
    /// Request seqno does not match storage.seqno.
    WrongSeqno = 165
    /// Certificate or request validity timestamp has expired.
    Expired = 166
    /// Operation is blocked while recovery delegation is active.
    RecoveryInProgress = 167
    /// Delegation retry or completion timeout has not elapsed.
    ActionTimeout = 170
    /// Second delegation request does not match the stored StateInit or amount.
    MismatchedData = 171
    /// Cancel was requested without active delegation.
    NoDelegationInitiated = 174
    /// Internal signed requests only support `send_actions`.
    OnlySendActionsSupported = 175
    /// The body opcode is not accepted by this entrypoint.
    UnsupportedOperation = 65535
}

/// Return the current replay-protection sequence number.
get fun get_seqno(): uint32 {
    throw 0;
}

/// Return the controlled wallet address.
get fun get_wallet_addr(): address {
    throw 0;
}

/// Return the stored root CA public key.
get fun get_root_pubkey(): uint256 {
    throw 0;
}

/// Return the stored seed public key.
get fun get_seed_pubkey(): uint256 {
    throw 0;
}

/// Return delegation state flag, timeout, and variant-specific raw tuple.
get fun get_delegation_state(): Tonkeeper2faDelegationStateReply {
    throw 0;
}

/// Estimate nanotons needed for a wallet request with the supplied forwarded message and action counts.
get fun get_estimated_attached_value(
    forwardMsg: cell,
    msgActions: int,
    extendedActions: int,
): coins {
    throw 0;
}
