/// Storm Trade referral NFT collection interface.
contract StormReferralCollection {
    author: "Storm Trade"
    version: "1.0"
    description: "Referral NFT collection with Storm-specific minting, default fee, and vault whitelist ABI"
    storage: StormReferralCollectionStorage
    incomingMessages: StormReferralCollectionIncomingMessage
    outgoingMessages: StormReferralCollectionOutgoingMessage
    forceAbiExport: StormReferralCollectionContent | StormReferralCollectionConfig | StormMintReferral
}

/// Root persistent storage.
struct StormReferralCollectionStorage {
    /// Admin address authorized to mutate collection settings and privileged mint variants.
    adminAddress: address
    /// Next referral NFT index; this collection stores referral indexes as uint64.
    nextReferralIndex: uint64
    /// Referenced collection metadata/common-content pair.
    content: Cell<StormReferralCollectionContent>
    /// Referenced default-fee and royalty configuration pair.
    config: Cell<StormReferralCollectionConfig>
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
}

/// Collection content cell: metadata returned by `get_collection_data` and common content prefix.
struct StormReferralCollectionContent {
    /// Referenced collection metadata cell returned by the standard NFT collection getter.
    collectionMetadata: cell
    /// Referenced common content prefix used by `get_nft_content`.
    commonContent: cell
}

/// Referral collection config cell with default referral fees and TEP-66 royalty params.
struct StormReferralCollectionConfig {
    /// Referenced default discount/rebate values used by standard referral mints.
    defaultFees: Cell<StormReferralParameters>
    /// Referenced royalty numerator, denominator, and payout address.
    royaltyParams: Cell<StormRoyaltyParams>
}

/// Referral fee parameters stored as two uint32 values.
struct StormReferralParameters {
    /// Discount rate value copied into referral item storage.
    discount: uint32
    /// Rebate rate value copied into referral item storage.
    rebate: uint32
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

/// Collection-to-item initialization body emitted during referral mint.
struct (0xcb4ddc3c) StormMintReferral {
    /// Initial NFT owner stored by the referral item.
    nftOwner: address
    /// Referral type stored as a uint2 in item storage.
    refType: uint2
    /// Address that receives deployment excess value.
    redirectAddress: address
    /// Referenced discount/rebate parameters.
    parameters: Cell<StormReferralParameters>
    /// Initial referral balances keyed by vault address hash.
    balancesDict: map<uint256, coins>
}

/// Raw forwarded vault-list request; collection appends its whitelist before returning it to the item.
struct (0xdd5aab73) StormReferralCollectionProvideVaults {
    /// Remaining request body forwarded from a referral item, beginning with the vault address.
    requestTail: RemainingBitsAndRefs
}

/// Self/batch continuation for deploying referral items starting at `nextReferralIndex`.
struct (0x7d0e56ef) StormReferralCollectionMintBatchContinuation {
    /// First referral index to process in this batch continuation.
    nextReferralIndex: uint64
}

/// Admin request to add a vault address hash to the whitelist dictionary.
struct (0xcbd1248a) StormReferralCollectionAddVault {
    /// Vault address; only basechain addresses are accepted.
    vaultAddress: address
}

/// Standard TEP-66 royalty-params request.
struct (0x693d3950) StormReferralCollectionGetRoyaltyParams {
    /// Query id copied into the outgoing royalty response.
    queryId: uint64
}

/// Referral mint request; tail is variant-encoded by referral type.
struct (0xecad15c4) StormReferralCollectionMint {
    /// Query id parsed before the referral-type selector.
    queryId: uint64
    /// Referral type: type 0 uses default fees, nonzero types require admin and custom fee ref in the tail.
    refType: uint2
    /// For type 0: `nft_owner redirect_address`; for nonzero: `^StormReferralParameters nft_owner redirect_address`.
    mintTail: RemainingBitsAndRefs
}

/// Admin request to replace collection metadata/common-content refs.
struct (0x6361a5c9) StormReferralCollectionChangeContent {
    /// Replacement collection content cell.
    content: Cell<StormReferralCollectionContent>
}

/// Admin request to change the collection admin address.
struct (0xa18797fe) StormReferralCollectionChangeAdmin {
    /// Replacement admin address.
    newAdminAddress: address
}

/// Admin request to replace only the default discount component.
struct (0x1194998f) StormReferralCollectionSetDefaultDiscount {
    /// Replacement default discount.
    discount: uint32
}

/// Admin request to replace only the default rebate component.
struct (0x07a57c24) StormReferralCollectionSetDefaultRebate {
    /// Replacement default rebate.
    rebate: uint32
}

/// Admin request to replace both default referral fee components.
struct (0x690ca46e) StormReferralCollectionSetDefaultReferralFees {
    /// Replacement default discount.
    discount: uint32
    /// Replacement default rebate.
    rebate: uint32
}

/// Royalty-params response emitted by the collection.
struct (0xa8cb00ad) StormReferralCollectionReportRoyaltyParams {
    /// Query id copied from the request.
    queryId: uint64
    /// Royalty numerator.
    numerator: uint16
    /// Royalty denominator.
    denominator: uint16
    /// Royalty payout address.
    royaltyAddress: address
}

/// Vault whitelist response sent from collection to a referral item.
struct (0x6996158d) StormReferralCollectionVaultsReply {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Original item request tail, beginning with vault address and add-amount body.
    requestTail: RemainingBitsAndRefs
}

/// Vault whitelist bootstrap body sent to freshly deployed referral items in batch flows.
struct (0x87b6c438) StormReferralCollectionVaultsBootstrap {
    /// Vault whitelist keyed by vault address hash.
    vaultsWhitelist: map<uint256, coins>
    /// Collection address copied into the item callback body.
    collectionAddress: address
}

/// Internal message bodies accepted by the referral collection.
type StormReferralCollectionIncomingMessage =
    | StormReferralCollectionProvideVaults
    | StormReferralCollectionMintBatchContinuation
    | StormReferralCollectionAddVault
    | StormReferralCollectionGetRoyaltyParams
    | StormReferralCollectionMint
    | StormReferralCollectionChangeContent
    | StormReferralCollectionChangeAdmin
    | StormReferralCollectionSetDefaultDiscount
    | StormReferralCollectionSetDefaultRebate
    | StormReferralCollectionSetDefaultReferralFees

/// Internal message bodies emitted by the referral collection.
type StormReferralCollectionOutgoingMessage =
    | StormMintReferral
    | StormReferralCollectionReportRoyaltyParams
    | StormReferralCollectionVaultsReply
    | StormReferralCollectionVaultsBootstrap

/// Standard NFT collection data returned by `get_collection_data`.
struct StormReferralCollectionDataReply {
    /// Next referral NFT index returned as a stack integer.
    nextItemIndex: int
    /// Referenced collection metadata cell.
    collectionMetadata: cell
    /// Current admin address.
    adminAddress: address
}

/// Default referral fee getter result.
struct GetDefaultReferralFeesReply {
    /// Default discount loaded from the config default-fees ref.
    discount: uint32
    /// Default rebate loaded from the config default-fees ref.
    rebate: uint32
}

/// Referral collection exit codes.
enum StormReferralCollectionErrors {
    /// Sender is not the stored admin address.
    NotAnOwner = 301
    /// Provide-vaults request attached less than 0.01 TON.
    ProvideVaultsMinValue = 302
    /// Vault address is not in basechain workchain 0.
    WrongVaultWc = 303
    /// Vault address hash already exists in whitelist.
    VaultAlreadyAdded = 304
    /// Mint request attached less than 0.1 TON.
    MinReferralMintValue = 305
    /// Referral type is greater than 2.
    WrongRefType = 306
    /// Batch continuation was not sent by admin or self.
    UnauthorizedBatchRequest = 316
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return next referral index, collection metadata, and admin address.
get fun get_collection_data(): StormReferralCollectionDataReply {
    assert (true) throw StormReferralCollectionErrors.NotAnOwner;
    assert (true) throw StormReferralCollectionErrors.ProvideVaultsMinValue;
    assert (true) throw StormReferralCollectionErrors.WrongVaultWc;
    assert (true) throw StormReferralCollectionErrors.VaultAlreadyAdded;
    assert (true) throw StormReferralCollectionErrors.MinReferralMintValue;
    assert (true) throw StormReferralCollectionErrors.WrongRefType;
    assert (true) throw StormReferralCollectionErrors.UnauthorizedBatchRequest;
    assert (true) throw StormReferralCollectionErrors.WrongOperation;
    return {
        nextItemIndex: 0,
        collectionMetadata: createEmptyCell(),
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return deterministic referral item address for a referral index.
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

/// Return default referral discount and rebate.
get fun get_default_referral_fees(): GetDefaultReferralFeesReply {
    return {
        discount: 0,
        rebate: 0,
    };
}

/// Return the whitelisted vault dictionary.
get fun get_referral_vaults_whitelist(): map<uint256, coins> {
    return [];
}
