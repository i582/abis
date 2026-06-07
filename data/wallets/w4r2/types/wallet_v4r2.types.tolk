/// Wallet V4 R2 interface with persistent storage, plugin messages, signed external requests, get methods, and exit codes.
contract WalletV4r2 {
    author: "TON Core"
    version: "4.2"
    description: "Curated Wallet V4 R2 interface"
    storage: WalletV4r2Storage
    incomingMessages: WalletV4r2IncomingMessage
    incomingExternal: WalletV4r2IncomingExternalMessage
    outgoingMessages: WalletV4r2OutgoingMessage
    forceAbiExport: WalletV4r2Payload
    thrownErrors: Errors
}

/// Persistent Wallet V4 R2 state.
struct WalletV4r2Storage {
    /// Replay-protection sequence number.
    seqno: uint32
    /// Wallet id, also called subwallet id in SDKs and get methods.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify signed external requests.
    publicKey: uint256
    /// Installed plugin set keyed by `int8 workchain + uint256 address_hash`; dictionary values are empty.
    plugins: map<bits264, void>
}

/// Standard TON currency collection used by plugin fund requests.
struct WalletV4r2CurrencyCollection {
    /// Toncoin amount in nanotons.
    grams: coins
    /// Extra-currency amounts keyed by 32-bit currency id.
    other: ExtraCurrenciesMap
}

/// Signed external operation that sends up to four caller-provided messages.
struct (0x00) WalletV4r2SimpleSend {
    /// Raw trailing stream of `mode:uint8` plus `^MessageRelaxed` pairs.
    messages: RemainingBitsAndRefs
}

/// Signed external operation that deploys a plugin and installs its address hash.
struct (0x01) WalletV4r2DeployAndInstallPlugin {
    /// Workchain where the plugin address is calculated.
    pluginWorkchain: int8
    /// Toncoin amount sent to the plugin deployment message.
    pluginBalance: coins
    /// Plugin StateInit cell used to derive the plugin address.
    stateInit: Cell<StateInit>
    /// Initial internal message body sent to the deployed plugin.
    body: cell
}

/// Signed external operation that installs an already deployed plugin.
struct (0x02) WalletV4r2InstallPlugin {
    /// Plugin workchain stored as the first 8 bits of the plugin dictionary key.
    pluginWorkchain: int8
    /// Plugin address hash stored after the workchain in the plugin dictionary key.
    pluginAddress: bits256
    /// Toncoin amount sent to the plugin notification message.
    amount: coins
    /// Caller-selected query id included in the plugin notification.
    queryId: uint64
}

/// Signed external operation that removes an installed plugin.
struct (0x03) WalletV4r2RemovePlugin {
    /// Plugin workchain stored as the first 8 bits of the plugin dictionary key.
    pluginWorkchain: int8
    /// Plugin address hash stored after the workchain in the plugin dictionary key.
    pluginAddress: bits256
    /// Toncoin amount sent to the plugin destruct message.
    amount: coins
    /// Caller-selected query id included in the plugin destruct message.
    queryId: uint64
}

/// Wallet V4 R2 signed external operation payload.
type WalletV4r2Payload =
    | WalletV4r2SimpleSend
    | WalletV4r2DeployAndInstallPlugin
    | WalletV4r2InstallPlugin
    | WalletV4r2RemovePlugin

/// Internal message by which an installed plugin requests wallet-side removal.
struct (0x64737472) WalletV4r2PluginDestruct {
    /// Plugin-selected query id echoed in the optional response.
    queryId: uint64
}

/// Internal message by which an installed plugin requests funds.
struct (0x706c7567) WalletV4r2PaymentRequest {
    /// Plugin-selected query id echoed in the payment confirmation.
    queryId: uint64
    /// Toncoin and extra-currency amount requested by the plugin.
    amount: WalletV4r2CurrencyCollection
}

/// External-in request authenticated by Ed25519 signature over the unsigned trailing payload.
struct WalletV4r2SignedExternal {
    /// Ed25519 signature over subwalletId, validUntil, seqno, and payload.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Wallet V4 operation selected by the 8-bit operation code.
    payload: WalletV4r2Payload
}

/// Outgoing notification sent after installing an existing plugin.
struct (0x6e6f7465) WalletV4r2PluginInstallationNotification {
    /// Query id supplied by the install operation.
    queryId: uint64
}

/// Outgoing response sent after plugin-requested removal when bounce is expected.
struct (0xe4737472) WalletV4r2PluginDestructResponse {
    /// Query id supplied by the plugin destruct request.
    queryId: uint64
}

/// Outgoing confirmation sent to a plugin after a successful payment request.
struct (0xf06c7567) WalletV4r2PaymentConfirmed {
    /// Query id supplied by the plugin payment request.
    queryId: uint64
}

/// Internal message bodies accepted by Wallet V4 R2.
type WalletV4r2IncomingMessage =
    | WalletV4r2PluginDestruct
    | WalletV4r2PaymentRequest

/// External-in message body accepted by Wallet V4 R2.
type WalletV4r2IncomingExternalMessage = WalletV4r2SignedExternal

/// Outgoing plugin message bodies emitted by Wallet V4 R2.
type WalletV4r2OutgoingMessage =
    | WalletV4r2PluginInstallationNotification
    | WalletV4r2PluginDestruct
    | WalletV4r2PluginDestructResponse
    | WalletV4r2PaymentConfirmed

/// Single plugin entry returned by get_plugin_list.
struct WalletV4r2PluginListEntry {
    /// Plugin workchain id.
    workchain: int32
    /// Plugin address hash.
    address: uint256
}

/// Wallet V4 R2 exit-code catalog from schemas and source/docs.
enum Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Ed25519 signature verification failed.
    InvalidSignature = 35
    /// Request validUntil is not greater than the current block time.
    ExpiredMessage = 36
    /// Plugin dictionary add/delete failed.
    PluginNotFound = 39
    /// Wallet balance is insufficient for a plugin payment request.
    NotEnoughTon = 80
}

/// Return the installed plugin list as `(workchain, address_hash)` pairs.
get fun get_plugin_list(): lisp_list<WalletV4r2PluginListEntry> {
    throw 0;
}

/// Return whether a plugin key is installed.
get fun is_plugin_installed(workchain: int32, addrHash: int): bool {
    throw 0;
}

/// Return the stored Ed25519 public key.
get fun get_public_key(): int {
    throw 0;
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}

/// Return the wallet id, equivalent to subwallet id.
get fun get_subwallet_id(): uint32 {
    throw 0;
}
