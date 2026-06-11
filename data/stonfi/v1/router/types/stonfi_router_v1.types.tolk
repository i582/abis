/// Low-level ABI for the STON.fi DEX v1 Router.
contract StonfiRouterV1 {
    author: "STON.fi"
    version: "1.0"
    description: "Curated low-level STON.fi DEX v1 Router ABI for storage, getters, Jetton transfer payloads, Pool routing, async getter messages, and admin operations."
    storage: StonfiRouterV1Storage
    incomingMessages: StonfiRouterV1IncomingMessage
    outgoingMessages: StonfiRouterV1OutgoingMessage
    forceAbiExport: StonfiRouterV1TempUpgrade
        | StonfiRouterV1PayToParams
        | StonfiRouterV1SetFeesPoolInfo
        | StonfiRouterV1SwapForwardPayload
        | StonfiRouterV1ProvideLpForwardPayload
        | StonfiRouterV1PoolSwapAddresses
}

/// Persistent Router state stored in the root data cell.
struct StonfiRouterV1Storage {
    /// One-bit Router lock flag; locked Routers refund swap and liquidity transfer notifications.
    isLocked: uint1
    /// Contract admin account authorized to run Router governance operations.
    adminAddress: address
    /// Code of the LP wallet contract used for deterministic Pool initialization.
    jettonLpWalletCode: cell
    /// Code of the liquidity Pool contract derived for token-wallet pairs.
    poolCode: cell
    /// Code of the LP account contract used by derived Pools.
    lpAccountCode: cell
    /// Pending code/admin upgrade state stored as a referenced cell.
    tempUpgrade: Cell<StonfiRouterV1TempUpgrade>
}

/// Pending Router code and admin upgrade data.
struct StonfiRouterV1TempUpgrade {
    /// Unix timestamp when the pending code upgrade may be finalized, or zero.
    codeUpgradeDeadline: uint64
    /// Unix timestamp when the pending admin upgrade may be finalized, or zero.
    adminUpgradeDeadline: uint64
    /// Pending admin address, or the configured hole address when no admin upgrade is active.
    pendingAdminAddress: address
    /// Pending Router code cell, or an empty cell when no code upgrade is active.
    pendingCode: cell
}

/// Referenced `pay_to` params describing the token-wallet payouts requested by a Pool.
struct StonfiRouterV1PayToParams {
    /// Amount of the first token sent through the corresponding Router-owned Jetton wallet.
    amount0Out: coins
    /// Router-owned wallet address of the first token.
    token0Address: address
    /// Amount of the second token sent through the corresponding Router-owned Jetton wallet.
    amount1Out: coins
    /// Router-owned wallet address of the second token.
    token1Address: address
}

/// Referenced token-wallet pair used by admin `set_fees` to select the derived Pool.
struct StonfiRouterV1SetFeesPoolInfo {
    /// Router-owned wallet address of the first token.
    jettonWallet0: address
    /// Router-owned wallet address of the second token.
    jettonWallet1: address
}

/// User Jetton forward payload for swapping one Jetton type through the Router.
struct (0x25938561) StonfiRouterV1SwapForwardPayload {
    /// Router-owned wallet address of the other token in the pair.
    tokenWallet: address
    /// Minimum required output token amount.
    minOut: coins
    /// Address receiving output tokens after the swap.
    toAddress: address
    /// One-bit referral flag; when set, `refAddressTail` contains a referral MsgAddress.
    hasRefAddress: uint1
    /// Tail is empty when `hasRefAddress` is zero, otherwise it contains the referral address without an extra Maybe tag.
    refAddressTail: RemainingBitsAndRefs
}

/// User Jetton forward payload for adding liquidity through the Router.
struct (0xfcf9e58f) StonfiRouterV1ProvideLpForwardPayload {
    /// Router-owned wallet address of the other token in the pair.
    tokenWallet: address
    /// Minimum required LP token amount.
    minLpOut: coins
}

/// Referenced address cell carried by Router-to-Pool `swap`.
struct StonfiRouterV1PoolSwapAddresses {
    /// Original user address reported by the inbound Jetton transfer notification.
    fromUser: address
    /// Tail is empty for non-referral swaps, otherwise it contains the referral address.
    referralAddressTail: RemainingBitsAndRefs
}

/// Pool-originated payout or refund request that makes the Router transfer Jettons.
struct (0xf93bb43f) StonfiRouterV1PayTo {
    /// Query id copied from the upstream Pool flow.
    queryId: uint64
    /// Owner address receiving the outgoing Jetton transfer.
    owner: address
    /// STON.fi status code appended to the outgoing Jetton forward payload.
    exitCode: uint32
    /// One-bit selector for `params`; value `1` means the params are stored in the following ref.
    paramsAsRef: uint1
    /// Referenced payout amounts and token-wallet addresses.
    params: Cell<StonfiRouterV1PayToParams>
}

/// Jetton wallet notification received after a user token transfer to a Router-owned wallet.
struct (0x7362d09c) StonfiRouterV1JettonTransferNotification {
    /// Query id copied from the user Jetton transfer.
    queryId: uint64
    /// Jetton amount received by the Router-owned wallet.
    jettonAmount: coins
    /// User address reported by the notifying Jetton wallet.
    fromAddress: address
    /// Raw Jetton `Either Cell ^Cell` forward-payload tail containing a swap or provide-lp payload ref.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin request that changes fee parameters for a derived Pool.
struct (0x355423e5) StonfiRouterV1SetFees {
    /// Caller-selected query id copied into the outgoing Pool message.
    queryId: uint64
    /// New liquidity-pool fee value.
    newLpFee: uint8
    /// New protocol fee value.
    newProtocolFee: uint8
    /// New referral fee value.
    newRefFee: uint8
    /// Address that receives protocol fees.
    newProtocolFeeAddress: address
    /// Referenced token-wallet pair selecting the derived Pool.
    poolInfo: Cell<StonfiRouterV1SetFeesPoolInfo>
}

/// Admin request that asks a derived Pool to collect protocol fees.
struct (0x1fcb7d3d) StonfiRouterV1CollectFees {
    /// Caller-selected query id copied into the outgoing Pool message.
    queryId: uint64
    /// Router-owned wallet address of the first token.
    jettonWallet0: address
    /// Router-owned wallet address of the second token.
    jettonWallet1: address
}

/// Admin request that locks user transfer-notification routing.
struct (0x878f9b0e) StonfiRouterV1Lock {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that unlocks user transfer-notification routing.
struct (0x6ae4b0ef) StonfiRouterV1Unlock {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that starts a delayed Router code upgrade.
struct (0xdf1e233d) StonfiRouterV1InitCodeUpgrade {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
    /// New Router code cell staged in the upgrade state.
    newCode: cell
}

/// Admin request that starts a delayed Router admin change.
struct (0x2fb94384) StonfiRouterV1InitAdminUpgrade {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
    /// New Router admin address staged in the upgrade state.
    newAdminAddress: address
}

/// Admin request that cancels a pending Router code upgrade.
struct (0x357ccc67) StonfiRouterV1CancelCodeUpgrade {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that cancels a pending Router admin change.
struct (0xa4ed9981) StonfiRouterV1CancelAdminUpgrade {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that finalizes matured Router code and admin upgrades.
struct (0x6378509f) StonfiRouterV1FinalizeUpgrades {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that returns Router excess TON to the admin after reserving storage balance.
struct (0x42a0fb43) StonfiRouterV1ResetGas {
    /// Caller-selected query id parsed by the Router dispatcher.
    queryId: uint64
}

/// Admin request that forwards `reset_gas` to a derived Pool.
struct (0xf6aa9737) StonfiRouterV1ResetPoolGas {
    /// Caller-selected query id copied into the outgoing Pool message.
    queryId: uint64
    /// Router-owned wallet address of the first token.
    jettonWallet0: address
    /// Router-owned wallet address of the second token.
    jettonWallet1: address
}

/// On-chain getter request asking the Router to derive a Pool address for two token wallets.
struct (0xd1db969b) StonfiRouterV1GetterPoolAddressRequest {
    /// Caller-selected query id copied into the async response.
    queryId: uint64
    /// Router-owned wallet address of the first token.
    token0: address
    /// Router-owned wallet address of the second token.
    token1: address
}

/// On-chain getter response containing the derived Pool address.
struct (0xd1db969b) StonfiRouterV1GetterPoolAddressResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// Deterministically derived Pool address.
    poolAddress: address
}

/// Router-to-Pool swap message built after a valid Jetton transfer notification.
struct (0x25938561) StonfiRouterV1PoolSwap {
    /// Query id copied from the user Jetton transfer notification.
    queryId: uint64
    /// Address receiving output tokens after the swap.
    toAddress: address
    /// Router-owned wallet address that received the input Jettons.
    senderAddress: address
    /// Input Jetton amount credited to the swap.
    jettonAmount: coins
    /// Minimum required output token amount.
    minOut: coins
    /// One-bit referral flag; when set, `addrs` carries a referral address after `fromUser`.
    hasRefAddress: uint1
    /// Referenced original-user address cell with optional referral-address tail.
    addrs: Cell<StonfiRouterV1PoolSwapAddresses>
}

/// Router-to-Pool liquidity provision message built after a valid Jetton transfer notification.
struct (0xfcf9e58f) StonfiRouterV1PoolProvideLp {
    /// Query id copied from the user Jetton transfer notification.
    queryId: uint64
    /// User address whose LP account receives the liquidity update.
    ownerAddress: address
    /// Minimum required LP token amount.
    minLpOut: coins
    /// Amount credited as the Pool's first token side.
    amount0: coins
    /// Amount credited as the Pool's second token side.
    amount1: coins
}

/// Router-to-Jetton-wallet transfer body used for payouts and refunds.
struct (0x0f8a7ea5) StonfiRouterV1JettonTransfer {
    /// Query id copied from the Pool payout or refund flow.
    queryId: uint64
    /// Jetton amount transferred by the Router-owned wallet.
    amount: coins
    /// Owner address receiving the Jettons.
    destination: address
    /// Address receiving Jetton wallet excesses.
    responseDestination: address
    /// Optional standard Jetton custom payload; Router v1 transfers leave it absent.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward-payload tail; Router v1 encodes a 32-bit status inline.
    forwardPayload: RemainingBitsAndRefs
}

/// Router-to-Pool fee update emitted from admin `set_fees`.
struct (0x355423e5) StonfiRouterV1PoolSetFees {
    /// Query id copied from the admin request.
    queryId: uint64
    /// New liquidity-pool fee value.
    newLpFee: uint8
    /// New protocol fee value.
    newProtocolFee: uint8
    /// New referral fee value.
    newRefFee: uint8
    /// Address that receives protocol fees.
    newProtocolFeeAddress: address
}

/// Router-to-Pool protocol-fee collection request emitted from admin `collect_fees`.
struct (0x1fcb7d3d) StonfiRouterV1PoolCollectFees {
    /// Query id copied from the admin request.
    queryId: uint64
}

/// Router-to-Pool gas reset request emitted from admin `reset_pool_gas`.
struct (0x42a0fb43) StonfiRouterV1PoolResetGas {
    /// Query id copied from the admin request.
    queryId: uint64
}

/// Internal message bodies accepted by STON.fi Router v1.
type StonfiRouterV1IncomingMessage =
    | StonfiRouterV1PayTo
    | StonfiRouterV1JettonTransferNotification
    | StonfiRouterV1SetFees
    | StonfiRouterV1CollectFees
    | StonfiRouterV1Lock
    | StonfiRouterV1Unlock
    | StonfiRouterV1InitCodeUpgrade
    | StonfiRouterV1InitAdminUpgrade
    | StonfiRouterV1CancelCodeUpgrade
    | StonfiRouterV1CancelAdminUpgrade
    | StonfiRouterV1FinalizeUpgrades
    | StonfiRouterV1ResetGas
    | StonfiRouterV1ResetPoolGas
    | StonfiRouterV1GetterPoolAddressRequest

/// Internal message bodies emitted by STON.fi Router v1.
type StonfiRouterV1OutgoingMessage =
    | StonfiRouterV1PoolSwap
    | StonfiRouterV1PoolProvideLp
    | StonfiRouterV1JettonTransfer
    | StonfiRouterV1PoolSetFees
    | StonfiRouterV1PoolCollectFees
    | StonfiRouterV1PoolResetGas
    | StonfiRouterV1GetterPoolAddressResponse

/// Structured result returned by `get_router_data`.
struct StonfiRouterV1DataReply {
    /// True when transfer-notification routing is locked.
    isLocked: bool
    /// Contract admin account.
    adminAddress: address
    /// Raw upgrade-state cell returned by the getter.
    tempUpgrade: cell
    /// Code of the Router's liquidity Pool contract.
    poolCode: cell
    /// Code of the LP wallet contract.
    jettonLpWalletCode: cell
    /// Code of the LP account contract.
    lpAccountCode: cell
}

/// Return the deterministic Pool address for a pair of Router-owned Jetton wallets.
get fun get_pool_address(token0: address, token1: address): address {
    throw 0;
}

/// Return Router lock/admin state, upgrade state, and contract code cells.
get fun get_router_data(): StonfiRouterV1DataReply {
    throw 0;
}
