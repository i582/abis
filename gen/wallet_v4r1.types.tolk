// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 64dd54805522c5be8a9db59cea0105ccf0d08786ca79beb8cb79e880a8d7322d

contract WalletV4r1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingMessages: WalletV4r1IncomingMessage
    incomingExternal: WalletV4r1IncomingExternalMessage
    outgoingMessages: WalletV4r1OutgoingMessage
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
type WalletV4r1IncomingMessage =
    | WalletPluginDestruct
    | PaymentRequest

type WalletV4r1IncomingExternalMessage = WalletSignedV4

type WalletV4r1OutgoingMessage =
    | WalletPluginInstallationNotification
    | WalletPluginDestruct
    | WalletPluginDestructResponse
    | PaymentConfirmed

struct GetPluginListPlugins {
    workchain: int32
    address: uint256
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
