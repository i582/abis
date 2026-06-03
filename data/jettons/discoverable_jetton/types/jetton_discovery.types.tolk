/// Standalone TEP-89 wallet discovery helper for existing non-discoverable Jetton minters.
contract JettonDiscovery {
    author: "TON Core"
    version: "1.07"
    description: "Curated interface for token-contract v1.04+ jetton-discovery helper"
    storage: JettonDiscoveryStorage
    incomingMessages: JettonDiscoveryIncomingMessage
    outgoingMessages: JettonDiscoveryOutgoingMessage
}

/// Persistent discovery helper state stored in the root data cell.
struct JettonDiscoveryStorage {
    /// Jetton minter/master address used in deterministic wallet address derivation.
    jettonMinterAddress: address
    /// Referenced wallet code cell used in deterministic wallet address derivation.
    jettonWalletCode: cell
}

/// TEP-89 wallet discovery request accepted by the helper.
struct (0x2c76b973) ProvideWalletAddress {
    /// Caller-selected query id copied into the `TakeWalletAddress` response.
    queryId: uint64
    /// Owner address whose deterministic jetton wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// TEP-89 wallet discovery response emitted to the original requester.
struct (0xd1735400) TakeWalletAddress {
    /// Query id copied from the `ProvideWalletAddress` request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced cell containing the requested owner address when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the standalone discovery helper.
type JettonDiscoveryIncomingMessage = ProvideWalletAddress

/// Internal message bodies emitted by the standalone discovery helper.
type JettonDiscoveryOutgoingMessage = TakeWalletAddress

/// Standalone discovery helper exit-code catalog from token-contract source.
enum JettonDiscoveryErrors {
    /// `provide_wallet_address` message value cannot cover the response budget.
    InsufficientProvideWalletAddressValue = 75
    /// Incoming internal message opcode is not supported by the helper.
    UnsupportedOperation = 65535
}
