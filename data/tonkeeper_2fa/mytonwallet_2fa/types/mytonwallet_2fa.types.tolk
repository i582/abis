/// MyTonWallet Telegram 2FA extension interface for Wallet V5.
contract MyTonWallet2fa {
    author: "MyTonWallet"
    version: "1.0"
    description: "MyTonWallet Telegram 2FA extension that authorizes Wallet V5 actions with seed and Telegram signatures and supports delayed recovery."
    storage: MyTonWallet2faStorage
    incomingMessages: MyTonWallet2faIncomingMessage
    incomingExternal: MyTonWallet2faIncomingExternalMessage
    outgoingMessages: MyTonWallet2faOutgoingMessage
    forceAbiExport: MyTonWallet2faEmptyRefill
        | MyTonWallet2faSeedSignature
        | MyTonWallet2faSendActionsPayload
        | MyTonWallet2faWalletOutActionSendMsg
        | MyTonWallet2faWalletSetSignatureAuthAction
        | MyTonWallet2faWalletDeleteExtensionAction
    thrownErrors: Errors
}

/// Persistent state shared by deployment and active instances.
struct MyTonWallet2faStorage {
    /// Replay-protection sequence number incremented after accepted requests.
    seqno: uint32
    /// Wallet V5 account controlled through this extension.
    wallet: address
    /// Telegram user id encoded as an ASCII decimal string in a referenced cell.
    telegramId: Cell<MyTonWallet2faTelegramId>
    /// Ed25519 public key used to authenticate seed-signed requests.
    seedPubkey: uint256
    /// Whether the delayed recovery flow has been started.
    recoveryStarted: bool
    /// Recovery deadline or retry-block timestamp, depending on recovery state.
    blockedUntil: uint64
}

/// Raw ASCII decimal Telegram user id stored in a referenced cell.
type MyTonWallet2faTelegramId = RemainingBitsAndRefs

/// Raw ASCII decimal Telegram authentication timestamp stored in a referenced cell.
type MyTonWallet2faAuthDate = RemainingBitsAndRefs

/// Referenced Ed25519 signature produced by the stored seed key.
struct MyTonWallet2faSeedSignature {
    /// Seed signature over the opcode, seqno, and payload reference.
    signature: bits512
}

/// Referenced payload for a signed `send_actions` request.
struct MyTonWallet2faSendActionsPayload {
    /// Raw TVM send mode passed to `send_raw_message`.
    mode: uint8
    /// Complete internal message forwarded unchanged by the extension.
    message: cell
}

/// Empty referenced payload required by a signed removal request.
struct MyTonWallet2faEmptyPayload {}

/// Signed request that forwards one arbitrary internal message.
struct (0xb15f2c8c) MyTonWallet2faSendActions {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Referenced send mode and complete message cell.
    payload: Cell<MyTonWallet2faSendActionsPayload>
}

/// Signed request that asks Wallet V5 to remove this extension.
struct (0xaeb09887) MyTonWallet2faRemoveExtension {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Required empty payload reference.
    payload: Cell<MyTonWallet2faEmptyPayload>
}

/// Operations authenticated by both seed and Telegram signatures.
type MyTonWallet2faSignedPayload =
    | MyTonWallet2faSendActions
    | MyTonWallet2faRemoveExtension

/// External request authenticated by the seed key and Telegram bot key.
struct MyTonWallet2faSignedExternal {
    /// Referenced signature produced by the stored seed key.
    seedSignature: Cell<MyTonWallet2faSeedSignature>
    /// Telegram authentication timestamp encoded as an ASCII decimal string.
    authDate: Cell<MyTonWallet2faAuthDate>
    /// Tagged request opcode, seqno, and referenced operation payload.
    payload: MyTonWallet2faSignedPayload
    /// Telegram bot signature over the WebAppData verification message.
    telegramSignature: bits512
}

/// Seed-signed request that starts or completes delayed recovery.
struct (0x8d9e73f8) MyTonWallet2faRecovery {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp before which the request remains valid.
    validUntil: uint32
}

/// Seed-signed request that cancels delayed recovery.
struct (0x0d9cef94) MyTonWallet2faCancelRecovery {
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Unix timestamp before which the request remains valid.
    validUntil: uint32
}

/// Recovery operations authenticated by the stored seed key.
type MyTonWallet2faSeedPayload =
    | MyTonWallet2faRecovery
    | MyTonWallet2faCancelRecovery

/// External recovery request authenticated by the stored seed key.
struct MyTonWallet2faSeedExternal {
    /// Tagged recovery opcode, seqno, and validity timestamp.
    payload: MyTonWallet2faSeedPayload
    /// Seed signature over the tagged recovery payload.
    signature: bits512
}

/// Install request sent by the configured Wallet V5 account.
struct (0x43563174) MyTonWallet2faInstall {}

/// Internal wrapper for a Telegram-and-seed-signed `send_actions` request.
struct (0x53684037) MyTonWallet2faInternalSigned {
    /// Referenced signature produced by the stored seed key.
    seedSignature: Cell<MyTonWallet2faSeedSignature>
    /// Telegram authentication timestamp encoded as an ASCII decimal string.
    authDate: Cell<MyTonWallet2faAuthDate>
    /// Signed operation; internal requests accept only `send_actions`.
    payload: MyTonWallet2faSignedPayload
    /// Telegram bot signature over the WebAppData verification message.
    telegramSignature: bits512
}

/// Confirmation sent by Wallet V5 after deleting this extension.
struct (0xc2d7f22b) MyTonWallet2faConfirmRemoval {}

/// Empty internal message body accepted as a balance refill.
struct MyTonWallet2faEmptyRefill {}

/// Wallet V5 extension-action request emitted during install or removal.
struct (0x6578746e) MyTonWallet2faWalletRequestByExtension {
    /// Query id; this extension always emits zero.
    queryId: uint64
    /// Optional raw Wallet V5 linked out-action list.
    outActions: cell?
    /// Raw Wallet V5 extended-action tail.
    extendedActions: RemainingBitsAndRefs
}

/// Wallet V5 send-message action stored in a linked out-action cell.
struct MyTonWallet2faWalletOutActionSendMsg {
    /// Previous linked action cell, empty for the first action.
    previous: cell
    /// Wallet out-action tag for `send_msg`.
    action: uint32
    /// Send mode applied to the nested message.
    mode: uint8
    /// Nested message sent by Wallet V5.
    message: cell
}

/// Wallet V5 extended action that enables or disables signature authentication.
struct MyTonWallet2faWalletSetSignatureAuthAction {
    /// Wallet extended-action tag for signature-auth mode.
    action: uint8
    /// New signature-authentication mode.
    allow: bool
    /// Optional continuation action cell.
    next: cell?
}

/// Wallet V5 extended action that deletes an installed extension.
struct MyTonWallet2faWalletDeleteExtensionAction {
    /// Wallet extended-action tag for deleting an extension.
    action: uint8
    /// Extension address to remove.
    extension: address
    /// Optional continuation action cell.
    next: cell?
}

/// Internal message bodies accepted by the extension.
type MyTonWallet2faIncomingMessage =
    | MyTonWallet2faInstall
    | MyTonWallet2faInternalSigned
    | MyTonWallet2faConfirmRemoval

/// External message bodies accepted by the extension.
type MyTonWallet2faIncomingExternalMessage =
    | MyTonWallet2faSignedExternal
    | MyTonWallet2faSeedExternal

/// Structured Wallet V5 request bodies emitted directly by the extension.
type MyTonWallet2faOutgoingMessage = MyTonWallet2faWalletRequestByExtension

/// Return value of the delayed-recovery getter.
struct MyTonWallet2faRecoveryStateReply {
    /// True after recovery has started and before it is cancelled or completed.
    recoveryStarted: bool
    /// Recovery deadline or retry-block timestamp.
    blockedUntil: uint64
}

/// MyTonWallet Telegram 2FA exit-code catalog.
enum Errors {
    /// Install was attempted after seqno became nonzero.
    ExtensionAlreadyInstalled = 700
    /// Install or removal confirmation sender is not the configured wallet.
    SenderIsNotOwner = 701
    /// Seed or Telegram signature verification failed.
    WrongSignature = 702
    /// Request seqno does not match storage.seqno.
    WrongSeqno = 703
    /// Seed request validity or Telegram authentication timestamp expired.
    Expired = 704
    /// Operation conflicts with the current recovery state.
    RecoveryInProgress = 705
    /// Recovery deadline or retry timeout has not elapsed.
    ActionTimeout = 710
    /// Internal signed requests only support `send_actions`.
    OnlySendActionsSupported = 711
    /// The body opcode is not accepted by this entrypoint.
    UnsupportedOperation = 65535
}

/// Return delayed-recovery state and its controlling timestamp.
get fun get_recovery_state(): MyTonWallet2faRecoveryStateReply {
    throw 0;
}

/// Return the current replay-protection sequence number.
get fun get_seqno(): uint32 {
    throw 0;
}

/// Return the Telegram user id parsed from its stored decimal string.
get fun get_telegram_id(): int {
    throw 0;
}
