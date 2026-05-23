// Generated from XML ABI schemas.
// Source schema: schemas/tonco.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract ToncoAccount {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/tonco.xml"
    incomingMessages: ToncoAccountIncomingMessage
    outgoingMessages: ToncoAccountOutgoingMessage
}

// TL-B parser notes:
// - type_1: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 58]).
// - type_2: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).
// - type_3: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).
// - type_4: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (cannot apply Semantics to [match failed at position 60]).

// TL-B message bodies.
struct (0x3ebe5431) Accountv3AddLiquidity {
    queryId: uint64
    newAmount0: coins
    newAmount1: coins
    newEnough0: coins
    newEnough1: coins
    liquidity: uint128
    tickLower: int24
    tickUpper: int24
}

struct (0x81702ef8) Poolv3Mint {
    queryId: uint64
    amount0Funded: coins
    amount1Funded: coins
    recipient: address
    liquidity: uint128
    tickLower: int24
    tickUpper: int24
}

// Message unions used by Acton ABI.
type ToncoAccountIncomingMessage = Accountv3AddLiquidity

type ToncoAccountOutgoingMessage = Poolv3Mint

struct GetAccountDataReply {
    userAddress: address
    poolAddress: address
    amount0: int
    amount1: int
    enough0: int
    enough1: int
}

get fun get_account_data(): GetAccountDataReply {
    return {
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        amount0: 0,
        amount1: 0,
        enough0: 0,
        enough1: 0,
    };
}
