/// Curated ABI for the Bidask DLMM internal liquidity vault.
contract BidaskInternalLiquidityVault {
    author: "Bidask Protocol"
    version: "1.0"
    description: "Bidask DLMM temporary vault for collecting two-sided liquidity deposit data before notifying the Pool."
    storage: BidaskInternalLiquidityVaultStorage
    incomingMessages: BidaskInternalLiquidityVaultIncomingMessage
    outgoingMessages: BidaskInternalLiquidityVaultOutgoingMessage
    forceAbiExport: BidaskLiquidityBinGroup
}

/// Runtime storage decoded from the live vault data cell.
struct BidaskInternalLiquidityVaultStorage {
    /// Liquidity provider address stored for the eventual Pool notification.
    userAddress: address
    /// Pool address that deployed and later receives the liquidity notification.
    poolAddress: address
    /// First pool asset amount accumulated by the temporary vault, encoded as `Coins`.
    amountX: coins
    /// Second pool asset amount accumulated by the temporary vault, encoded as `Coins`.
    amountY: coins
}

/// Amount pair for one liquidity bin inside a four-bin dictionary group.
struct BidaskLiquidityBinAmounts {
    /// Amount of the first pool asset assigned to the bin.
    amountX: coins
    /// Amount of the second pool asset assigned to the bin.
    amountY: coins
}

/// SDK-compatible dictionary value for group key `floor(bin / 4)`.
struct BidaskLiquidityBinGroup {
    /// Amounts for bin `groupKey * 4`.
    bin0: BidaskLiquidityBinAmounts
    /// Amounts for bin `groupKey * 4 + 1`.
    bin1: BidaskLiquidityBinAmounts
    /// Amounts for bin `groupKey * 4 + 2`.
    bin2: BidaskLiquidityBinAmounts
    /// Amounts for bin `groupKey * 4 + 3`.
    bin3: BidaskLiquidityBinAmounts
}

/// Pool-to-vault message that saves one side, or part, of a liquidity deposit.
struct (0x214ad1d2) BidaskSaveLiquidityInfo {
    /// Query id copied from the user liquidity operation.
    queryId: uint64
    /// First pool asset amount carried by this save message.
    amountX: coins
    /// Second pool asset amount carried by this save message.
    amountY: coins
    /// Deposit mode; saved SDK names are `Initial = 0`, `Add = 1`, and `Update = 2`.
    depositType: uint3
    /// Signed group key to four-bin amount group, matching SDK `createLiquidityProvideDict`.
    liquidityDict: map<int32, BidaskLiquidityBinGroup>
    /// Optional rejection payload returned with liquidity refunds.
    rejectPayload: cell?
    /// Optional success payload forwarded after liquidity notification.
    forwardPayload: cell?
}

/// Vault-to-pool message emitted after the vault combines saved liquidity sides.
struct (0xaf31d23f) BidaskAddingLiquidityNotify {
    /// Query id copied from the saved liquidity operation.
    queryId: uint64
    /// Original liquidity provider address stored by the vault.
    userAddress: address
    /// Combined first pool asset amount.
    amountX: coins
    /// Combined second pool asset amount.
    amountY: coins
    /// Deposit mode; saved SDK names are `Initial = 0`, `Add = 1`, and `Update = 2`.
    depositType: uint3
    /// Signed group key to four-bin amount group, matching SDK `createLiquidityProvideDict`.
    liquidityDict: map<int32, BidaskLiquidityBinGroup>
    /// Optional rejection payload returned with liquidity refunds.
    rejectPayload: cell?
    /// Optional success payload forwarded after liquidity notification.
    forwardPayload: cell?
}

/// Internal messages accepted by the temporary liquidity vault.
type BidaskInternalLiquidityVaultIncomingMessage = BidaskSaveLiquidityInfo

/// Internal messages emitted by the temporary liquidity vault.
type BidaskInternalLiquidityVaultOutgoingMessage = BidaskAddingLiquidityNotify

/// Stack reply for schema-defined `get_liquidity_data`.
struct GetLiquidityDataReply {
    /// Stored liquidity provider address.
    userAddress: address
    /// Stored Pool address.
    poolAddress: address
    /// Stored first asset amount returned as a stack integer.
    amountX: int
    /// Stored second asset amount returned as a stack integer.
    amountY: int
}

/// Schema-defined getter; live method-id extraction is blocked by library-reference code.
get fun get_liquidity_data(): GetLiquidityDataReply {
    return {
        userAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        poolAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        amountX: 0,
        amountY: 0,
    };
}
