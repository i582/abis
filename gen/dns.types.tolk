// Generated from XML ABI schemas.
// Source schema: schemas/dns.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract Dns {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/dns.xml"
    incomingMessages: DnsIncomingMessage
    outgoingMessages: DnsOutgoingMessage
}

// TL-B message bodies.
struct (0x4ed14b65) DnsBalanceRelease {
    queryId: uint64
}

struct (0x44beae41) ProcessGovernanceDecision {
    queryId: uint64
}

// Message unions used by Acton ABI.
type DnsIncomingMessage =
    | DnsBalanceRelease
    | ProcessGovernanceDecision

type DnsOutgoingMessage = DnsBalanceRelease

struct DnsresolveReply {
    resolvedBits: int64
    result: cell
}

get fun dnsresolve(domain: slice, category: int): DnsresolveReply {
    return {
        resolvedBits: 0,
        result: createEmptyCell(),
    };
}
