/// Payload-only ABI interface for invoice message bodies.
contract Invoices {
    author: "Unknown"
    version: "1.0"
    description: "Payload-only ABI for invoice_payload internal bodies and Jetton forward payloads."
    incomingMessages: InvoicesIncomingMessage
    forceAbiExport: InvoicesJettonPayload
}

/// Empty payment-provider URL marker.
struct (0x00) None {}

/// Ton-site payment-provider URL marker carrying a 256-bit site address/hash.
struct (0x01) Tonsite {
    /// Ton-site address/hash carried after the URL variant tag.
    address: bits256
}

/// Byte-tagged payment-provider URL variants embedded after the invoice id.
type PaymentProviderUrl =
    | None
    | Tonsite

/// Invoice body accepted as a regular internal message body.
struct (0x7aa23eb5) InvoicePayload {
    /// Opaque 128-bit invoice identifier.
    id: bits128
    /// Optional payment-provider URL selector.
    url: PaymentProviderUrl
}

/// Invoice body carried as a Jetton forward payload.
struct (0x7aa23eb5) InvoiceJettonPayload {
    /// Opaque 128-bit invoice identifier.
    id: bits128
    /// Optional payment-provider URL selector.
    url: PaymentProviderUrl
}

/// Incoming internal message union for direct invoice payload bodies.
type InvoicesIncomingMessage = InvoicePayload

/// Forced export for the same layout when embedded as a Jetton forward payload.
type InvoicesJettonPayload = InvoiceJettonPayload
