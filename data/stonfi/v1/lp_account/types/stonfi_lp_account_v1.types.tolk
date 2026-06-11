/// STON.fi DEX v1 LP Account interface for pending liquidity deposits.
contract StonfiLpAccountV1 {
    author: "STON.fi"
    version: "1.0"
    description: "Curated STON.fi LP Account v1 interface for stored liquidity balances, add/refund/reset commands, LP Account callbacks, and account data getters"
    storage: StonfiLpAccountV1Storage
    incomingMessages: StonfiLpAccountV1IncomingMessage
    outgoingMessages: StonfiLpAccountV1OutgoingMessage
}

/// Current LP Account state stored on-chain.
struct StonfiLpAccountV1Storage {
    /// Owner address of this LP Account.
    userAddress: address
    /// Pool address paired with this LP Account.
    poolAddress: address
    /// Stored balance of the first Jetton token, in basic token units.
    amount0: coins
    /// Stored balance of the second Jetton token, in basic token units.
    amount1: coins
}

/// Pool-originated `add_liquidity` message that increases stored token balances and may trigger minting.
struct (0x3ebe5431) StonfiLpAccountV1AddLiquidity {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Amount of the first Jetton token added to the stored LP Account balance.
    newAmount0: coins
    /// Amount of the second Jetton token added to the stored LP Account balance.
    newAmount1: coins
    /// Minimum required amount of liquidity tokens to receive.
    minLpOut: coins
}

/// User-originated `refund_me` command that asks the pool to return stored token balances.
struct (0x0bf3f447) StonfiLpAccountV1RefundMe {
    /// Query id propagated to the refund callback.
    queryId: uint64
}

/// User-originated `direct_add_liquidity` command that consumes stored balances for liquidity minting.
struct (0x4cf82803) StonfiLpAccountV1DirectAddLiquidity {
    /// Query id propagated through the direct liquidity operation.
    queryId: uint64
    /// Amount of the first Jetton token to use for liquidity minting.
    amount0: coins
    /// Amount of the second Jetton token to use for liquidity minting.
    amount1: coins
    /// Minimum required amount of liquidity tokens to receive.
    minLpOut: coins
}

/// User-originated `reset_gas` command that reserves account storage TON and returns the rest to the owner.
struct (0x42a0fb43) StonfiLpAccountV1ResetGas {
    /// Query id for the gas reset command.
    queryId: uint64
}

/// On-chain `getter_lp_account_data` request; response uses the same opcode with LP Account state appended.
struct (0x1d439ae0) StonfiLpAccountV1GetterLpAccountDataRequest {
    /// Query id copied into the asynchronous getter response.
    queryId: uint64
}

/// `cb_add_liquidity` callback sent from LP Account to Pool with token amounts to mint as liquidity.
struct (0x56dfeb8a) StonfiLpAccountV1CbAddLiquidity {
    /// Query id propagated from the liquidity request.
    queryId: uint64
    /// Total amount of the first Jetton token supplied for liquidity.
    totalAmount0: coins
    /// Total amount of the second Jetton token supplied for liquidity.
    totalAmount1: coins
    /// Owner address of the LP Account that funded this callback.
    userAddress: address
    /// Minimum required amount of liquidity tokens to receive.
    minLpOut: coins
}

/// `cb_refund_me` callback sent from LP Account to Pool with stored balances to refund.
struct (0x89446a42) StonfiLpAccountV1CbRefundMe {
    /// Query id propagated from the refund request.
    queryId: uint64
    /// Total amount of the first Jetton token to refund through the pool path.
    totalAmount0: coins
    /// Total amount of the second Jetton token to refund through the pool path.
    totalAmount1: coins
    /// Owner address of the LP Account being refunded.
    userAddress: address
}

/// Asynchronous `getter_lp_account_data` response sent to the requester with current LP Account state.
struct (0x1d439ae0) StonfiLpAccountV1GetterLpAccountDataResponse {
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

/// Internal message bodies accepted by STON.fi LP Account v1.
type StonfiLpAccountV1IncomingMessage =
    | StonfiLpAccountV1AddLiquidity
    | StonfiLpAccountV1RefundMe
    | StonfiLpAccountV1DirectAddLiquidity
    | StonfiLpAccountV1ResetGas
    | StonfiLpAccountV1GetterLpAccountDataRequest

/// Internal message bodies emitted by STON.fi LP Account v1.
type StonfiLpAccountV1OutgoingMessage =
    | StonfiLpAccountV1CbAddLiquidity
    | StonfiLpAccountV1CbRefundMe
    | StonfiLpAccountV1GetterLpAccountDataResponse

/// Structured result returned by off-chain `get_lp_account_data`.
struct StonfiLpAccountV1DataReply {
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
get fun get_lp_account_data(): StonfiLpAccountV1DataReply {
    throw 0;
}
