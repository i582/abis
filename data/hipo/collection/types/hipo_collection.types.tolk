/// Hipo Finance NFT-style bill collection for one validation round payout.
contract HipoCollection {
    author: "Hipo Finance"
    version: "1.0"
    description: "Curated interface for the Hipo Finance bill collection contract"
    storage: HipoCollectionStorage
    incomingMessages: HipoCollectionIncomingMessage
    outgoingMessages: HipoCollectionOutgoingMessage
    thrownErrors: HipoCollectionErrors
}

/// Persistent collection state stored in the root data cell.
struct HipoCollectionStorage {
    /// Treasury address authorized to mint bills and start collection-wide burns.
    treasury: address
    /// Validation round start Unix timestamp embedded into collection metadata and treasury callbacks.
    roundSince: uint32
    /// Next deterministic bill item index; source stores and increments it as uint64.
    nextItemIndex: uint64
    /// Bill item code cell used to derive deterministic item StateInit and addresses.
    billCode: cell
}

/// Treasury request that deploys and assigns the next bill item.
struct (0x4b2d7871) HipoCollectionMintBill {
    /// Query id copied into the outgoing `assign_bill` body.
    queryId: uint64
    /// TON amount represented by the bill, encoded as TL-B `Coins`.
    amount: coins
    /// True when the bill represents an unstake burn path; false for minting tokens.
    unstake: bool
    /// User owner address passed through to the bill and later treasury token message.
    owner: address
    /// Parent hTON address passed through to bill and treasury token accounting.
    parent: address
    /// Nanotons forwarded for NFT ownership assignment handling.
    ownershipAssignedAmount: coins
}

/// Bill item callback accepted only from the deterministic bill address for `index`.
struct (0x840f6369) HipoCollectionBillBurned {
    /// Query id copied into follow-up burn and treasury callback messages.
    queryId: uint64
    /// TON or token amount represented by the burned bill.
    amount: coins
    /// Selects outgoing `burn_tokens` when true and `mint_tokens` when false.
    unstake: bool
    /// User owner address forwarded to the treasury token accounting message.
    owner: address
    /// Parent hTON address forwarded to the treasury token accounting message.
    parent: address
    /// Burned bill item index used to validate the sender and continue the burn loop.
    index: uint64
}

/// Treasury request that starts or resumes sequential burning from `startIndex`.
struct (0x639d400a) HipoCollectionBurnAll {
    /// Query id copied into `burn_bill` and `last_bill_burned` follow-up messages.
    queryId: uint64
    /// First bill index to burn in the sequential collection burn loop.
    startIndex: uint64
}

/// Body emitted to the newly derived bill item after `mint_bill`.
struct (0x3275dfc2) HipoCollectionAssignBill {
    /// Query id copied from the treasury `mint_bill` request.
    queryId: uint64
    /// TON amount represented by the bill, encoded as TL-B `Coins`.
    amount: coins
    /// True when the bill represents an unstake burn path; false for minting tokens.
    unstake: bool
    /// User owner address stored/assigned by the bill item.
    owner: address
    /// Parent hTON address stored/assigned by the bill item.
    parent: address
    /// Nanotons carried for the bill ownership assignment flow.
    ownershipAssignedAmount: coins
}

/// Body emitted to each deterministic bill during the burn-all loop.
struct (0x6f89f5e3) HipoCollectionBurnBill {
    /// Query id copied from `burn_all` or the preceding `bill_burned` callback.
    queryId: uint64
}

/// Treasury callback emitted when the burn-all loop reaches `nextItemIndex`.
struct (0xc6d8b51f) HipoCollectionLastBillBurned {
    /// Query id copied from the burn-all flow.
    queryId: uint64
    /// Validation round start Unix timestamp stored by this collection.
    roundSince: uint32
}

/// Treasury token-accounting callback emitted after a non-unstake bill is burned.
struct (0x42684479) HipoCollectionMintTokens {
    /// Query id copied from the bill callback.
    queryId: uint64
    /// TON amount represented by the bill, encoded as TL-B `Coins`.
    coins: coins
    /// User owner address that receives minted token accounting.
    owner: address
    /// Parent hTON address associated with the owner.
    parent: address
    /// Validation round start Unix timestamp stored by this collection.
    roundSince: uint32
}

/// Treasury token-accounting callback emitted after an unstake bill is burned.
struct (0x7cffe1ee) HipoCollectionBurnTokens {
    /// Query id copied from the bill callback.
    queryId: uint64
    /// Token amount represented by the bill, encoded as TL-B `Coins`.
    tokens: coins
    /// User owner address whose tokens are burned.
    owner: address
    /// Parent hTON address associated with the owner.
    parent: address
    /// Validation round start Unix timestamp stored by this collection.
    roundSince: uint32
}

/// Internal message bodies accepted by Hipo Collection.
type HipoCollectionIncomingMessage =
    | HipoCollectionMintBill
    | HipoCollectionBillBurned
    | HipoCollectionBurnAll

/// Internal message bodies emitted by Hipo Collection.
type HipoCollectionOutgoingMessage =
    | HipoCollectionAssignBill
    | HipoCollectionBurnBill
    | HipoCollectionLastBillBurned
    | HipoCollectionMintTokens
    | HipoCollectionBurnTokens

/// Structured result returned by `get_collection_data`.
struct HipoCollectionDataReply {
    /// Next deterministic bill item index returned as a TVM stack integer.
    nextItemIndex: int
    /// On-chain TEP-64 metadata cell containing name, description, and image entries.
    collectionMetadata: cell
    /// Treasury address stored by this collection.
    treasury: address
}

/// Hipo Collection exit-code catalog from the source constants used by collection.fc.
enum HipoCollectionErrors {
    /// Sender is not the stored treasury or deterministic bill sender required by the operation.
    AccessDenied = 103
    /// Incoming internal message opcode is not one of the source dispatcher branches.
    InvalidOperation = 107
}

/// Return next bill index, generated collection metadata, and treasury address.
get fun get_collection_data(): HipoCollectionDataReply {
    throw 0;
}

/// Return the deterministic bill item address for `index`.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return the individual bill content unchanged, as implemented by the source.
get fun get_nft_content(index: int, individualContent: cell): cell {
    throw 0;
}
