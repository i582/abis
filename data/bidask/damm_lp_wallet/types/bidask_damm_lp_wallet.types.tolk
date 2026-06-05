/// Bidask DAMM LP wallet: an LP-token Jetton wallet with DAMM fee checkpoints.
contract BidaskDammLpWallet {
    author: "Bidask Protocol"
    version: "0.1"
    description: "Curated interface for the Bidask DAMM LP wallet: LP Jetton wallet messages, DAMM mint/burn/claim extensions, fee checkpoint getters, and proven init-state storage"
    storage: BidaskDammLpWalletStorage
    incomingMessages: BidaskDammLpWalletIncomingMessage
    outgoingMessages: BidaskDammLpWalletOutgoingMessage
}

/// Owner/master pair stored in the single referenced storage cell.
struct BidaskDammLpWalletStorageAddresses {
    /// LP-token owner; the historical init data stores the user wallet here.
    ownerAddress: address
    /// LP Jetton master address; for DAMM LP wallets this is the DAMM Pool.
    jettonMasterAddress: address
}

/// Persistent wallet state proven from the saved historical init data BoC.
struct BidaskDammLpWalletStorage {
    /// LP Jetton balance encoded as TL-B `Coins`.
    balance: coins
    /// Last pool fee checkpoint for token X, stored as a 220-bit unsigned integer.
    feesPerLpXLast: uint220
    /// Last pool fee checkpoint for token Y, stored as a 220-bit unsigned integer.
    feesPerLpYLast: uint220
    /// Token X fees already claimed by this LP owner, stored as a 220-bit unsigned integer.
    claimedX: uint220
    /// Token Y fees already claimed by this LP owner, stored as a 220-bit unsigned integer.
    claimedY: uint220
    /// Referenced cell containing owner and DAMM Pool/master addresses.
    addresses: Cell<BidaskDammLpWalletStorageAddresses>
}

/// Fee checkpoint cell carried by DAMM mint and custom internal-transfer bodies.
struct BidaskDammLpWalletTransferFees {
    /// Pool fee checkpoint for token X at mint or peer transfer time.
    feesPerLpXLast: uint220
    /// Pool fee checkpoint for token Y at mint or peer transfer time.
    feesPerLpYLast: uint220
}

/// Fee checkpoint and claimed totals sent from the LP wallet back to the DAMM Pool.
struct BidaskDammLpWalletBurnFees {
    /// Wallet's token X fee checkpoint before the burn is applied.
    feesPerLpXLast: uint220
    /// Wallet's token Y fee checkpoint before the burn is applied.
    feesPerLpYLast: uint220
    /// Token X fees already claimed by this LP owner.
    claimedX: uint220
    /// Token Y fees already claimed by this LP owner.
    claimedY: uint220
}

/// Fee checkpoint and claimed totals sent from the LP wallet during a fee claim.
struct BidaskDammLpWalletClaimFees {
    /// Wallet's token X fee checkpoint before the claim is applied.
    feesPerLpXLast: uint220
    /// Wallet's token Y fee checkpoint before the claim is applied.
    feesPerLpYLast: uint220
    /// Token X fees already claimed by this LP owner.
    claimedX: uint220
    /// Token Y fees already claimed by this LP owner.
    claimedY: uint220
}

/// DAMM Pool mint message that credits LP tokens and initializes fee checkpoints.
struct (0x27ae4eff) BidaskDammLpWalletMint {
    /// Query id selected by the DAMM Pool and copied through follow-up messages.
    queryId: uint64
    /// LP tokens to mint into the wallet, in base units.
    mintAmount: coins
    /// Address carried by the pool mint body; the historical body stores the DAMM Pool here.
    fromAddress: address
    /// Response or owner address carried by the mint body; the historical body stores the LP owner here.
    responseAddress: address
    /// Referenced fee checkpoint cell with token X/Y per-LP fee counters.
    fees: Cell<BidaskDammLpWalletTransferFees>
    /// Optional payload forwarded to the LP wallet owner after mint processing.
    forwardPayload: cell?
}

/// Owner-originated LP-token transfer request, following TEP-74 with Bidask docs naming.
struct (0x0f8a7ea5) BidaskDammLpWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// LP Jetton amount to transfer, in base units.
    jettonAmount: coins
    /// Destination owner whose deterministic DAMM LP wallet receives the transfer.
    toOwnerAddress: address
    /// Optional response address for an excesses refund.
    responseAddress: address?
    /// Optional custom payload parsed as a referenced cell by SDK builders.
    customPayload: cell?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Custom DAMM LP wallet-to-wallet transfer with a referenced fee checkpoint cell.
struct (0x178d4519) BidaskDammLpWalletInternalTransfer {
    /// Query id copied from the originating transfer or mint-like flow.
    queryId: uint64
    /// LP Jetton amount credited to the recipient wallet, in base units.
    jettonAmount: coins
    /// Source owner address reported by the sending LP wallet.
    fromAddress: address
    /// Optional response address for an excesses refund.
    responseAddress: address?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Referenced token X/Y fee checkpoints that travel with transferred LP tokens.
    fees: Cell<BidaskDammLpWalletTransferFees>
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail after the DAMM fee cell.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated request to burn LP tokens through the DAMM Pool.
struct (0x71e4a09a) BidaskDammLpWalletBurn {
    /// Caller-selected query id copied into the outgoing pool burn request.
    queryId: uint64
    /// LP tokens to burn, in base units.
    burnAmount: coins
    /// Whether the receiver is a Bidask account contract rather than a plain wallet.
    isAccount: bool
    /// Address that should receive withdrawn assets or account credit.
    receiver: address
    /// Optional auxiliary data forwarded to the DAMM Pool burn handler.
    additionalData: cell?
    /// Optional payload forwarded with the pool's burn result.
    forwardPayload: cell?
}

/// Owner-originated request to claim accumulated DAMM LP fees.
struct (0x26fa12a4) BidaskDammLpWalletClaimFeesRequest {
    /// Caller-selected query id copied into the outgoing pool claim request.
    queryId: uint64
    /// Whether the receiver is a Bidask account contract rather than a plain wallet.
    isAccount: bool
    /// Address that should receive claimed fees or account credit.
    receiver: address
    /// Optional payload forwarded with the pool's claim result.
    forwardPayload: cell?
}

/// Internal burn request emitted by the LP wallet to the DAMM Pool.
struct (0xadb8eb49) BidaskDammLpWalletInternalBurn {
    /// Query id copied from the owner burn request.
    queryId: uint64
    /// LP owner address whose liquidity is being burned.
    burner: address
    /// LP tokens to burn, in base units.
    burnAmount: coins
    /// Whether the receiver is a Bidask account contract rather than a plain wallet.
    isAccount: bool
    /// Address that should receive withdrawn assets or account credit.
    receiver: address
    /// Referenced fee checkpoint and claimed-total cell from this wallet's state.
    fees: Cell<BidaskDammLpWalletBurnFees>
    /// Optional auxiliary data forwarded to the DAMM Pool burn handler.
    additionalData: cell?
    /// Optional payload forwarded with the pool's burn result.
    forwardPayload: cell?
}

/// Internal fee-claim request emitted by the LP wallet to the DAMM Pool.
struct (0x983b6933) BidaskDammLpWalletInternalClaim {
    /// Query id copied from the owner claim request.
    queryId: uint64
    /// LP owner address whose accumulated fees are being claimed.
    owner: address
    /// Whether the receiver is a Bidask account contract rather than a plain wallet.
    isAccount: bool
    /// Address that should receive claimed fees or account credit.
    receiver: address
    /// Current LP wallet balance sent so the pool can settle fees proportionally.
    walletBalance: coins
    /// Referenced fee checkpoint and claimed-total cell from this wallet's state.
    fees: Cell<BidaskDammLpWalletClaimFees>
    /// Optional payload forwarded with the pool's claim result.
    forwardPayload: cell?
}

/// Standard Jetton owner notification emitted when a received LP transfer forwards TON.
struct (0x7362d09c) BidaskDammLpWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// LP Jetton amount received, in base units.
    amount: coins
    /// Source owner address reported by the internal transfer.
    sender: address
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excesses response emitted when value remains after processing.
struct (0xd53276db) BidaskDammLpWalletExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the Bidask DAMM LP wallet.
type BidaskDammLpWalletIncomingMessage =
    | BidaskDammLpWalletMint
    | BidaskDammLpWalletTransfer
    | BidaskDammLpWalletInternalTransfer
    | BidaskDammLpWalletBurn
    | BidaskDammLpWalletClaimFeesRequest

/// Internal message bodies emitted by the Bidask DAMM LP wallet.
type BidaskDammLpWalletOutgoingMessage =
    | BidaskDammLpWalletInternalTransfer
    | BidaskDammLpWalletInternalBurn
    | BidaskDammLpWalletInternalClaim
    | BidaskDammLpWalletTransferNotification
    | BidaskDammLpWalletExcesses

/// Structured result returned by the standard Jetton wallet `get_wallet_data`.
struct GetBidaskDammLpWalletDataReply {
    /// LP Jetton balance returned as a TVM stack integer.
    balance: int
    /// LP-token owner address.
    ownerAddress: address
    /// LP Jetton master address; for DAMM LP wallets this is the DAMM Pool.
    jettonMasterAddress: address
    /// Wallet code cell returned by the getter; this exotic-code variant does not store it in data.
    jettonWalletCode: cell
}

/// Structured result returned by `get_user_fees_info`.
struct GetBidaskDammLpWalletUserFeesInfoReply {
    /// Last token X per-LP fee checkpoint returned as a TVM stack integer.
    feesPerLpXLast: int
    /// Last token Y per-LP fee checkpoint returned as a TVM stack integer.
    feesPerLpYLast: int
    /// Claimed token X total returned as a TVM stack integer.
    claimedX: int
    /// Claimed token Y total returned as a TVM stack integer.
    claimedY: int
}

/// Return the standard LP Jetton wallet data tuple.
get fun get_wallet_data(): GetBidaskDammLpWalletDataReply {
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the wallet's stored DAMM fee checkpoints and already-claimed totals.
get fun get_user_fees_info(): GetBidaskDammLpWalletUserFeesInfoReply {
    return {
        feesPerLpXLast: 0,
        feesPerLpYLast: 0,
        claimedX: 0,
        claimedY: 0,
    };
}
