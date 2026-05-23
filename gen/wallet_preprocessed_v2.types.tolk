// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 45ebbce9b5d235886cb6bfe1c3ad93b708de058244892365c9ee0dfe439cb7b5

contract WalletPreprocessedV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingExternal: WalletPreprocessedV2IncomingExternalMessage
}

// TL-B helper types referenced by messages.
struct MsgInner {
    validUntil: uint64
    seqNo: uint16
    actions: cell
}

type PreprocessedWalletV2MsgInner = MsgInner

// TL-B message bodies.
struct PreprocessedWalletSignedV2 {
    sign: bits512
    msg: Cell<PreprocessedWalletV2MsgInner>
}

// Message unions used by Acton ABI.
type WalletPreprocessedV2IncomingExternalMessage = PreprocessedWalletSignedV2
