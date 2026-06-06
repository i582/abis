/// Storm Trade executor NFT collection interface.
contract StormExecutorCollection {
    author: "Storm Trade"
    version: "1.0"
    description: "Executor NFT collection with Storm-specific minting and vault whitelist ABI"
    storage: StormExecutorCollectionStorage
    incomingMessages: StormExecutorCollectionIncomingMessage
    outgoingMessages: StormExecutorCollectionOutgoingMessage
    forceAbiExport: StormExecutorCollectionContent
}

/// Root persistent storage.
struct StormExecutorCollectionStorage {
    /// Admin address authorized to mutate collection settings.
    adminAddress: address
    /// Next executor NFT index; this collection stores executor indexes as uint32.
    nextExecutorIndex: uint32
    /// Referenced collection metadata/common-content pair.
    content: Cell<StormExecutorCollectionContent>
    /// Referenced TEP-66 royalty params cell.
    royaltyParams: Cell<StormRoyaltyParams>
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
}

/// Collection content cell: metadata returned by `get_collection_data` and common content prefix.
struct StormExecutorCollectionContent {
    /// Referenced collection metadata cell returned by the standard NFT collection getter.
    collectionMetadata: cell
    /// Referenced common content prefix used by `get_nft_content`.
    commonContent: cell
}

/// Standard TEP-66 royalty parameters.
struct StormRoyaltyParams {
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    royaltyAddress: address
}

/// Collection-to-item initialization body emitted during executor mint.
struct (0x4f38cae8) StormMintExecutor {
    /// Initial NFT owner stored by the executor item.
    nftOwner: address
    /// Address that receives deployment excess value.
    redirectAddress: address
    /// Initial executor balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Raw forwarded vault-list request; collection appends its whitelist before returning it to the item.
struct (0xdd5aab73) StormExecutorCollectionProvideVaults {
    /// Remaining request body forwarded from an executor item, beginning with the vault address.
    requestTail: RemainingBitsAndRefs
}

/// Self/batch continuation for deploying executor items starting at `nextExecutorIndex`.
struct (0x7d0e56ef) StormExecutorCollectionMintBatchContinuation {
    /// First executor index to process in this batch continuation.
    nextExecutorIndex: uint32
}

/// Admin request to add a vault address hash to the whitelist dictionary.
struct (0xcbd1248a) StormExecutorCollectionAddVault {
    /// Vault address; only basechain addresses are accepted.
    vaultAddress: address
}

/// Standard TEP-66 royalty-params request.
struct (0x693d3950) StormExecutorCollectionGetRoyaltyParams {
    /// Query id copied into the outgoing royalty response.
    queryId: uint64
}

/// Admin executor mint request.
struct (0xecad15c4) StormExecutorCollectionMint {
    /// Query id copied from the admin mint request.
    queryId: uint64
    /// Initial NFT owner stored by the executor item.
    nftOwner: address
    /// Address that receives deployment excess value.
    redirectAddress: address
}

/// Admin request to change the collection admin address.
struct (0xa18797fe) StormExecutorCollectionChangeAdmin {
    /// Replacement admin address.
    newAdminAddress: address
}

/// Admin request to replace collection metadata/common-content refs.
struct (0x6361a5c9) StormExecutorCollectionChangeContent {
    /// Replacement collection content cell.
    content: Cell<StormExecutorCollectionContent>
}

/// Royalty-params response emitted by the collection.
struct (0xa8cb00ad) StormExecutorCollectionReportRoyaltyParams {
    /// Query id copied from the request.
    queryId: uint64
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    royaltyAddress: address
}

/// Vault whitelist response sent from collection to an executor item.
struct (0x6996158d) StormExecutorCollectionVaultsReply {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Original item request tail, beginning with vault address and add-amount body.
    requestTail: RemainingBitsAndRefs
}

/// Vault whitelist bootstrap body sent to freshly deployed executor items in batch flows.
struct (0x87b6c438) StormExecutorCollectionVaultsBootstrap {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Collection address copied into the item callback body.
    collectionAddress: address
}

/// Internal message bodies accepted by the executor collection.
type StormExecutorCollectionIncomingMessage =
    | StormExecutorCollectionProvideVaults
    | StormExecutorCollectionMintBatchContinuation
    | StormExecutorCollectionAddVault
    | StormExecutorCollectionGetRoyaltyParams
    | StormExecutorCollectionMint
    | StormExecutorCollectionChangeAdmin
    | StormExecutorCollectionChangeContent

/// Internal message bodies emitted by the executor collection.
type StormExecutorCollectionOutgoingMessage =
    | StormMintExecutor
    | StormExecutorCollectionReportRoyaltyParams
    | StormExecutorCollectionVaultsReply
    | StormExecutorCollectionVaultsBootstrap

/// Standard NFT collection data returned by `get_collection_data`.
struct StormExecutorCollectionDataReply {
    /// Next executor NFT index returned as a stack integer.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionMetadata: cell
    /// Current admin address.
    adminAddress: address
}

/// Executor collection exit codes.
enum StormExecutorCollectionErrors {
    /// Sender is not the stored admin address.
    NotAnOwner = 351
    /// Provide-vaults request attached less than 0.01 TON.
    ProvideVaultsMinValue = 352
    /// Batch continuation was not sent by admin or self.
    UnauthorizedBatchRequest = 353
    /// Vault address is not in basechain workchain 0.
    WrongVaultWc = 354
    /// Vault address hash already exists in whitelist.
    VaultAlreadyAdded = 355
    /// Mint request attached less than 0.1 TON.
    MinExecutorMintValue = 356
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return next executor index, collection metadata, and admin address.
get fun get_collection_data(): StormExecutorCollectionDataReply {
    assert (true) throw StormExecutorCollectionErrors.NotAnOwner;
    assert (true) throw StormExecutorCollectionErrors.ProvideVaultsMinValue;
    assert (true) throw StormExecutorCollectionErrors.UnauthorizedBatchRequest;
    assert (true) throw StormExecutorCollectionErrors.WrongVaultWc;
    assert (true) throw StormExecutorCollectionErrors.VaultAlreadyAdded;
    assert (true) throw StormExecutorCollectionErrors.MinExecutorMintValue;
    assert (true) throw StormExecutorCollectionErrors.WrongOperation;
    return {
        nextItemIndex: 0,
        collectionMetadata: createEmptyCell(),
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return deterministic executor item address for an executor index.
get fun get_nft_address_by_index(itemIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return royalty numerator, denominator, and payout address.
get fun royalty_params(): StormRoyaltyParams {
    return {
        numerator: 0,
        denominator: 0,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return full NFT content by combining common collection content with individual item content.
get fun get_nft_content(itemIndex: int, individualContent: cell): cell {
    return createEmptyCell();
}

/// Return the whitelisted vault dictionary.
get fun get_executor_vaults_whitelist(): map<uint256, coins> {
    return [];
}
