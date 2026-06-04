/// TONCO AccountV3 temporary liquidity account interface.
contract ToncoAccount {
    author: "Algebra / TONCO"
    version: "1.0"
    description: "Curated TONCO AccountV3 ABI for pending concentrated-liquidity mint balances, user refund/reset commands, and Pool mint callbacks"
    storage: ToncoAccountStorage
    incomingMessages: ToncoAccountIncomingMessage
    outgoingMessages: ToncoAccountOutgoingMessage
}

/// Runtime AccountV3 storage loaded from the root data cell.
struct ToncoAccountStorage {
    /// User that owns this temporary mint account.
    userAddress: address
    /// TONCO Pool that created and controls this account.
    poolAddress: address
    /// Referenced token balance and minimum-enough values.
    balances: Cell<ToncoAccountBalances>
}

/// Referenced pending liquidity balances stored by AccountV3.
struct ToncoAccountBalances {
    /// Pending amount of pool token0, in token basic units.
    amount0: coins
    /// Pending amount of pool token1, in token basic units.
    amount1: coins
    /// Required token0 threshold for the pending mint order.
    enough0: coins
    /// Required token1 threshold for the pending mint order.
    enough1: coins
}

/// Pool-originated command that adds pending liquidity balances to an account.
struct (0x3ebe5431) Accountv3AddLiquidity {
    /// Query id propagated through the add-liquidity flow.
    queryId: uint64
    /// Additional token0 amount to store, in token basic units.
    newAmount0: coins
    /// Additional token1 amount to store, in token basic units.
    newAmount1: coins
    /// Replacement or accumulated token0 enough threshold.
    newEnough0: coins
    /// Replacement or accumulated token1 enough threshold.
    newEnough1: coins
    /// Liquidity amount requested for the target position.
    liquidity: uint128
    /// Lower tick boundary for the target position.
    tickLower: int24
    /// Upper tick boundary for the target position.
    tickUpper: int24
}

/// User command that returns excess TON after preserving account storage reserve.
struct (0x42a0fb43) Accountv3ResetGas {
    /// Query id for tracing the reset-gas command.
    queryId: uint64
}

/// User command that asks the pool to refund pending token balances.
struct (0x0bf3f447) Accountv3RefundMe {
    /// Query id copied into the refund flow.
    queryId: uint64
}

/// Account-to-Pool callback that attempts to mint a position from funded balances.
struct (0x81702ef8) Poolv3Mint {
    /// Query id copied from the account operation that triggered minting.
    queryId: uint64
    /// Token0 amount funded for the mint, in token basic units.
    amount0Funded: coins
    /// Token1 amount funded for the mint, in token basic units.
    amount1Funded: coins
    /// Position owner that should receive the minted Position NFT.
    recipient: address
    /// Liquidity amount to mint.
    liquidity: uint128
    /// Lower tick boundary for the minted position.
    tickLower: int24
    /// Upper tick boundary for the minted position.
    tickUpper: int24
}

/// Internal message bodies accepted by TONCO AccountV3.
type ToncoAccountIncomingMessage =
    | Accountv3AddLiquidity
    | Accountv3ResetGas
    | Accountv3RefundMe

/// Internal message body emitted by TONCO AccountV3 toward its pool.
type ToncoAccountOutgoingMessage = Poolv3Mint

/// Structured return value of `get_account_data`.
struct GetAccountDataReply {
    /// User that owns this temporary mint account.
    userAddress: address
    /// TONCO Pool paired with this account.
    poolAddress: address
    /// Pending token0 amount, in token basic units.
    amount0: int
    /// Pending token1 amount, in token basic units.
    amount1: int
    /// Token0 enough threshold for the pending mint order.
    enough0: int
    /// Token1 enough threshold for the pending mint order.
    enough1: int
}

/// Return AccountV3 owner, pool, pending token balances, and enough thresholds.
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
