// Generated from XML ABI schemas.
// Source schema: schemas/tonkeeper_2fa.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.
// Code hash: c5ef19df22aee8b707bd7a181174e400a4225223c5ae40d8320f5ddd707d34a1

contract Tonkeeper2fa {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tonkeeper_2fa.xml"
    incomingMessages: Tonkeeper2faIncomingMessage
    incomingExternal: Tonkeeper2faIncomingExternalMessage
}

struct Tonkeeper2faSignedRefWithSeedSignature {
    seedSignature: bits512
}

struct Tonkeeper2faSignedExternalRefWithSeedSignature {
    seedSignature: bits512
}

// TL-B helper types referenced by messages.
struct Certificate {
    data: CertificateData2Fa
    signature: bits512
}

struct (0xb15f2c8c) SendActions {
    seqno: uint32
    validUntil: uint64
    msg: cell
    mode: uint8
}

struct (0x9d8084d6) RemoveExtension {
    seqno: uint32
    validUntil: uint64
}

struct (0x23d9c15c) Delegation {
    seqno: uint32
    validUntil: uint64
    newStateInit: cell
    forwardAmount: coins
}

struct (0xde82b501) CancelDelegation {
    seqno: uint32
    validUntil: uint64
}

struct CertificateData {
    validUntil: uint64
    pubkey: bits256
}

type Certificate2Fa = Certificate

type Payload2Fa =
    | SendActions
    | RemoveExtension
    | Delegation
    | CancelDelegation

type CertificateData2Fa = CertificateData

// TL-B message bodies.
struct (0x53684037) Tonkeeper2faSigned {
    refWithCertificate: Cell<Certificate2Fa>
    refWithSeedSignature: Cell<Tonkeeper2faSignedRefWithSeedSignature>
    payload: cell
    certificateSignature: bits512
}

struct Tonkeeper2faSignedExternal {
    refWithCertificate: Cell<Certificate2Fa>
    refWithSeedSignature: Cell<Tonkeeper2faSignedExternalRefWithSeedSignature>
    payload: cell
    certificateSignature: bits512
}

// Message unions used by Acton ABI.
type Tonkeeper2faIncomingMessage = Tonkeeper2faSigned

type Tonkeeper2faIncomingExternalMessage = Tonkeeper2faSignedExternal

struct GetDelegationStateStateParams {
    newStateInit: cell
    paymentPerPeriod: coins
}

struct GetDelegationStateReply {
    delegationStarted: bool
    recoveryBlockedUntil: uint64
    stateParams: GetDelegationStateStateParams
}

get fun get_wallet_addr(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

get fun get_root_pubkey(): uint256 {
    return 0;
}

get fun get_seed_pubkey(): uint256 {
    return 0;
}

get fun get_delegation_state(): GetDelegationStateReply {
    return {
        delegationStarted: false,
        recoveryBlockedUntil: 0,
        stateParams: {
        newStateInit: createEmptyCell(),
        paymentPerPeriod: 0,
    },
    };
}

get fun get_estimated_attached_value(forwardMsg: cell, msgActions: int, extendedActions: int): coins {
    return 0;
}
