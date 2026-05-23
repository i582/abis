// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 20834b7b72b112147e1b2fb457b84e74d1a30f04f737d4f62a668e9552d2b72f

contract WalletV5r1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingMessages: WalletV5r1IncomingMessage
    incomingExternal: WalletV5r1IncomingExternalMessage
}

// TL-B message bodies.
struct (0x73696e74) WalletSignedInternalV5r1 {
    walletId: uint32
    validUntil: uint32
    seqno: uint32
    actions: cell?
    extended: cell?
    signature: bits512
}

struct (0x6578746e) WalletExtensionActionV5r1 {
    queryId: uint64
    actions: cell?
    extended: cell?
}

struct (0x7369676e) WalletSignedExternalV5r1 {
    walletId: uint32
    validUntil: uint32
    seqno: uint32
    actions: cell?
    extended: cell?
    signature: bits512
}

// Message unions used by Acton ABI.
type WalletV5r1IncomingMessage =
    | WalletSignedInternalV5r1
    | WalletExtensionActionV5r1

type WalletV5r1IncomingExternalMessage = WalletSignedExternalV5r1

get fun seqno(): uint32 {
    return 0;
}

get fun get_public_key(): int {
    return 0;
}

get fun get_subwallet_id(): uint32 {
    return 0;
}

get fun get_extensions(): cell? {
    return null;
}

get fun is_signature_allowed(): bool {
    return false;
}
