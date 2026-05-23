// Generated from XML ABI schemas.
// Source schema: schemas/known.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Known {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/known.xml"
    incomingMessages: KnownIncomingMessage
    forceAbiExport: KnownJettonPayload | KnownNftPayload
}

// TL-B helper types referenced by messages.
struct NewBounceOriginalInfo {
    value: (coins, ExtraCurrenciesMap)
    createdLt: uint64
    createdAt: uint32
}

struct NewBounceComputePhaseInfo {
    gasUsed: uint32
    vmSteps: uint32
}

// TL-B message bodies.
struct (0xffffffff) Bounce {
    payload: cell
}

struct (0xfffffffe) BounceV2 {
    originalBody: cell
    originalInfo: Cell<NewBounceOriginalInfo>
    bouncedByPhase: uint8
    exitCode: int32
    computePhase: NewBounceComputePhaseInfo?
}

struct (0x00000000) TextComment {
    text: string
}

struct (0x2167da4b) EncryptedTextComment {
    cipherText: RemainingBitsAndRefs
}

struct (0xd53276db) Excess {
    queryId: uint64
}

struct (0xd372158c) TopUp {
    queryId: uint64
}

struct (0x1690c604) Credit {
    queryId: uint64
    amount: coins
}

struct (0x7b4b42e6) Approve {
    queryId: uint64
}

struct (0xe8a0abfe) Disapprove {
    queryId: uint64
}

struct (0x00000000) TextComment2 {
    text: string
}

struct (0x2167da4b) EncryptedTextComment2 {
    cipherText: RemainingBitsAndRefs
}

struct (0x00000000) TextComment3 {
    text: string
}

struct (0x2167da4b) EncryptedTextComment3 {
    cipherText: RemainingBitsAndRefs
}

// Message unions used by Acton ABI.
type KnownIncomingMessage =
    | Bounce
    | BounceV2
    | TextComment
    | EncryptedTextComment
    | Excess
    | TopUp
    | Credit
    | Approve
    | Disapprove

type KnownJettonPayload =
    | TextComment2
    | EncryptedTextComment2

type KnownNftPayload =
    | TextComment3
    | EncryptedTextComment3
