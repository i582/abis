/// STON.fi pTON v2.1 minter/master from ston-fi/pton-contracts.
contract PtonMinterV2 {
    author: "STON.fi"
    version: "2.1"
    description: "Curated pTON v2.1 minter ABI for TEP-161 proxy TON wallet deployment, Jetton discovery, and standard Jetton metadata getters"
    storage: PtonMinterV2Storage
    incomingMessages: PtonMinterV2IncomingMessage
    outgoingMessages: PtonMinterV2OutgoingMessage
    forceAbiExport: PtonMinterV2Errors
}

/// Persistent pTON minter state stored in the root data cell.
struct PtonMinterV2Storage {
    /// Source `id:uint32`; live pTON v2.1 mainnet minter stores `0`.
    id: uint32
    /// Referenced pTON wallet code cell used for deterministic owner wallet deployment.
    walletCode: cell
    /// Referenced Jetton metadata content cell.
    content: cell
}

/// User request to deploy the deterministic pTON wallet for an owner.
struct (0x4f5f4313) PtonMinterV2DeployWallet {
    /// Query id copied into the deployment flow.
    queryId: uint64
    /// Owner whose deterministic pTON wallet should be deployed.
    ownerAddress: address
    /// Address receiving excess TON after wallet deployment.
    excessesAddress: address
}

/// TEP-89 wallet discovery request accepted by the pTON minter.
struct (0x2c76b973) PtonMinterV2ProvideWalletAddress {
    /// Caller-selected query id copied into the response.
    queryId: uint64
    /// Owner address whose deterministic pTON wallet is requested.
    ownerAddress: address
    /// True when the response should include the queried owner address in a ref.
    includeAddress: bool
}

/// Minter-to-wallet deployment message emitted by `deploy_wallet`.
struct (0x6540cf85) PtonMinterV2InternalDeploy {
    /// Query id copied from the upstream deploy request.
    queryId: uint64
    /// Address receiving deployment excesses from the newly deployed wallet.
    excessesAddress: address
}

/// TEP-89 wallet discovery response emitted by the pTON minter.
struct (0xd1735400) PtonMinterV2TakeWalletAddress {
    /// Query id copied from the discovery request.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` if the owner address is outside workchain 0.
    walletAddress: address?
    /// Optional owner address ref included when requested.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the pTON minter.
type PtonMinterV2IncomingMessage =
    | PtonMinterV2DeployWallet
    | PtonMinterV2ProvideWalletAddress

/// Internal message bodies emitted by the pTON minter.
type PtonMinterV2OutgoingMessage =
    | PtonMinterV2InternalDeploy
    | PtonMinterV2TakeWalletAddress

/// Structured result returned by `get_jetton_data`.
struct PtonMinterV2JettonDataReply {
    /// Always zero in source because total tokenized TON is tracked by wallets.
    totalSupply: int
    /// Source returns true for Jetton compatibility.
    mintable: bool
    /// Source returns `addr_none`; pTON has no admin minter.
    adminAddress: any_address
    /// Jetton metadata content cell.
    jettonContent: cell
    /// pTON wallet code cell.
    jettonWalletCode: cell
}

/// Structured result returned by `get_version`.
struct PtonMinterV2VersionReply {
    /// Major source version.
    major: uint32
    /// Minor source version.
    minor: uint32
    /// Development tag, live mainnet returns `release`.
    development: string
}

/// pTON minter exit-code catalog from ston-fi/pton-contracts.
enum PtonMinterV2Errors {
    /// Incoming value is not enough to deploy a wallet and preserve storage reserves.
    InsufficientGas = 83
    /// Address is outside workchain 0 where the reference implementation operates.
    WrongWorkchain = 85
    /// Incoming opcode is unsupported.
    WrongOperation = 65535
}

/// Return zero supply, mintability, no admin, metadata, and wallet code.
get fun get_jetton_data(): PtonMinterV2JettonDataReply {
    assert (true) throw PtonMinterV2Errors.InsufficientGas;
    assert (true) throw PtonMinterV2Errors.WrongWorkchain;
    assert (true) throw PtonMinterV2Errors.WrongOperation;
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: createAddressNone(),
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic pTON wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return pTON source version.
get fun get_version(): PtonMinterV2VersionReply {
    return {
        major: 2,
        minor: 1,
        development: "release",
    };
}
