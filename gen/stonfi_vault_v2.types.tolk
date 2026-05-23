// Generated from XML ABI schemas.
// Source schema: schemas/ston-fi.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract StonfiVaultV2 {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/ston-fi.xml"
    incomingMessages: StonfiVaultV2IncomingMessage
    outgoingMessages: StonfiVaultV2OutgoingMessage
}

// TL-B message bodies.
struct (0x354bcdf4) StonfiWithdrawFeeV2 {
    queryId: uint64
}

struct (0x0490f09b) StonfiDepositRefFeeV2 {
    queryId: uint64
    jettonAmount: coins
    excessesAddress: address
}

struct (0x2100c922) StonfiVaultPayToV2 {
    queryId: uint64
    amountOut: coins
    tokenAddress: address
    toAddress: address
}

// Message unions used by Acton ABI.
type StonfiVaultV2IncomingMessage =
    | StonfiWithdrawFeeV2
    | StonfiDepositRefFeeV2

type StonfiVaultV2OutgoingMessage = StonfiVaultPayToV2

struct GetVaultDataReply {
    ownerAddress: address
    tokenAddress: address
    routerAddress: address
    depositedAmount: int
}

get fun get_vault_data(): GetVaultDataReply {
    return {
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        tokenAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        depositedAmount: 0,
    };
}
