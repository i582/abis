/// TonPay per-purchase Invoice revision 9 deployed by Store revision 11.
contract TonpayInvoiceV9 {
    author: "TonPay"
    version: "9"
    description: "TonPay Invoice records a GRAM payment request, enforces optional customer identity, and distributes paid value."
    storage: TonpayInvoiceV9Storage
    incomingMessages: TonpayInvoiceV9IncomingMessage
    outgoingMessages: TonpayInvoiceV9OutgoingMessage
    forceAbiExport: TonpayInvoiceV9EmptyBody
    thrownErrors: TonpayInvoiceV9Errors
}

/// Standard opcode-zero text cell used by Invoice references and notifications.
struct (0x00000000) TonpayInvoiceV9Text {
    /// Raw UTF-8 snake tail stored after the zero opcode.
    value: RemainingBitsAndRefs
}

/// Persistent Invoice revision-9 state.
struct TonpayInvoiceV9Storage {
    /// Store that deployed this Invoice and may submit a payment with payer data.
    store: address
    /// Merchant authorized to edit and change Invoice activity.
    merchant: address
    /// Fee beneficiary receiving 2 percent of the Invoice amount.
    beneficiary: address
    /// Signed two-bit flag indicating whether a customer is enforced.
    hasCustomer: int2
    /// Referenced customer address; zero address when customer is not enforced.
    customer: Cell<address>
    /// Referenced invoice identifier text.
    invoiceId: Cell<TonpayInvoiceV9Text>
    /// Referenced merchant metadata text.
    metadata: Cell<TonpayInvoiceV9Text>
    /// Required payment amount in nanograms.
    amount: uint64
    /// Signed two-bit paid flag; paid is encoded as `-1`.
    paid: int2
    /// Signed two-bit activity flag; active is encoded as `-1`.
    active: int2
}

/// Empty deployment or top-up body returned to the sender.
struct TonpayInvoiceV9EmptyBody {}

/// GRAM payment request accepted from a customer or the deploying Store.
struct (0xf53a02d3) TonpayInvoiceV9Pay {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Optional payer address used only when the sender is the Store.
    payerTail: RemainingBitsAndRefs
}

/// Merchant request to replace editable Invoice fields before payment.
struct (0x48c504f3) TonpayInvoiceV9Edit {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Signed two-bit flag indicating whether a customer is enforced.
    hasCustomer: int2
    /// Referenced customer address; zero address when customer is not enforced.
    customer: Cell<address>
    /// Replacement invoice identifier text.
    invoiceId: Cell<TonpayInvoiceV9Text>
    /// Replacement merchant metadata text.
    metadata: Cell<TonpayInvoiceV9Text>
    /// Replacement payment amount in nanograms.
    amount: uint64
}

/// Merchant request to deactivate an unpaid active Invoice.
struct (0x1cc0b11e) TonpayInvoiceV9Deactivate {
    /// Caller-selected correlation id.
    queryId: uint64
}

/// Merchant request to reactivate an unpaid inactive Invoice.
struct (0xc285952f) TonpayInvoiceV9Activate {
    /// Caller-selected correlation id.
    queryId: uint64
}

/// Beneficiary-authorized request to replace Invoice code and optionally data.
struct (0x61bddf8b) TonpayInvoiceV9Upgrade {
    /// Caller-selected correlation id.
    queryId: uint64
    /// Replacement Invoice code.
    code: cell
    /// Signed two-bit flag indicating whether a replacement data ref follows.
    hasNewData: int2
    /// Optional replacement-data ref and any remaining extension data.
    newDataTail: RemainingBitsAndRefs
}

/// All ordinary internal bodies accepted by Invoice revision 9.
type TonpayInvoiceV9IncomingMessage =
    | TonpayInvoiceV9Pay
    | TonpayInvoiceV9Edit
    | TonpayInvoiceV9Deactivate
    | TonpayInvoiceV9Activate
    | TonpayInvoiceV9Upgrade

/// Opcode-zero payment memo emitted to the merchant and change payer.
///
/// Empty refund bodies are exported separately as `TonpayInvoiceV9EmptyBody`
/// because tagged and untagged bodies cannot share an automatically
/// discriminated Tolk union.
type TonpayInvoiceV9OutgoingMessage = TonpayInvoiceV9Text

/// Full Invoice data returned by `get_invoice_data`.
struct TonpayInvoiceV9DataReply {
    /// Store that deployed the Invoice.
    store: address
    /// Merchant controlling the Invoice.
    merchant: address
    /// Fee beneficiary receiving 2 percent of the payment.
    beneficiary: address
    /// Signed customer-presence flag.
    hasCustomer: int
    /// Customer address cell.
    customer: cell
    /// Invoice identifier text cell.
    invoiceId: cell
    /// Merchant metadata text cell.
    metadata: cell
    /// Required amount in nanograms.
    amount: int
    /// Signed paid flag.
    paid: int
    /// Signed activity flag.
    active: int
    /// Invoice version constant, equal to 9.
    version: int
}

/// Invoice revision-9 exit codes.
enum TonpayInvoiceV9Errors {
    /// Invoice is inactive.
    InvoiceDeactivated = 61441
    /// Invoice was already paid.
    InvoiceAlreadyPaid = 61442
    /// Attached GRAM does not cover the required amount.
    NotEnoughTon = 61443
    /// Sender does not match the enforced customer or Store-provided payer.
    InvalidCustomer = 61444
    /// Paid Invoice can no longer be edited.
    InvoiceFinalized = 61445
    /// Sender is not authorized for the requested administrative operation.
    Unauthorized = 3840
    /// Incoming opcode is not supported by Invoice revision 9.
    UnsupportedOperation = 65535
}

/// Return the deploying Store address.
get fun get_invoice_store(): address {
    throw 0;
}

/// Return the controlling merchant address.
get fun get_invoice_merchant(): address {
    throw 0;
}

/// Return the fee beneficiary address.
get fun get_invoice_beneficiary(): address {
    throw 0;
}

/// Return the signed customer-presence flag.
get fun get_invoice_has_customer(): int {
    throw 0;
}

/// Return the referenced customer-address cell.
get fun get_invoice_customer(): cell {
    throw 0;
}

/// Return the referenced invoice-id text cell.
get fun get_invoice_id(): cell {
    throw 0;
}

/// Return the referenced merchant-metadata text cell.
get fun get_invoice_metadata(): cell {
    throw 0;
}

/// Return the required amount in nanograms.
get fun get_invoice_amount(): int {
    throw 0;
}

/// Return the signed paid flag.
get fun get_invoice_paid(): int {
    throw 0;
}

/// Return the signed activity flag.
get fun get_invoice_active(): int {
    throw 0;
}

/// Return the Invoice version constant, equal to 9.
get fun get_invoice_version(): int {
    throw 0;
}

/// Return all Invoice fields and the version constant.
get fun get_invoice_data(): TonpayInvoiceV9DataReply {
    throw 0;
}
