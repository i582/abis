/// Jetton v1.00 minter with admin minting and burn notifications.
contract JettonV100Master {
    author: "TON Core"
    version: "1.00"
    description: "Curated interface for the ton-blockchain/token-contract Jetton v1.00 minter"
    storage: JettonV100MasterStorage
    incomingMessages: JettonV100MasterIncomingMessage
    outgoingMessages: JettonV100MasterOutgoingMessage
}

/// Persistent minter state stored in the root data cell.
struct JettonV100MasterStorage {
    /// Total issued jettons encoded as TL-B `Coins` in storage.
    totalSupply: coins
    /// Admin address authorized to mint.
    adminAddress: address
    /// Referenced jetton metadata content cell returned by `get_jetton_data`.
    jettonContent: cell
    /// Referenced wallet code cell used to derive deterministic user wallet addresses.
    jettonWalletCode: cell
}

/// Admin mint request accepted by the v1.00 minter.
struct (0x00000015) JettonV100Mint {
    /// Admin-selected query id carried only in the minter request.
    queryId: uint64
    /// Jetton owner address whose deterministic wallet receives the mint transfer.
    toAddress: address
    /// Nanotons attached to the wallet deployment/internal-transfer message.
    tonAmount: coins
    /// Referenced raw wallet message body, normally `JettonInternalTransfer`.
    masterMsg: cell
}

/// Burn notification sent by a deterministic user wallet to decrease total supply.
struct (0x7bdd97de) JettonBurnNotification {
    /// Query id copied from the original wallet burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Owner address whose deterministic wallet burned the jettons.
    sender: address
    /// Optional response address that receives an `Excesses` refund when non-null.
    responseDestination: address
}

/// TEP-74 excesses response emitted after burn notification processing when a response address is present.
struct (0xd53276db) JettonExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the Jetton v1.00 minter.
type JettonV100MasterIncomingMessage =
    | JettonV100Mint
    | JettonBurnNotification

/// Statically known internal message bodies emitted by the Jetton v1.00 minter.
type JettonV100MasterOutgoingMessage = JettonExcesses

/// Structured result returned by `get_jetton_data`.
struct GetJettonV100DataReply {
    /// Total issued jettons returned as a TVM stack integer.
    totalSupply: int
    /// Source returns true because this minter can mint through the admin.
    mintable: bool
    /// Current admin address.
    adminAddress: address
    /// Referenced jetton metadata content cell.
    jettonContent: cell
    /// Referenced wallet code cell embedded in deterministic wallet state init.
    jettonWalletCode: cell
}

/// Jetton v1.00 minter exit-code catalog from the official FunC source.
enum JettonV100MasterErrors {
    /// Sender is not the stored admin for mint requests.
    UnauthorizedAdmin = 73
    /// Burn notification sender is not the deterministic wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// Incoming internal message opcode is not supported by the minter.
    UnsupportedOperation = 65535
}

/// Return total supply, mintability, admin address, content cell, and wallet code cell.
get fun get_jetton_data(): GetJettonV100DataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw JettonV100MasterErrors.UnauthorizedAdmin;
    assert (true) throw JettonV100MasterErrors.InvalidBurnNotificationSender;
    assert (true) throw JettonV100MasterErrors.UnsupportedOperation;
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
