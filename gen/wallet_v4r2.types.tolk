// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: feb5ff6820e2ff0d9483e7e0d62c817d846789fb4ae580c878866d959dabd5c0

contract WalletV4r2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingMessages: WalletV4r2IncomingMessage
    incomingExternal: WalletV4r2IncomingExternalMessage
    outgoingMessages: WalletV4r2OutgoingMessage
}

// TL-B helper types referenced by messages.
struct (0b00000000) SimpleSend {
    payload: cell
}

struct (0b00000001) DeployAndInstallPlugin {
    pluginWorkchain: int8
    pluginBalance: coins
    stateInit: Cell<StateInit>
    body: cell
}

struct (0b00000010) InstallPlugin {
    pluginWorkchain: int8
    pluginAddress: bits256
    amount: coins
    queryId: uint64
}

struct (0b00000011) RemovePlugin {
    pluginWorkchain: int8
    pluginAddress: bits256
    amount: coins
    queryId: uint64
}

type WalletV4Payload =
    | SimpleSend
    | DeployAndInstallPlugin
    | InstallPlugin
    | RemovePlugin

// TL-B message bodies.
struct (0x64737472) WalletPluginDestruct {
    queryId: uint64
}

struct (0x706c7567) PaymentRequest {
    queryId: uint64
    amount: (coins, ExtraCurrenciesMap)
}

struct WalletSignedV4 {
    signature: bits512
    subwalletId: uint32
    validUntil: uint32
    seqno: uint32
    payload: cell
}

struct (0x6e6f7465) WalletPluginInstallationNotification {
    queryId: uint64
}

struct (0xe4737472) WalletPluginDestructResponse {
    queryId: uint64
}

struct (0xf06c7567) PaymentConfirmed {
    queryId: uint64
}

// Message unions used by Acton ABI.
type WalletV4r2IncomingMessage =
    | WalletPluginDestruct
    | PaymentRequest

type WalletV4r2IncomingExternalMessage = WalletSignedV4

type WalletV4r2OutgoingMessage =
    | WalletPluginInstallationNotification
    | WalletPluginDestruct
    | WalletPluginDestructResponse
    | PaymentConfirmed

struct GetPluginListPlugins {
    workchain: int32
    address: uint256
}

enum Errors {
    InvalidSeqno = 33
    InvalidSubwalletId = 34
    InvalidSignature = 35
    ExpiredMessage = 36
    PluginNotFound = 39
    NotEnoughTon = 80
}

get fun get_plugin_list(): lisp_list<GetPluginListPlugins> {
    return [];
}

get fun is_plugin_installed(workchain: int32, addrHash: int): bool {
    return false;
}

get fun get_public_key(): int {
    return 0;
}

get fun seqno(): uint32 {
    return 0;
}

get fun get_subwallet_id(): uint32 {
    return 0;
}
