// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: b61041a58a7980b946e8fb9e198e3c904d24799ffa36574ea4251c41a566f581

contract WalletV3r1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingExternal: WalletV3r1IncomingExternalMessage
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
type WalletV3r1IncomingExternalMessage = WalletSignedV3

get fun seqno(): uint32 {
    return 0;
}
