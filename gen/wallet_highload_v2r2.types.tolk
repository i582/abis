// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 203dd4f358adb49993129aa925cac39916b68a0e4f78d26e8f2c2b69eafa5679

contract WalletHighloadV2r2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingExternal: WalletHighloadV2r2IncomingExternalMessage
}

// TL-B helper types referenced by messages.
struct SendMsg {
    mode: uint8
    message: cell
}

struct (0b0) MessageInternal {
    ihrDisabled: bool
    bounce: bool
    bounced: bool
    src: address
    dest: address
    value: (coins, ExtraCurrenciesMap)
    ihrFee: coins
    fwdFee: coins
    createdLt: uint64
    createdAt: uint32
    init: RemainingBitsAndRefs?
    body: RemainingBitsAndRefs
}

struct (0b11) MessageExtOut {
    src: address
    dest: address
    createdLt: uint64
    createdAt: uint32
    init: RemainingBitsAndRefs?
    body: RemainingBitsAndRefs
}

type SendMessageAction = SendMsg

type MessageRelaxed =
    | MessageInternal
    | MessageExtOut

// TL-B message bodies.
struct HighloadWalletSignedV2 {
    signature: bits512
    subwalletId: uint32
    queryId: uint64
    payload: map<uint16, SendMessageAction>
}

// Message unions used by Acton ABI.
type WalletHighloadV2r2IncomingExternalMessage = HighloadWalletSignedV2

get fun get_public_key(): int {
    return 0;
}
