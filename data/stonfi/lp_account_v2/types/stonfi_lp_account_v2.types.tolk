/// STON.fi DEX v2 LP Account interface for pending liquidity deposits.
contract StonfiLpAccountV2 {
    author: "STON.fi"
    version: "2.0"
    description: "Curated STON.fi LP Account v2 interface aligned with docs.ston.fi terminology for get_lp_account_data, on-chain getter query/response, liquidity/refund/reset commands, and LPAccount-to-Pool callbacks; source-proven wire layout is preserved"
    storage: StonfiLpAccountV2Storage
    incomingMessages: StonfiLpAccountV2IncomingMessage
    outgoingMessages: StonfiLpAccountV2OutgoingMessage
}

/// Current LP Account state returned by `get_lp_account_data` and stored on-chain.
struct StonfiLpAccountV2Storage {
    /// Owner address of this LP Account.
    userAddress: address
    /// Pool address paired with this LP Account.
    poolAddress: address
    /// Stored balance of the first Jetton token, in basic token units.
    amount0: coins
    /// Stored balance of the second Jetton token, in basic token units.
    amount1: coins
}

/// Referenced refund and TON-excess destinations used by liquidity-add messages.
struct StonfiLpAccountV2RefundExcessFields {
    /// Address that receives tokens if liquidity minting is not successful.
    refundAddress: address
    /// Address that receives remaining TON excesses.
    excessAddress: address
}

/// Referenced receiver, refund, and TON-excess destinations in `cb_add_liquidity` additional data.
struct StonfiLpAccountV2CbAddLiquidityAdditionalFields {
    /// Owner address for newly minted liquidity tokens.
    toUserAddress: address
    /// Address that receives tokens if liquidity minting is not successful.
    refundAddress: address
    /// Address that receives remaining TON excesses.
    excessAddress: address
}

/// Pool-originated `add_liquidity` message that stores newly received token amounts and may trigger minting.
struct (0x50c6a654) StonfiLpAccountV2AddLiquidity {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Amount of the first Jetton token added to the stored LP Account balance.
    newAmount0: coins
    /// Amount of the second Jetton token added to the stored LP Account balance.
    newAmount1: coins
    /// Minimum required amount of liquidity tokens to receive; zero keeps funds pending.
    minLpOut: coins
    /// Forward TON amount used with `custom_payload_cs` in the eventual transfer notification.
    fwdAmount: coins
    /// If set, minting is attempted only when both stored token balances are non-zero.
    bothPositive: uint1
    /// Owner address for newly minted liquidity tokens.
    toUser: address
    /// Optional payload forwarded in the eventual LP token transfer notification.
    customPayloadCs: cell?
    /// Referenced refund and TON-excess destinations.
    additionalFields: Cell<StonfiLpAccountV2RefundExcessFields>
}

/// User-originated `refund_me` command that asks the pool to return stored token balances to the owner.
struct (0x132b9a2c) StonfiLpAccountV2RefundMe {
    /// Query id propagated to the refund callback.
    queryId: uint64
    /// Optional payload used for the first-token refund transfer.
    leftMaybePayload: cell?
    /// Optional payload used for the second-token refund transfer.
    rightMaybePayload: cell?
}

/// User-originated `direct_add_liquidity` command that consumes selected stored balances for liquidity minting.
struct (0x0ff8bfc6) StonfiLpAccountV2DirectAddLiquidity {
    /// Query id propagated through the direct liquidity operation.
    queryId: uint64
    /// Amount of the first Jetton token to use; zero means the full stored amount.
    am0: coins
    /// Amount of the second Jetton token to use; zero means the full stored amount.
    am1: coins
    /// Minimum required amount of liquidity tokens to receive; must be non-zero for this command.
    minLpOut: coins
    /// Forward TON amount used with `custom_payload_cs` in the eventual transfer notification.
    fwdAmount: coins
    /// Owner address for newly minted liquidity tokens.
    toUser: address
    /// Optional payload forwarded in the eventual LP token transfer notification.
    customPayloadCs: cell?
    /// Referenced refund and TON-excess destinations.
    additionalFields: Cell<StonfiLpAccountV2RefundExcessFields>
}

/// User-originated `reset_gas` command that reserves LP Account storage TON and returns the rest to the owner.
struct (0x29d22935) StonfiLpAccountV2ResetGas {
    /// Query id for the gas reset command.
    queryId: uint64
}

/// On-chain `getter_lp_account_data` request; response uses the same opcode with LP Account state appended.
struct (0x24cfc100) StonfiLpAccountV2GetterLpAccountDataRequest {
    /// Query id copied into the asynchronous getter response.
    queryId: uint64
}

/// `cb_add_liquidity` callback sent from LP Account to Pool with token amounts to mint as liquidity.
struct (0x06ecd527) StonfiLpAccountV2CbAddLiquidity {
    /// Query id propagated from the liquidity request.
    queryId: uint64
    /// Amount of the first Jetton token supplied for liquidity.
    totAm0: coins
    /// Amount of the second Jetton token supplied for liquidity.
    totAm1: coins
    /// Owner address of the LP Account that funded this callback.
    userAddress: address
    /// Minimum required amount of liquidity tokens to receive.
    minLpOut: coins
    /// Forward TON amount used with `custom_payload_cs` in the eventual transfer notification.
    fwdAmount: coins
    /// Optional payload forwarded in the eventual LP token transfer notification.
    customPayloadCs: cell?
    /// Referenced receiver, refund, and TON-excess destinations.
    additionalFields: Cell<StonfiLpAccountV2CbAddLiquidityAdditionalFields>
}

/// `cb_refund_me` callback sent from LP Account to Pool with stored balances to refund.
struct (0x0f98e2b8) StonfiLpAccountV2CbRefundMe {
    /// Query id propagated from the refund request.
    queryId: uint64
    /// Amount of the first Jetton token to refund through the pool/router path.
    totAm0: coins
    /// Amount of the second Jetton token to refund through the pool/router path.
    totAm1: coins
    /// Owner address of the LP Account being refunded.
    userAddress: address
    /// Optional payload used for the first-token refund transfer.
    leftMaybePayload: cell?
    /// Optional payload used for the second-token refund transfer.
    rightMaybePayload: cell?
}

/// Asynchronous `getter_lp_account_data` response sent to the requester with current LP Account state.
struct (0x24cfc100) StonfiLpAccountV2GetterLpAccountDataResponse {
    /// Query id copied from the asynchronous getter request.
    queryId: uint64
    /// Owner address of this LP Account.
    userAddress: address
    /// Pool address paired with this LP Account.
    poolAddress: address
    /// Stored balance of the first Jetton token, in basic token units.
    amount0: coins
    /// Stored balance of the second Jetton token, in basic token units.
    amount1: coins
}

/// Internal message bodies accepted by STON.fi LP Account v2.
type StonfiLpAccountV2IncomingMessage =
    | StonfiLpAccountV2AddLiquidity
    | StonfiLpAccountV2RefundMe
    | StonfiLpAccountV2DirectAddLiquidity
    | StonfiLpAccountV2ResetGas
    | StonfiLpAccountV2GetterLpAccountDataRequest

/// Internal message bodies emitted by STON.fi LP Account v2.
type StonfiLpAccountV2OutgoingMessage =
    | StonfiLpAccountV2CbAddLiquidity
    | StonfiLpAccountV2CbRefundMe
    | StonfiLpAccountV2GetterLpAccountDataResponse

/// Structured result returned by off-chain `get_lp_account_data`.
struct StonfiLpAccountV2DataReply {
    /// Owner address of this LP Account.
    userAddress: address
    /// Pool address paired with this LP Account.
    poolAddress: address
    /// Stored balance of the first Jetton token, in basic token units.
    amount0: int
    /// Stored balance of the second Jetton token, in basic token units.
    amount1: int
}

/// Returns the current LP Account owner, pool, and stored first/second Jetton balances.
get fun get_lp_account_data(): StonfiLpAccountV2DataReply {
    return {
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        amount0: 0,
        amount1: 0,
    };
}
