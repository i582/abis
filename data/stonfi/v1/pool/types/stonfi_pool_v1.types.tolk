/// STON.fi DEX v1 Pool interface for reserve accounting, routed swaps, liquidity callbacks, async getters, and LP Jetton minter methods.
contract StonfiPoolV1 {
    author: "STON.fi"
    version: "1.0"
    description: "Curated STON.fi Pool v1 ABI covering stored pool state, routed swap/provide_lp flows, LP account callbacks, fee operations, async getter messages, and LP Jetton minter discovery"
    storage: StonfiPoolV1Storage
    incomingMessages: StonfiPoolV1IncomingMessage
    outgoingMessages: StonfiPoolV1OutgoingMessage
    forceAbiExport: StonfiPoolV1ExtraData
        | StonfiPoolV1SwapRefBody
        | StonfiPoolV1PayToParams
        | StonfiPoolV1GetterPoolDataExtra
}

/// Root Pool state cell.
struct StonfiPoolV1Storage {
    /// Router address authorized for routed swap, liquidity, and fee-management messages.
    routerAddress: address
    /// Liquidity-provider fee value stored as an 8-bit unsigned integer.
    lpFee: uint8
    /// Protocol fee value stored as an 8-bit unsigned integer.
    protocolFee: uint8
    /// Referral fee value stored as an 8-bit unsigned integer.
    refFee: uint8
    /// Address of the first token wallet paired by the pool.
    token0Address: address
    /// Address of the second token wallet paired by the pool.
    token1Address: address
    /// Total supply of LP Jettons, in basic token units.
    totalSupplyLp: coins
    /// Referenced cell with collected protocol fees, fee recipient, and reserves.
    extra: Cell<StonfiPoolV1ExtraData>
    /// Code cell used to derive and deploy LP Jetton wallets.
    jettonLpWalletCode: cell
    /// Code cell used to derive and deploy user LP Accounts.
    lpAccountCode: cell
}

/// Referenced Pool state extension.
struct StonfiPoolV1ExtraData {
    /// Collected protocol fee amount for the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fee amount for the second token, in basic token units.
    collectedToken1ProtocolFee: coins
    /// Address receiving collected protocol fees.
    protocolFeeAddress: address
    /// Current reserve amount of the first token, in basic token units.
    reserve0: coins
    /// Current reserve amount of the second token, in basic token units.
    reserve1: coins
}

/// Referral cell used by Router-originated swap messages.
struct StonfiPoolV1SwapRefBody {
    /// Original user address used for swap refunds.
    fromRealUser: address
    /// Empty when hasRef is false, or a full referral address when hasRef is true.
    refAddressTail: RemainingBitsAndRefs
}

/// Referenced payout parameters carried by `pay_to`.
struct StonfiPoolV1PayToParams {
    /// Amount of the first token to transfer, in basic token units.
    amount0Out: coins
    /// First token wallet address used for the payout.
    token0Address: address
    /// Amount of the second token to transfer, in basic token units.
    amount1Out: coins
    /// Second token wallet address used for the payout.
    token1Address: address
}

/// Extra fields carried in async pool-data responses.
struct StonfiPoolV1GetterPoolDataExtra {
    /// Liquidity-provider fee value.
    lpFee: uint8
    /// Protocol fee value.
    protocolFee: uint8
    /// Referral fee value.
    refFee: uint8
    /// Address receiving collected protocol fees.
    protocolFeeAddress: address
    /// Collected protocol fee amount for the first token, in basic token units.
    collectedToken0ProtocolFee: coins
    /// Collected protocol fee amount for the second token, in basic token units.
    collectedToken1ProtocolFee: coins
}

/// LP-wallet burn callback that releases both pool reserves through Router payouts.
struct (0x7bdd97de) StonfiPoolV1BurnNotification {
    /// Query id copied from the LP Jetton burn.
    queryId: uint64
    /// Amount of LP Jettons burned, in basic token units.
    jettonAmount: coins
    /// LP owner whose liquidity is released.
    fromAddress: address
    /// Address receiving Jetton excesses, or `addr_none` when no excess response is requested.
    responseAddress: address?
}

/// LP Account callback after tokens are accumulated for liquidity minting.
struct (0x56dfeb8a) StonfiPoolV1CbAddLiquidity {
    /// Query id propagated through the liquidity operation.
    queryId: uint64
    /// Total first-token amount supplied by the LP Account, in basic token units.
    totAm0: coins
    /// Total second-token amount supplied by the LP Account, in basic token units.
    totAm1: coins
    /// Owner address of the LP Account.
    userAddress: address
    /// Minimum LP Jetton amount expected by the owner.
    minLpOut: coins
}

/// LP Account callback requesting refund of pending liquidity amounts.
struct (0x89446a42) StonfiPoolV1CbRefundMe {
    /// Query id propagated through the refund operation.
    queryId: uint64
    /// Total first-token amount to refund, in basic token units.
    totAm0: coins
    /// Total second-token amount to refund, in basic token units.
    totAm1: coins
    /// Owner address of the LP Account.
    userAddress: address
}

/// Router-originated swap routed from a user token transfer.
struct (0x25938561) StonfiPoolV1RouterSwap {
    /// Query id propagated from the routed transfer.
    queryId: uint64
    /// Address receiving successful swap output.
    fromUserAddress: address
    /// Token wallet address identifying the input side.
    tokenWallet: address
    /// Input token amount, in basic token units.
    amount: coins
    /// Minimum output token amount required by the swap.
    minOut: coins
    /// True when the referenced swap cell includes a referral address.
    hasRef: bool
    /// Referenced swap address data.
    refBody: Cell<StonfiPoolV1SwapRefBody>
}

/// Router-originated liquidity provision routed to the user's LP Account.
struct (0xfcf9e58f) StonfiPoolV1ProvideLp {
    /// Query id propagated from the routed transfer.
    queryId: uint64
    /// Owner whose deterministic LP Account receives the liquidity update.
    ownerAddress: address
    /// Minimum LP Jetton amount expected by the owner.
    minLpOut: coins
    /// First-token amount added to the LP Account, in basic token units.
    amount0: coins
    /// Second-token amount added to the LP Account, in basic token units.
    amount1: coins
}

/// Router gas-reset command for returning excess balance to the Router.
struct (0x42a0fb43) StonfiPoolV1ResetGas {
    /// Query id for the gas reset command.
    queryId: uint64
}

/// Protocol-fee collection command.
struct (0x1fcb7d3d) StonfiPoolV1CollectFees {
    /// Query id propagated to fee payout messages.
    queryId: uint64
}

/// Router command that updates Pool fee values and protocol-fee recipient.
struct (0x355423e5) StonfiPoolV1SetFees {
    /// Query id for the fee update command.
    queryId: uint64
    /// Replacement liquidity-provider fee value.
    newLpFee: uint8
    /// Replacement protocol fee value.
    newProtocolFee: uint8
    /// Replacement referral fee value.
    newRefFee: uint8
    /// Replacement protocol-fee recipient.
    newProtocolFeeAddress: address
}

/// Async request for current Pool data.
struct (0x43c034e6) StonfiPoolV1GetterPoolDataRequest {
    /// Query id copied into the async response.
    queryId: uint64
}

/// Async response with current Pool reserves, token wallets, fees, and collected protocol fees.
struct (0x43c034e6) StonfiPoolV1GetterPoolDataResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// Current reserve amount of the first token, in basic token units.
    reserve0: coins
    /// Current reserve amount of the second token, in basic token units.
    reserve1: coins
    /// Address of the first token wallet paired by the pool.
    token0Address: address
    /// Address of the second token wallet paired by the pool.
    token1Address: address
    /// Referenced fee and collected-fee data.
    extra: Cell<StonfiPoolV1GetterPoolDataExtra>
}

/// Async request for expected swap outputs.
struct (0xed4d8b67) StonfiPoolV1GetterExpectedOutputsRequest {
    /// Query id copied into the async response.
    queryId: uint64
    /// Input token amount, in basic token units.
    amount: coins
    /// Token wallet address identifying the input side.
    tokenWallet: address
}

/// Async request for a user's deterministic LP Account address.
struct (0x9163a98a) StonfiPoolV1GetterLpAccountAddressRequest {
    /// Query id copied into the async response.
    queryId: uint64
    /// User address used to derive the LP Account address.
    userAddress: address
}

/// Async response for `getter_expected_outputs`; source response opcode for `getter_lp_account_address` is also `getter_expected_outputs#ed4d8b67`.
struct (0xed4d8b67) StonfiPoolV1GetterExpectedOutputsOrLpAccountAddressResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// Either three `Coins` values for expected outputs or one LP Account address.
    responseTail: RemainingBitsAndRefs
}

/// Async request for estimated LP Jettons minted from token amounts.
struct (0x9ce632c5) StonfiPoolV1GetterExpectedTokensRequest {
    /// Query id copied into the async response.
    queryId: uint64
    /// User address carried by the async request.
    userAddress: address
    /// First-token amount, in basic token units.
    amount0: coins
    /// Second-token amount, in basic token units.
    amount1: coins
}

/// Async response with estimated LP Jettons.
struct (0x9ce632c5) StonfiPoolV1GetterExpectedTokensResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// Estimated LP Jetton amount, in basic token units.
    liquidity: coins
}

/// Async request for token amounts returned by burning LP Jettons.
struct (0x8751801f) StonfiPoolV1GetterExpectedLiquidityRequest {
    /// Query id copied into the async response.
    queryId: uint64
    /// LP Jetton amount, in basic token units.
    jettonAmount: coins
}

/// Async response with token amounts returned by burning LP Jettons.
struct (0x8751801f) StonfiPoolV1GetterExpectedLiquidityResponse {
    /// Query id copied from the async request.
    queryId: uint64
    /// First-token amount returned, in basic token units.
    amount0Out: coins
    /// Second-token amount returned, in basic token units.
    amount1Out: coins
}

/// TEP-89 LP wallet discovery request accepted by the Pool as LP Jetton minter.
struct (0x2c76b973) StonfiPoolV1ProvideWalletAddress {
    /// Query id copied into the wallet discovery response.
    queryId: uint64
    /// LP owner address whose deterministic LP wallet address is requested.
    ownerAddress: address
    /// True when the response includes a referenced copy of ownerAddress.
    includeAddress: bool
}

/// TEP-89 LP wallet discovery response emitted by the Pool as LP Jetton minter.
struct (0xd1735400) StonfiPoolV1TakeWalletAddress {
    /// Query id copied from the wallet discovery request.
    queryId: uint64
    /// Calculated LP wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced owner address when requested.
    ownerAddress: Cell<address>?
}

/// Pool-to-Router payout or refund request.
struct (0xf93bb43f) StonfiPoolV1PayTo {
    /// Query id propagated from the triggering operation.
    queryId: uint64
    /// Final owner or recipient of the payout.
    owner: address
    /// STON.fi result code describing the payout reason.
    exitCode: uint32
    /// Raw `Either StonfiPoolV1PayToParams ^StonfiPoolV1PayToParams` payout params.
    params: RemainingBitsAndRefs
}

/// Pool-to-LP Account update emitted by the routed provide-liquidity path.
struct (0x3ebe5431) StonfiPoolV1AddLiquidity {
    /// Query id copied from the routed provide-liquidity message.
    queryId: uint64
    /// First-token amount to add to the LP Account, in basic token units.
    amount0: coins
    /// Second-token amount to add to the LP Account, in basic token units.
    amount1: coins
    /// Minimum LP Jetton amount expected; zero requests a refund-only update.
    minLpOut: coins
}

/// Pool-to-LP-wallet mint transfer for newly issued LP Jettons.
struct (0x178d4519) StonfiPoolV1LpWalletInternalTransfer {
    /// Query id copied from the liquidity operation.
    queryId: uint64
    /// LP Jetton amount minted to the receiver wallet, in basic token units.
    amount: coins
    /// Address associated with the mint operation.
    fromAddress: address
    /// Address receiving LP wallet excesses, or `addr_none` when no response is requested.
    responseAddress: address?
    /// Nanotons forwarded with the LP wallet notification.
    forwardTonAmount: coins
    /// Raw Jetton `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Jetton excess response emitted when a burn response address is provided.
struct (0xd53276db) StonfiPoolV1Excesses {
    /// Query id copied from the triggering Jetton operation.
    queryId: uint64
}

/// Internal message bodies accepted by STON.fi Pool v1.
type StonfiPoolV1IncomingMessage =
    | StonfiPoolV1BurnNotification
    | StonfiPoolV1CbAddLiquidity
    | StonfiPoolV1CbRefundMe
    | StonfiPoolV1RouterSwap
    | StonfiPoolV1ProvideLp
    | StonfiPoolV1ResetGas
    | StonfiPoolV1CollectFees
    | StonfiPoolV1SetFees
    | StonfiPoolV1GetterPoolDataRequest
    | StonfiPoolV1GetterExpectedOutputsRequest
    | StonfiPoolV1GetterLpAccountAddressRequest
    | StonfiPoolV1GetterExpectedTokensRequest
    | StonfiPoolV1GetterExpectedLiquidityRequest
    | StonfiPoolV1ProvideWalletAddress

/// Internal message bodies emitted by STON.fi Pool v1.
type StonfiPoolV1OutgoingMessage =
    | StonfiPoolV1GetterPoolDataResponse
    | StonfiPoolV1GetterExpectedOutputsOrLpAccountAddressResponse
    | StonfiPoolV1GetterExpectedTokensResponse
    | StonfiPoolV1GetterExpectedLiquidityResponse
    | StonfiPoolV1TakeWalletAddress
    | StonfiPoolV1PayTo
    | StonfiPoolV1AddLiquidity
    | StonfiPoolV1LpWalletInternalTransfer
    | StonfiPoolV1Excesses

/// Structured result returned by `get_pool_data`.
struct StonfiPoolV1DataReply {
    /// Current reserve amount of the first token, in basic token units.
    reserve0: int
    /// Current reserve amount of the second token, in basic token units.
    reserve1: int
    /// Address of the first token wallet paired by the pool.
    token0Address: address
    /// Address of the second token wallet paired by the pool.
    token1Address: address
    /// Liquidity-provider fee value.
    lpFee: uint8
    /// Protocol fee value.
    protocolFee: uint8
    /// Referral fee value.
    refFee: uint8
    /// Address receiving collected protocol fees.
    protocolFeeAddress: address
    /// Collected protocol fee amount for the first token, in basic token units.
    collectedToken0ProtocolFee: int
    /// Collected protocol fee amount for the second token, in basic token units.
    collectedToken1ProtocolFee: int
}

/// Structured result returned by `get_expected_outputs`.
struct StonfiPoolV1ExpectedOutputsReply {
    /// Estimated output token amount, in basic token units.
    out: int
    /// Estimated protocol fee amount, in basic token units.
    protocolFeeOut: int
    /// Estimated referral fee amount, in basic token units.
    refFeeOut: int
}

/// Structured result returned by `get_expected_liquidity`.
struct StonfiPoolV1ExpectedLiquidityReply {
    /// First-token amount returned by burning LP Jettons, in basic token units.
    amount0Out: int
    /// Second-token amount returned by burning LP Jettons, in basic token units.
    amount1Out: int
}

/// Structured result returned by Pool's LP Jetton minter `get_jetton_data`.
struct StonfiPoolV1JettonDataReply {
    /// Total LP Jetton supply, in basic token units.
    totalSupply: int
    /// LP Jetton mintability flag.
    mintable: bool
    /// Router address returned in the Jetton admin slot.
    adminAddress: address
    /// LP Jetton metadata content cell.
    jettonContent: cell
    /// LP Jetton wallet code cell.
    jettonWalletCode: cell
}

/// Return current Pool reserves, token wallets, fee values, protocol-fee recipient, and collected protocol fees.
get fun get_pool_data(): StonfiPoolV1DataReply {
    throw 0;
}

/// Return estimated swap output and fee amounts for an input token amount.
get fun get_expected_outputs(amount: int, tokenWallet: address): StonfiPoolV1ExpectedOutputsReply {
    throw 0;
}

/// Return estimated LP Jettons minted from first-token and second-token amounts.
get fun get_expected_tokens(amount0: int, amount1: int): int {
    throw 0;
}

/// Return token amounts received by burning an LP Jetton amount.
get fun get_expected_liquidity(jettonAmount: int): StonfiPoolV1ExpectedLiquidityReply {
    throw 0;
}

/// Return the deterministic LP Account address for an owner.
get fun get_lp_account_address(owner: address): address {
    throw 0;
}

/// Return LP Jetton minter data for this Pool.
get fun get_jetton_data(): StonfiPoolV1JettonDataReply {
    throw 0;
}

/// Return the deterministic LP wallet address for an owner.
get fun get_wallet_address(owner: address): address {
    throw 0;
}
