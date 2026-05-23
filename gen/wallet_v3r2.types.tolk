// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 84dafa449f98a6987789ba232358072bc0f76dc4524002a5d0918b9a75d2d599

contract WalletV3r2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingExternal: WalletV3r2IncomingExternalMessage
}

// TL-B message bodies.
struct WalletSignedV3 {
    signature: bits512
    subwalletId: uint32
    validUntil: uint32
    seqno: uint32
    payload: cell
}

// Message unions used by Acton ABI.
type WalletV3r2IncomingExternalMessage = WalletSignedV3

get fun get_public_key(): int {
    return 0;
}

get fun seqno(): uint32 {
    return 0;
}
