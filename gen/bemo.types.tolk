// Generated from XML ABI schemas.
// Source schema: schemas/bemo.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Bemo {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/bemo.xml"
    incomingMessages: BemoIncomingMessage
}

// TL-B message bodies.
struct (0x4253c4d5) BemoStake {
    queryId: uint64
    forwardTonAmount: coins
    forwardPayload: cell?
}

struct (0x492ab1b3) BemoUnstake {
    index: uint64
    owner: address
    tonAmount: coins
    jettonAmount: coins
    forwardPayload: cell?
}

struct (0x10a1ce75) BemoDeployUnstakeRequest {
    queryId: uint64
    ownerAddress: address
    withdrawTonAmount: coins
    withdrawJettonAmount: coins
    forwardPayload: cell?
    lockupTimestamp: uint32
}

struct (0x90c80a07) BemoUnstakeNotification {
    queryId: uint64
    forwardPayload: cell?
}

struct (0x38633538) BemoReturnUnstakeRequest {
    lockupTimestamp: uint32
}

// Message unions used by Acton ABI.
type BemoIncomingMessage =
    | BemoStake
    | BemoUnstake
    | BemoDeployUnstakeRequest
    | BemoUnstakeNotification
    | BemoReturnUnstakeRequest
