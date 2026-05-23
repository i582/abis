// Generated from XML ABI schemas.
// Source schema: schemas/wallets.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: 11acad7955844090f283bf238bc1449871f783e7cc0979408d3f4859483e8525

contract WalletHighloadV3r1 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/wallets.xml"
    incomingExternal: WalletHighloadV3r1IncomingExternalMessage
}

// TL-B helper types referenced by messages.
struct MsgInner {
    subwalletId: uint32
    messageToSend: cell
    sendMode: uint8
    queryId: HighloadV3QueryId
    createdAt: uint64
    timeout: uint22
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

struct QueryId {
    shift: uint13
    bitNumber: uint10
}

type HighloadV3MsgInner = MsgInner

type MessageRelaxed =
    | MessageInternal
    | MessageExtOut

type HighloadV3QueryId = QueryId

// TL-B message bodies.
struct HighloadWalletSignedV3 {
    signature: bits512
    msg: Cell<HighloadV3MsgInner>
}

// Message unions used by Acton ABI.
type WalletHighloadV3r1IncomingExternalMessage = HighloadWalletSignedV3

get fun get_public_key(): int {
    return 0;
}

get fun get_subwallet_id(): uint32 {
    return 0;
}

get fun get_timeout(): uint32 {
    return 0;
}
