/// TonPay merchant Store revision 11 deployed on mainnet.
contract TonpayStoreV11 {
    author: "TonPay"
    version: "11"
    description: "TonPay Store holds merchant metadata, deploys version-9 invoices, and accepts direct purchase requests."
    storage: TonpayStoreV11Storage
    incomingMessages: TonpayStoreV11IncomingMessage
    outgoingMessages: TonpayStoreV11OutgoingMessage
    forceAbiExport: TonpayStoreV11EmptyBody
    thrownErrors: TonpayStoreV11Errors
}

/// Standard opcode-zero text cell used by TonPay metadata references.
struct (0x00000000) TonpayStoreV11Text {
    /// Raw UTF-8 snake tail stored after the zero opcode.
    value: RemainingBitsAndRefs
}

/// Image and webhook references grouped in Store storage.
struct TonpayStoreV11Metadata {
    /// Store image text cell.
    image: Cell<TonpayStoreV11Text>
    /// Store webhook text cell.
    webhook: Cell<TonpayStoreV11Text>
}

/// Persistent Store revision-11 state.
struct TonpayStoreV11Storage {
    /// Merchant owner authorized to edit and upgrade the Store.
    owner: address
    /// Human-readable Store name.
    name: Cell<TonpayStoreV11Text>
    /// Human-readable Store description.
    description: Cell<TonpayStoreV11Text>
    /// Referenced image and webhook cells.
    metadata: Cell<TonpayStoreV11Metadata>
    /// ISO 18245 merchant category code.
    mccCode: uint16
    /// Signed two-bit activity flag; active is encoded as `-1`.
    active: int2
    /// Invoice revision-9 code used in deterministic StateInit cells.
    invoiceCode: cell
}

/// Empty deployment or top-up body accepted without changing Store state.
struct TonpayStoreV11EmptyBody {}

/// Owner request to create an Invoice with explicit customer data.
struct (0x4b4e70b0) TonpayStoreV11IssueInvoice {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Signed two-bit flag indicating whether customer is enforced.
    hasCustomer: int2
    /// Referenced customer address; zero address when customer is not enforced.
    customer: Cell<address>
    /// Referenced invoice identifier text.
    invoiceId: Cell<TonpayStoreV11Text>
    /// Referenced merchant metadata text.
    metadata: Cell<TonpayStoreV11Text>
    /// Requested payment amount in nanotons.
    amount: uint64
}

/// Public request that creates and immediately pays an Invoice.
struct (0x36b795b5) TonpayStoreV11RequestPurchase {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Referenced invoice identifier text.
    invoiceId: Cell<TonpayStoreV11Text>
    /// Referenced merchant metadata text.
    metadata: Cell<TonpayStoreV11Text>
    /// Requested payment amount in nanotons.
    amount: uint64
}

/// Owner request to replace Store presentation and merchant-category fields.
struct (0xa0b2b61d) TonpayStoreV11EditStore {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Replacement Store name.
    name: Cell<TonpayStoreV11Text>
    /// Replacement Store description.
    description: Cell<TonpayStoreV11Text>
    /// Replacement image reference.
    image: Cell<TonpayStoreV11Text>
    /// Replacement webhook reference.
    webhook: Cell<TonpayStoreV11Text>
    /// Replacement merchant category code.
    mccCode: uint16
}

/// Owner request to stop new invoice and purchase operations.
struct (0xf9bf9637) TonpayStoreV11Deactivate {
    /// Caller-selected correlation id.
    queryId: uint64
}

/// Owner request to resume invoice and purchase operations.
struct (0x97500daf) TonpayStoreV11Activate {
    /// Caller-selected correlation id.
    queryId: uint64
}

/// Authorized request to replace Store and Invoice code together.
struct (0xb43bbb52) TonpayStoreV11UpgradeFull {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Replacement Store code.
    storeCode: cell
    /// Replacement Invoice code stored by the Store.
    invoiceCode: cell
    /// Signed two-bit flag indicating whether a replacement data ref follows.
    hasNewData: int2
    /// Optional replacement-data ref and any remaining extension data.
    newDataTail: RemainingBitsAndRefs
}

/// Authorized request to replace only the embedded Invoice code.
struct (0xb5f1424f) TonpayStoreV11UpgradeInvoice {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Replacement Invoice code stored by the Store.
    invoiceCode: cell
}

/// Authorized request to replace Store code.
struct (0xacb08f28) TonpayStoreV11UpgradeStore {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Replacement Store code.
    storeCode: cell
    /// Signed two-bit flag indicating whether a replacement data ref follows.
    hasNewData: int2
    /// Optional replacement-data ref and any remaining extension data.
    newDataTail: RemainingBitsAndRefs
}

/// All ordinary internal bodies accepted by Store revision 11.
type TonpayStoreV11IncomingMessage =
    | TonpayStoreV11IssueInvoice
    | TonpayStoreV11RequestPurchase
    | TonpayStoreV11EditStore
    | TonpayStoreV11Deactivate
    | TonpayStoreV11Activate
    | TonpayStoreV11UpgradeFull
    | TonpayStoreV11UpgradeInvoice
    | TonpayStoreV11UpgradeStore

/// Payment request sent by Store revision 11 to a newly deployed Invoice.
struct (0xf53a02d3) TonpayStoreV11PayInvoice {
    /// Constant zero in Store revision 11.
    queryId: uint64
    /// Original purchase requester used as the change destination.
    payer: address
}

/// Structured non-empty body emitted by Store revision 11.
///
/// The empty Invoice deployment body is exported separately as
/// `TonpayStoreV11EmptyBody` because tagged and untagged bodies cannot share
/// an automatically discriminated Tolk union.
type TonpayStoreV11OutgoingMessage = TonpayStoreV11PayInvoice

/// Full Store data returned by `get_store_data`.
struct TonpayStoreV11DataReply {
    /// Store owner.
    owner: address
    /// Store name text cell.
    name: cell
    /// Store description text cell.
    description: cell
    /// Store image text cell.
    image: cell
    /// Store webhook text cell.
    webhook: cell
    /// Merchant category code.
    mccCode: int
    /// Signed activity flag.
    active: int
    /// Embedded Invoice code.
    invoiceCode: cell
    /// Store version constant, equal to 11.
    version: int
}

/// Store revision-11 exit codes.
enum TonpayStoreV11Errors {
    /// Invoice creation or purchase was attempted while the Store is inactive.
    StoreDeactivated = 240
    /// Attached value does not cover the purchase amount and deployment reserve.
    AmountMismatch = 241
    /// Sender is not the owner or authorized upgrade address.
    Unauthorized = 3840
    /// Incoming opcode is not supported by Store revision 11.
    UnsupportedOperation = 65535
}

/// Return the Store owner.
get fun get_store_owner(): address {
    throw 0;
}

/// Return the referenced Store name text cell.
get fun get_store_name(): cell {
    throw 0;
}

/// Return the referenced Store description text cell.
get fun get_store_description(): cell {
    throw 0;
}

/// Return the referenced Store image text cell.
get fun get_store_image(): cell {
    throw 0;
}

/// Return the referenced Store webhook text cell.
get fun get_store_webhook(): cell {
    throw 0;
}

/// Return the merchant category code.
get fun get_store_mcc_code(): int {
    throw 0;
}

/// Return the signed activity flag.
get fun get_store_active(): int {
    throw 0;
}

/// Return the embedded Invoice code cell.
get fun get_store_invoice_code(): cell {
    throw 0;
}

/// Return the Store version constant, equal to 11.
get fun get_store_version(): int {
    throw 0;
}

/// Return all Store fields and the version constant.
get fun get_store_data(): TonpayStoreV11DataReply {
    throw 0;
}
