// Generated from XML ABI schemas.
// Source schema: schemas/invoices.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Invoices {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/invoices.xml"
    incomingMessages: InvoicesIncomingMessage
    forceAbiExport: InvoicesJettonPayload
}

// TL-B helper types referenced by messages.
struct (0x00) None {}

struct (0x01) Tonsite {
    address: bits256
}

type PaymentProviderUrl =
    | None
    | Tonsite

// TL-B message bodies.
struct (0x7aa23eb5) InvoicePayload {
    id: bits128
    url: cell
}

struct (0x7aa23eb5) InvoicePayload2 {
    id: bits128
    url: cell
}

// Message unions used by Acton ABI.
type InvoicesIncomingMessage = InvoicePayload

type InvoicesJettonPayload = InvoicePayload2
