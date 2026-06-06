/// Storm Trade LP Jetton minter interface.
contract StormLpMinter {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade LP Jetton minter for LP supply, mint and burn notifications, wallet discovery, and public Jetton getters."
    storage: StormLpMinterStorage
    incomingMessages: StormLpMinterIncomingMessage
    outgoingMessages: StormLpMinterOutgoingMessage
}

/// Persistent LP minter state stored in the root data cell.
struct StormLpMinterStorage {
    /// Total LP Jetton supply encoded as TL-B `Coins`.
    totalSupply: coins
    /// Storm vault address authorized to mint and notified on LP burns.
    vaultAddress: address
    /// Referenced LP wallet code used to derive deterministic owner wallet addresses.
    lpWalletCode: cell
}

/// Vault mint request accepted only from the stored Storm vault address.
struct (0x1674b0a0) StormLpMintRequest {
    /// Query id copied into the outgoing wallet `internal_transfer`.
    queryId: uint64
    /// LP Jetton amount to add to total supply and transfer to the deterministic wallet.
    amount: coins
    /// Owner/response address used for wallet derivation and the outgoing transfer response address.
    ownerAddress: address
}

/// Burn notification accepted only from the deterministic wallet for `ownerAddress`.
struct (0x7bdd97de) StormLpBurnNotification {
    /// Query id carried by the wallet burn notification; the minter does not forward it to the vault.
    queryId: uint64
    /// LP Jetton amount to subtract from total supply and report to the vault.
    amount: coins
    /// Owner address whose deterministic LP wallet sent the burn notification.
    ownerAddress: address
}

/// TEP-89 wallet discovery request accepted by the LP minter.
struct (0x2c76b973) StormLpProvideWalletAddress {
    /// Caller-selected query id copied into the `take_wallet_address` response.
    queryId: uint64
    /// Owner address whose deterministic LP wallet is requested.
    ownerAddress: address
    /// True when the response should include the queried owner address in a ref.
    includeAddress: bool
}

/// Outgoing Jetton internal transfer emitted to a newly derived/deployed LP wallet after mint.
struct (0x178d4519) StormLpInternalTransfer {
    /// Query id copied from the vault mint request.
    queryId: uint64
    /// Minted LP Jetton amount transferred to the deterministic wallet.
    amount: coins
    /// Source owner encoded by the minter as `addr_none`.
    fromAddress: address?
    /// Response address copied from the mint request owner address.
    responseAddress: address
    /// Forward TON amount.
    forwardTonAmount: coins
    /// Raw forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Burn callback emitted to the Storm vault after a wallet burn notification.
struct (0xd5b5e9ad) StormLpVaultUnstake {
    /// Burned LP Jetton amount reported to the vault.
    jettonAmount: coins
    /// Owner address whose wallet burned LP Jettons.
    userAddress: address
}

/// TEP-89 wallet discovery response emitted by the LP minter.
struct (0xd1735400) StormLpTakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Calculated LP wallet address, or `addr_none` when owner workchain is unsupported.
    walletAddress: address?
    /// Optional referenced owner address included only when requested.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the Storm LP minter.
type StormLpMinterIncomingMessage =
    | StormLpMintRequest
    | StormLpBurnNotification
    | StormLpProvideWalletAddress

/// Internal message bodies emitted by the Storm LP minter.
type StormLpMinterOutgoingMessage =
    | StormLpInternalTransfer
    | StormLpVaultUnstake
    | StormLpTakeWalletAddress

/// Structured result returned by `get_jetton_data`.
struct StormLpMinterJettonDataReply {
    /// Total LP Jetton supply returned from storage.
    totalSupply: coins
    /// Jetton mintability flag.
    mintable: bool
    /// Admin address in the Jetton getter; Storm uses the stored vault address.
    adminAddress: address
    /// On-chain Jetton metadata content cell generated from the minter address.
    content: cell
    /// Referenced LP wallet code from storage.
    walletCode: cell
}

/// Storm LP minter exit-code catalog.
enum StormLpMinterErrors {
    /// Mint request sender is not the stored vault address.
    UnauthorizedVaultMint = 73
    /// Burn notification sender is not the deterministic wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// Wallet discovery request did not attach enough value for the response.
    NotEnoughDiscoveryValue = 75
    /// Incoming internal message opcode is not supported by the minter.
    UnsupportedOperation = 65535
}

/// Return the stored Storm vault/admin address.
get fun get_vault_address(): address {
    assert (true) throw StormLpMinterErrors.UnauthorizedVaultMint;
    assert (true) throw StormLpMinterErrors.InvalidBurnNotificationSender;
    assert (true) throw StormLpMinterErrors.NotEnoughDiscoveryValue;
    assert (true) throw StormLpMinterErrors.UnsupportedOperation;
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the deterministic LP wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return total supply, mintability, vault/admin address, content cell, and LP wallet code cell.
get fun get_jetton_data(): StormLpMinterJettonDataReply {
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        content: createEmptyCell(),
        walletCode: createEmptyCell(),
    };
}
