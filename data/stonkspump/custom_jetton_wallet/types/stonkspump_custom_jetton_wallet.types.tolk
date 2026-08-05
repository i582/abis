/// sTONks tax-enabled Jetton wallet interface used by custom-tokenomics deployments.
contract StonksPumpCustomJettonWallet {
    author: "Stonks"
    description: "sTONks custom Jetton wallet with transfer tax accounting and distribution context."
    storage: StonksPumpCustomJettonWalletStorage
    incomingMessages: StonksPumpCustomJettonWalletIncomingMessage
    outgoingMessages: StonksPumpCustomJettonWalletOutgoingMessage
    forceAbiExport: StonksPumpCustomJettonWalletEmptyBody
        | StonksPumpCustomJettonWalletBouncedKnownBody
    thrownErrors: StonksPumpCustomJettonWalletErrors
}

/// Two-address context propagated between peer custom Jetton wallets.
struct StonksPumpJettonTransferContext {
    /// First address copied into the receiver's distribution context.
    contextAddress0: address
    /// Second address copied into the receiver's distribution context.
    contextAddress1: address
}

/// Persistent state of an initialized sTONks custom Jetton wallet.
struct StonksPumpCustomJettonWalletStorage {
    /// Spendable Jetton balance exposed through `get_wallet_data`.
    jettonBalance: coins
    /// Secondary Jetton-denominated amount used by the distribution accounting.
    accountingBalance: coins
    /// Referenced pair propagated by custom internal and tax transfers.
    transferContext: Cell<StonksPumpJettonTransferContext>
    /// Owner authorized to request transfers and burns.
    ownerAddress: address
    /// Jetton master accepted as a mint-originated transfer sender.
    jettonMasterAddress: address
    /// Executable wallet code used to derive peer wallet addresses.
    jettonWalletCode: cell
}

/// Owner-originated TEP-74 transfer request.
struct (0x0f8a7ea5) StonksPumpJettonTransfer {
    /// Caller-selected identifier copied into downstream messages.
    queryId: uint64
    /// Jetton amount debited from this wallet in base units.
    amount: coins
    /// Owner address for the destination Jetton wallet.
    destination: address
    /// Optional address that receives excess GRAM.
    responseDestination: address?
    /// Optional referenced application payload.
    customPayload: cell?
    /// Nanograms forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// TEP-74 Either payload tail, including its inline/reference selector.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet transfer extended with a referenced sTONks context pair.
struct (0x178d4519) StonksPumpJettonInternalTransfer {
    /// Request identifier copied from the originating transfer.
    queryId: uint64
    /// Jetton amount credited to the receiving wallet.
    amount: coins
    /// Original owner address, or `addr_none` for a master-originated transfer.
    senderOwner: address?
    /// Referenced context copied from the sending wallet.
    transferContext: Cell<StonksPumpJettonTransferContext>
    /// Optional address that receives excess GRAM.
    responseDestination: address?
    /// Nanograms forwarded to the receiving owner.
    forwardTonAmount: coins
    /// TEP-74 Either payload tail, including its inline/reference selector.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated TEP-74 burn request.
struct (0x595f07bc) StonksPumpJettonBurn {
    /// Caller-selected identifier copied into the burn notification.
    queryId: uint64
    /// Jetton amount removed from the wallet balance.
    amount: coins
    /// Optional address that receives excess GRAM from the master.
    responseDestination: address?
    /// Optional referenced application payload.
    customPayload: cell?
}

/// Inferred custom wallet-to-wallet transfer that accrues a taxed Jetton amount.
struct (0xcc1a97ab) StonksPumpJettonTaxTransfer {
    /// Request identifier copied from the taxed owner transfer.
    queryId: uint64
    /// Taxed Jetton amount credited to the master-owned receiver wallet.
    amount: coins
    /// Owner used to derive and authenticate the sending Jetton wallet.
    senderOwner: address
    /// First address installed into the receiver's distribution context.
    contextAddress0: address
    /// Second address installed into the receiver's distribution context.
    contextAddress1: address
}

/// Empty body accepted for GRAM distribution and emitted by value-only payouts.
struct StonksPumpCustomJettonWalletEmptyBody {}

/// Bounce body accepted when the original operation was a wallet transfer or burn notification.
struct (0xffffffff) StonksPumpCustomJettonWalletBouncedKnownBody {
    /// Original bounced operation; accepted values are `0x178d4519` and `0x7bdd97de`.
    originalOpcode: uint32
    /// Request identifier copied from the original operation.
    queryId: uint64
    /// Jetton amount restored to the spendable balance.
    amount: coins
    /// Truncated remainder of the original bounced body.
    tail: RemainingBitsAndRefs
}

/// Internal bodies accepted by the sTONks custom Jetton wallet.
type StonksPumpCustomJettonWalletIncomingMessage =
    | StonksPumpJettonTransfer
    | StonksPumpJettonInternalTransfer
    | StonksPumpJettonBurn
    | StonksPumpJettonTaxTransfer

/// TEP-74 transfer notification emitted to a receiving owner.
struct (0x7362d09c) StonksPumpJettonTransferNotification {
    /// Request identifier copied from the internal transfer.
    queryId: uint64
    /// Received Jetton amount in base units.
    amount: coins
    /// Original owner, or `addr_none` for a master-originated transfer.
    senderOwner: address?
    /// TEP-74 Either payload tail delivered to the owner.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excess-value response.
struct (0xd53276db) StonksPumpJettonExcess {
    /// Request identifier associated with the returned GRAM.
    queryId: uint64
}

/// Burn notification emitted to the Jetton master.
struct (0x7bdd97de) StonksPumpJettonBurnNotification {
    /// Request identifier copied from the burn request.
    queryId: uint64
    /// Burned Jetton amount in base units.
    amount: coins
    /// Owner whose wallet burned the Jettons.
    senderOwner: address
    /// Optional address that receives remaining GRAM.
    responseDestination: address?
}

/// Body-bearing internal messages emitted by the custom wallet.
type StonksPumpCustomJettonWalletOutgoingMessage =
    | StonksPumpJettonInternalTransfer
    | StonksPumpJettonTaxTransfer
    | StonksPumpJettonTransferNotification
    | StonksPumpJettonExcess
    | StonksPumpJettonBurnNotification

/// Buy and sell tax rates returned in tenths of one percent.
struct StonksPumpJettonTaxRates {
    /// Buy-side tax in per-mille units; `290` means 29%.
    buyTaxPermille: int
    /// Sell-side tax in per-mille units; `290` means 29%.
    sellTaxPermille: int
}

/// Standard Jetton wallet data returned on the TVM stack.
struct StonksPumpCustomJettonWalletData {
    /// Current spendable Jetton balance.
    jettonBalance: int
    /// Wallet owner address.
    ownerAddress: any_address
    /// Jetton master address.
    jettonMasterAddress: any_address
    /// Executable wallet code cell.
    jettonWalletCode: cell
}

/// Returns buy-side and sell-side tax rates in per-mille units.
get fun get_tax(): StonksPumpJettonTaxRates {
    throw 0;
}

/// Returns standard Jetton balance, owner, master, and wallet-code data.
get fun get_wallet_data(): StonksPumpCustomJettonWalletData {
    throw 0;
}

/// Exit codes thrown by the deployed custom wallet.
enum StonksPumpCustomJettonWalletErrors {
    /// A transfer destination is outside base workchain zero.
    UnsupportedWorkchain = 333
    /// A transfer or burn request was not sent by the wallet owner.
    SenderIsNotOwner = 705
    /// A transfer or burn amount exceeds the wallet's Jetton balance.
    InsufficientJettonBalance = 706
    /// Sender authentication or the attached-value requirement failed.
    InvalidSenderOrAttachedValue = 707
    /// A transfer omits the required forward-payload Either selector.
    MissingForwardPayload = 708
    /// Attached value is insufficient or a bounced opcode is unsupported.
    InvalidValueOrBouncedOpcode = 709
}
