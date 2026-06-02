/// Wallet V5 R1 interface with storage, signed requests, extension requests, and get methods.
contract WalletV5r1 {
    author: "TON Core"
    version: "5.1"
    description: "Curated Wallet V5 R1 interface"
    storage: WalletV5r1Storage
    incomingMessages: WalletV5r1IncomingMessage
    incomingExternal: WalletV5r1IncomingExternalMessage
    forceAbiExport: WalletV5r1ExtraAction
}

/// Persistent Wallet V5 R1 state.
struct WalletV5r1Storage {
    /// Whether public-key signature authentication is currently allowed.
    isSignatureAllowed: bool
    /// Replay-protection sequence number.
    seqno: uint32
    /// Wallet id, equivalent to subwallet id in earlier wallet versions.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify signed requests.
    publicKey: uint256
    /// Extension address-hash dictionary; keys are 256-bit address hashes in the wallet workchain.
    extensions: map<uint256, bool>
}

/// Extended action that installs an extension address.
struct (0x02) WalletV5r1AddExtensionAction {
    /// Internal address of the extension to add.
    addr: address
}

/// Extended action that removes an installed extension address.
struct (0x03) WalletV5r1RemoveExtensionAction {
    /// Internal address of the extension to remove.
    addr: address
}

/// Extended action that toggles public-key signature authentication.
struct (0x04) WalletV5r1SetSignatureAllowedAction {
    /// New signature-authentication mode.
    allowSignature: bool
}

/// Wallet V5 extended-action union.
type WalletV5r1ExtraAction =
    | WalletV5r1AddExtensionAction
    | WalletV5r1RemoveExtensionAction
    | WalletV5r1SetSignatureAllowedAction

/// Internal signed request body, authenticated by Ed25519 signature.
struct (0x73696e74) WalletSignedInternalV5r1 {
    /// Wallet id expected to match storage.subwalletId.
    walletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw optional C5 out-action list cell.
    outActions: cell?
    /// Raw optional Wallet V5 extended-action list.
    extendedActions: cell?
    /// Ed25519 signature over the signed payload.
    signature: bits512
}

/// Internal extension request body, authenticated by the sender being installed.
struct (0x6578746e) WalletExtensionActionV5r1 {
    /// Caller-selected query id for extension-originated requests.
    queryId: uint64
    /// Raw optional C5 out-action list cell.
    outActions: cell?
    /// Raw optional Wallet V5 extended-action list.
    extendedActions: cell?
}

/// External signed request body, authenticated by Ed25519 signature.
struct (0x7369676e) WalletSignedExternalV5r1 {
    /// Wallet id expected to match storage.subwalletId.
    walletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw optional C5 out-action list cell.
    outActions: cell?
    /// Raw optional Wallet V5 extended-action list.
    extendedActions: cell?
    /// Ed25519 signature over the signed payload.
    signature: bits512
}

/// Internal message bodies accepted by Wallet V5 R1.
type WalletV5r1IncomingMessage =
    | WalletSignedInternalV5r1
    | WalletExtensionActionV5r1

/// External-in message bodies accepted by Wallet V5 R1.
type WalletV5r1IncomingExternalMessage = WalletSignedExternalV5r1

/// Wallet V5 R1 exit-code catalog from the source implementation.
enum Errors {
    /// Signature-authenticated requests are disabled.
    SignatureDisabled = 132
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 133
    /// Request wallet id does not match storage.subwalletId.
    InvalidWalletId = 134
    /// Ed25519 signature verification failed.
    InvalidSignature = 135
    /// Request validUntil is not greater than the current block time.
    Expired = 136
    /// External request contains a send action without IGNORE_ERRORS send mode.
    ExternalSendMessageMustHaveIgnoreErrorsSendMode = 137
    /// Message opcode is not accepted in the current entrypoint.
    InvalidMessageOperation = 138
    /// Add-extension action failed, usually because the extension already exists.
    AddExtension = 139
    /// Remove-extension action failed, usually because the extension does not exist.
    RemoveExtension = 140
    /// Extended action opcode is unsupported.
    UnsupportedAction = 141
    /// Signature auth cannot be disabled while the extension dictionary is empty.
    DisableSignatureWhenExtensionsIsEmpty = 142
    /// Requested signature-auth mode is already active.
    ThisSignatureModeAlreadySet = 143
    /// The last extension cannot be removed while signature auth is disabled.
    RemoveLastExtensionWhenSignatureDisabled = 144
    /// Extension address workchain differs from the wallet workchain.
    ExtensionWrongWorkchain = 145
    /// Only an installed extension can change signature-auth mode.
    OnlyExtensionCanChangeSignatureMode = 146
    /// C5 out-action list validation failed.
    InvalidC5 = 147
}

/// Return the current replay-protection sequence number.
get fun seqno(): int {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw Errors.SignatureDisabled;
    assert (true) throw Errors.InvalidSeqno;
    assert (true) throw Errors.InvalidWalletId;
    assert (true) throw Errors.InvalidSignature;
    assert (true) throw Errors.Expired;
    assert (true) throw Errors.ExternalSendMessageMustHaveIgnoreErrorsSendMode;
    assert (true) throw Errors.InvalidMessageOperation;
    assert (true) throw Errors.AddExtension;
    assert (true) throw Errors.RemoveExtension;
    assert (true) throw Errors.UnsupportedAction;
    assert (true) throw Errors.DisableSignatureWhenExtensionsIsEmpty;
    assert (true) throw Errors.ThisSignatureModeAlreadySet;
    assert (true) throw Errors.RemoveLastExtensionWhenSignatureDisabled;
    assert (true) throw Errors.ExtensionWrongWorkchain;
    assert (true) throw Errors.OnlyExtensionCanChangeSignatureMode;
    assert (true) throw Errors.InvalidC5;
    return 0;
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    return 0;
}

/// Return the wallet id, equivalent to subwallet id.
get fun get_subwallet_id(): int {
    return 0;
}

/// Return the raw extension dictionary keyed by extension address hash.
get fun get_extensions(): map<uint256, bool> {
    return [];
}

/// Return whether public-key signature authentication is currently allowed.
get fun is_signature_allowed(): bool {
    return false;
}
