/// Mintless Jetton v1.0 minter with Merkle-root wallet derivation and airdrop metadata.
contract MintlessJettonMaster {
    author: "TON Core"
    version: "1.0"
    description: "Curated interface for ton-blockchain/mintless-jetton-contract v1.0 minter"
    storage: MintlessJettonMasterStorage
    incomingMessages: MintlessJettonMasterIncomingMessage
    outgoingMessages: MintlessJettonMasterOutgoingMessage
}

/// Persistent mintless minter state stored in the root data cell.
struct MintlessJettonMasterStorage {
    /// Total issued jettons encoded as TL-B `Coins` in storage.
    totalSupply: coins
    /// Current admin address authorized to mint, transfer admin rights, mutate metadata, or upgrade code/data; `addr_none` after `drop_admin`.
    adminAddress: address?
    /// Pending admin address for the two-step `change_admin` / `claim_admin` flow.
    nextAdminAddress: address?
    /// Referenced wallet code cell used with `merkleRoot` to derive salted deterministic wallet addresses.
    jettonWalletCode: cell
    /// Referenced snake-encoded metadata URI cell stored without the on-chain metadata dictionary prefix.
    metadataUri: cell
    /// Root hash of the mintless airdrop dictionary proven by wallet claim payloads.
    merkleRoot: uint256
}

/// Minter-to-wallet internal transfer body used by minting and wallet transfers.
struct (0x178d4519) MintlessJettonMasterInternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the mint payload or sending wallet; mint payloads may use `addr_none`.
    from: address?
    /// Optional response address for wallet `Excesses`.
    responseAddress: address?
    /// Nanotons forwarded to the recipient owner's notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin mint request accepted by the mintless minter while an admin is present.
struct (0x642b7d07) MintlessJettonMasterMint {
    /// Admin-selected query id carried only in the minter request.
    queryId: uint64
    /// Jetton owner address whose deterministic salted wallet receives the mint transfer.
    toAddress: address
    /// Nanotons attached to the wallet deployment/internal-transfer message.
    tonAmount: coins
    /// Referenced internal transfer body validated and forwarded to the recipient wallet.
    masterMsg: Cell<MintlessJettonMasterInternalTransfer>
}

/// Burn notification sent by a deterministic wallet to decrease total supply.
struct (0x7bdd97de) MintlessJettonMasterBurnNotification {
    /// Query id copied from the original wallet burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Owner address whose deterministic wallet burned the jettons.
    sender: address
    /// Optional response address that receives an `Excesses` refund when non-null.
    responseDestination: address?
}

/// TEP-89 wallet discovery request accepted by the mintless minter.
struct (0x2c76b973) MintlessJettonMasterProvideWalletAddress {
    /// Caller-selected query id copied into the `TakeWalletAddress` response.
    queryId: uint64
    /// Owner address whose deterministic salted wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Admin request that sets the pending next admin address.
struct (0x6501f354) MintlessJettonMasterChangeAdmin {
    /// Admin-selected query id carried in the change request.
    queryId: uint64
    /// Pending admin address stored until that address sends `claim_admin`; may be `addr_none` to clear.
    newAdminAddress: address?
}

/// Pending-admin request that promotes `nextAdminAddress` to `adminAddress`.
struct (0xfb88e119) MintlessJettonMasterClaimAdmin {
    /// Query id carried by the pending-admin claim request.
    queryId: uint64
}

/// Admin request that permanently clears both admin slots by storing `addr_none`.
struct (0x7431f221) MintlessJettonMasterDropAdmin {
    /// Admin-selected query id carried in the drop request.
    queryId: uint64
}

/// Admin request that replaces the stored snake metadata URI tail.
struct (0xcb862902) MintlessJettonMasterChangeMetadataUri {
    /// Admin-selected query id carried in the metadata change request.
    queryId: uint64
    /// Raw remaining body slice stored as the snake metadata URI cell.
    metadataUri: RemainingBitsAndRefs
}

/// Admin request that replaces minter data and code.
struct (0x2508d66a) MintlessJettonMasterUpgrade {
    /// Admin-selected query id carried in the upgrade request.
    queryId: uint64
    /// Referenced replacement root data cell passed directly to `set_data`.
    newData: cell
    /// Referenced replacement code cell passed directly to `set_code`.
    newCode: cell
}

/// Funding-only message accepted by the minter without changing state.
struct (0xd372158c) MintlessJettonMasterTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// TEP-74 excesses response emitted after burn notification processing when a response address is present.
struct (0xd53276db) MintlessJettonMasterExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// TEP-89 wallet discovery response emitted to the original requester.
struct (0xd1735400) MintlessJettonMasterTakeWalletAddress {
    /// Query id copied from the `ProvideWalletAddress` request.
    queryId: uint64
    /// Deterministic salted wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced cell containing the requested owner address when `includeAddress` was true.
    ownerAddress: Cell<address>?
}

/// Internal message bodies accepted by the mintless v1.0 minter.
type MintlessJettonMasterIncomingMessage =
    | MintlessJettonMasterMint
    | MintlessJettonMasterBurnNotification
    | MintlessJettonMasterProvideWalletAddress
    | MintlessJettonMasterChangeAdmin
    | MintlessJettonMasterClaimAdmin
    | MintlessJettonMasterDropAdmin
    | MintlessJettonMasterChangeMetadataUri
    | MintlessJettonMasterUpgrade
    | MintlessJettonMasterTopUp

/// Statically known internal message bodies emitted by the mintless v1.0 minter.
type MintlessJettonMasterOutgoingMessage =
    | MintlessJettonMasterInternalTransfer
    | MintlessJettonMasterExcesses
    | MintlessJettonMasterTakeWalletAddress

/// Structured result returned by `get_jetton_data`.
struct GetMintlessJettonDataReply {
    /// Total issued jettons returned as a TVM stack integer.
    totalSupply: int
    /// Source returns true because this minter can mint while an admin remains.
    mintable: bool
    /// Current admin `MsgAddress` returned on stack, or `addr_none` after `drop_admin`.
    adminAddress: any_address
    /// On-chain metadata dictionary built from the stored URI.
    jettonContent: cell
    /// Referenced wallet code cell embedded in salted deterministic wallet state init.
    jettonWalletCode: cell
}

/// Structured result returned by `get_wallet_state_init_and_salt`.
struct GetMintlessWalletStateInitAndSaltReply {
    /// Full wallet `StateInit` cell for the owner, wallet code, master address, Merkle root, and selected salt.
    stateInit: cell
    /// Selected salt returned as a stack integer by the source getter.
    salt: int
}

/// Mintless v1.0 minter exit-code catalog from official FunC source.
enum MintlessJettonMasterErrors {
    /// Nested mint payload opcode is not `internal_transfer`.
    InvalidNestedOperation = 72
    /// Sender is not the stored admin or pending admin for the requested admin action.
    UnauthorizedAdmin = 73
    /// Burn notification sender is not the deterministic salted wallet for the reported owner.
    InvalidBurnNotificationSender = 74
    /// Transfer or burn funding is below the required gas/forward-fee budget.
    NotEnoughGas = 48
    /// Forward payload layout is invalid for a validated mint transfer.
    InvalidMessage = 49
    /// Target owner address is outside the configured base workchain.
    WrongWorkchain = 333
    /// Incoming internal message opcode is not supported by the minter.
    UnsupportedOperation = 65535
}

/// Return supply, mintability, admin address, metadata content cell, and wallet code cell.
get fun get_jetton_data(): GetMintlessJettonDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw MintlessJettonMasterErrors.InvalidNestedOperation;
    assert (true) throw MintlessJettonMasterErrors.UnauthorizedAdmin;
    assert (true) throw MintlessJettonMasterErrors.InvalidBurnNotificationSender;
    assert (true) throw MintlessJettonMasterErrors.NotEnoughGas;
    assert (true) throw MintlessJettonMasterErrors.InvalidMessage;
    assert (true) throw MintlessJettonMasterErrors.WrongWorkchain;
    assert (true) throw MintlessJettonMasterErrors.UnsupportedOperation;
    return {
        totalSupply: 0,
        mintable: true,
        adminAddress: createAddressNone(),
        jettonContent: createEmptyCell(),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the deterministic salted wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the wallet state init and selected salt for `ownerAddress`.
get fun get_wallet_state_init_and_salt(ownerAddress: address): GetMintlessWalletStateInitAndSaltReply {
    return {
        stateInit: createEmptyCell(),
        salt: 0,
    };
}

/// Return the pending next admin stack `MsgAddress`, or `addr_none` when no admin claim is pending.
get fun get_next_admin_address(): any_address {
    return createAddressNone();
}

/// Return the stored Merkle root used to verify mintless wallet claim proofs.
get fun get_mintless_airdrop_hashmap_root(): uint256 {
    return 0;
}
