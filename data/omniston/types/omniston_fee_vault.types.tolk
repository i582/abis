/// Omniston Fee-Vault Minter used for token-aware referral-fee vaults.
contract OmnistonFeeVault {
    author: "Omniston"
    version: "0.4 beta2.0"
    description: "Standalone Omniston Fee-Vault Minter that derives per-referrer vault addresses, deposits jetton referral fees, and routes remaining jettons or TON to settlement destinations."
    storage: OmnistonFeeVaultStorage
    incomingMessages: OmnistonFeeVaultIncomingMessage
    outgoingMessages: OmnistonFeeVaultOutgoingMessage
    thrownErrors: Errors
    forceAbiExport: OmnistonJettonFeePayload
        | OmnistonJettonFeePayloadInRef
        | OmnistonWrappedJettonFeePayload
        | OmnistonNativeFeePayload
        | OmnistonFeeShareConfig
        | OmnistonFeeVaultMinterDataReply
        | OmnistonForwardPayloadInline
        | OmnistonForwardPayloadInRef
        | OmnistonPtonRoutePayloadInRef
}

/// Raw TEP-74/TEP-161 forward-payload tail after the Either tag is decoded.
type OmnistonForwardPayloadRemainder = RemainingBitsAndRefs

/// Inline forward-payload variant with payload bits stored directly in the message body.
struct (0b0) OmnistonForwardPayloadInline {
    /// Remaining inline payload bits and refs after the Either tag.
    value: RemainingBitsAndRefs
}

/// Referenced forward-payload variant with payload stored in a separate cell.
struct (0b1) OmnistonForwardPayloadInRef {
    /// Referenced raw payload cell.
    value: Cell<RemainingBitsAndRefs>
}

/// Referenced TEP-74 forward-payload variant carrying the Omniston jetton fee payload.
struct (0b1) OmnistonJettonFeePayloadInRef {
    /// Referenced jetton fee payload cell.
    value: Cell<OmnistonJettonFeePayload>
}

/// Referenced pTON forward-payload variant carrying a native route payload cell.
struct (0b1) OmnistonPtonRoutePayloadInRef {
    /// Referenced native route payload cell.
    value: Cell<OmnistonNativeFeePayload>
}

/// Persistent Fee-Vault Minter state stored in the root data cell.
struct OmnistonFeeVaultStorage {
    /// Contract instance id stored as a 64-bit integer.
    id: uint64
    /// Admin address authorized for upgrade and TON-withdrawal commands.
    adminAddress: address
    /// Unix timestamp after which a staged upgrade may be applied; zero means no pending upgrade.
    tempUpgradeUntil: uint64
    /// Staged replacement code cell for the delayed upgrade flow.
    tempCode: cell
    /// Staged replacement data cell for the delayed upgrade flow.
    tempData: cell
    /// Code cell used to derive deterministic per-token, per-owner fee vault addresses.
    vaultCode: cell
}

/// Stack tuple returned by `get_minter_data`.
struct OmnistonFeeVaultMinterDataReply {
    /// Contract instance id.
    id: uint64
    /// Admin address authorized for upgrade and TON-withdrawal commands.
    adminAddress: any_address
    /// Unix timestamp after which a staged upgrade may be applied; zero means no pending upgrade.
    tempUpgradeUntil: uint64
    /// Staged replacement code cell for the delayed upgrade flow.
    tempCode: cell
    /// Staged replacement data cell for the delayed upgrade flow.
    tempData: cell
    /// Code cell used to derive deterministic per-token, per-owner fee vault addresses.
    vaultCode: cell
}

/// Three referral-fee share entries encoded in a referenced cell.
struct OmnistonFeeShareConfig {
    /// First fee recipient or vault owner address.
    recipient0: address
    /// First fee share in basis points; accepted values are 0 through 100.
    shareBps0: uint16
    /// Second fee recipient or vault owner address.
    recipient1: address
    /// Second fee share in basis points; accepted values are 0 through 100.
    shareBps1: uint16
    /// Third fee recipient or vault owner address.
    recipient2: address
    /// Third fee share in basis points; accepted values are 0 through 100.
    shareBps2: uint16
}

/// Jetton fee payload carried inside a referenced transfer-notification payload cell.
struct (0x1a3c2fc3) OmnistonJettonFeePayload {
    /// Destination receiving the remaining jettons after referral-fee deposits.
    successDestination: address
    /// Destination receiving the original jettons when fee processing fails.
    errorDestination: address
    /// Address copied into downstream jetton-transfer response fields.
    responseDestination: address
    /// Referenced three-entry fee-share configuration.
    feeShares: Cell<OmnistonFeeShareConfig>
}

/// Wrapped jetton fee payload that carries the direct fee payload by reference.
struct (0xc0ffee36) OmnistonWrappedJettonFeePayload {
    /// Wrapper-selected query id stored before the referenced route payload.
    wrapperQueryId: uint64
    /// Referenced direct jetton fee payload.
    payload: Cell<OmnistonJettonFeePayload>
}

/// Native TON route payload used directly or through pTON forwarded payload refs.
struct OmnistonNativeFeePayload {
    /// Route tag stored before the address and share fields.
    routeTag: uint32
    /// Destination receiving the success result callback.
    successDestination: address
    /// Destination receiving the failure result callback.
    errorDestination: address
    /// Additional route address carried before the fee-share ref.
    contextAddress: address
    /// Referenced three-entry fee-share configuration.
    feeShares: Cell<OmnistonFeeShareConfig>
}

/// Jetton transfer notification accepted from a token wallet.
struct (0x7362d09c) OmnistonJettonFeeNotification {
    /// Query id copied into downstream vault deposits and jetton transfers.
    queryId: uint64
    /// Jetton amount received by the contract.
    amount: coins
    /// Jetton sender or owner address from the notification.
    sender: address
    /// TEP-74 Either forward-payload tail; the referenced-cell variant carries a jetton fee payload.
    @abi.clientType(OmnistonForwardPayloadInline | OmnistonJettonFeePayloadInRef)
    forwardPayload: OmnistonForwardPayloadRemainder
}

/// Native TON distribution request with the route payload encoded as a nullable reference.
struct (0x474f86cf) OmnistonNativeFeeDistribution {
    /// Query id copied into outgoing TON fee notifications and result callbacks.
    queryId: uint64
    /// Optional referenced native route payload.
    route: Cell<OmnistonNativeFeePayload>?
}

/// Wrapped native TON distribution request carrying the route payload by reference.
struct (0xc0ffee36) OmnistonWrappedNativeFeeDistribution {
    /// Query id copied into outgoing TON fee notifications and result callbacks.
    queryId: uint64
    /// Referenced route payload cell.
    payload: Cell<OmnistonNativeFeePayload>
}

/// pTON TON transfer body accepted when native TON is forwarded through a pTON wallet.
struct (0x01f3835d) OmnistonPtonTonTransfer {
    /// Query id copied into outgoing TON fee notifications and result callbacks.
    queryId: uint64
    /// Native TON amount to distribute before route fees.
    tonAmount: coins
    /// Refund address required to be a standard internal address.
    refundAddress: address
    /// TEP-161 Either payload tail; the referenced-cell variant carries the route payload.
    @abi.clientType(OmnistonForwardPayloadInline | OmnistonPtonRoutePayloadInRef)
    forwardPayload: OmnistonForwardPayloadRemainder
}

/// Callback from a deterministic fee vault asking this contract to pay jettons out.
struct (0x4187c1ac) OmnistonVaultJettonPayout {
    /// Query id copied into the outgoing jetton transfer.
    queryId: uint64
    /// Jetton amount to pay out.
    amount: coins
    /// Owner destination receiving the jettons.
    destination: address
    /// Jetton wallet address that should send the outgoing transfer.
    tokenWallet: address
    /// Address copied into the outgoing jetton-transfer response field.
    responseDestination: address
}

/// Admin command that sends remaining TON to a response address after reserving storage.
struct (0x3477ff3f) OmnistonAdminWithdrawTons {
    /// Query id copied into the excesses response.
    queryId: uint64
    /// Address receiving the excesses response and carried TON.
    responseAddress: address
}

/// Admin command that stages a delayed code and data upgrade.
struct (0x08cb667b) OmnistonAdminStageUpgrade {
    /// Query id copied into the excesses response.
    queryId: uint64
    /// Address receiving the excesses response.
    responseAddress: address
    /// Replacement code cell staged for the delayed upgrade.
    newCode: cell
    /// Replacement data cell staged for the delayed upgrade.
    newData: cell
}

/// Admin command that clears the staged upgrade cells and deadline.
struct (0x0398cdb0) OmnistonAdminCancelUpgrade {
    /// Query id copied into the excesses response.
    queryId: uint64
    /// Address receiving the excesses response.
    responseAddress: address
}

/// Admin command that applies a staged upgrade after its delay expires.
struct (0x6d85c00b) OmnistonAdminApplyUpgrade {
    /// Query id copied into the excesses response.
    queryId: uint64
    /// Address receiving the excesses response.
    responseAddress: address
}

/// Deposit request emitted to a deterministic fee vault.
struct (0x6d82d2a4) OmnistonVaultDeposit {
    /// Query id copied from the triggering route message.
    queryId: uint64
    /// Jetton amount deposited into the deterministic fee vault.
    amount: coins
    /// Address receiving excesses from the fee-vault deposit.
    responseDestination: address
}

/// Standard jetton transfer emitted to token wallets by Omniston fee processing.
struct (0x0f8a7ea5) OmnistonJettonTransfer {
    /// Query id copied from the triggering route message.
    queryId: uint64
    /// Jetton amount to transfer.
    amount: coins
    /// Destination owner address.
    destination: address
    /// Address receiving excesses from the token wallet.
    responseDestination: address
    /// Optional custom payload, always absent in observed send sites.
    customPayload: cell?
    /// Nanotons forwarded to the destination notification.
    forwardTonAmount: coins
    /// TEP-74 Either payload tail carrying an inline result code.
    @abi.clientType(OmnistonForwardPayloadInline | OmnistonForwardPayloadInRef)
    forwardPayload: OmnistonForwardPayloadRemainder
}

/// TON fee notification emitted to native route fee recipients.
struct (0x37d3af9e) OmnistonNativeTonExcesses {
    /// Query id copied from the triggering route message.
    queryId: uint64
}

/// Native route result callback carrying a 32-bit success or error code.
struct (0x4c3e12d7) OmnistonNativeTonPayResult {
    /// Query id copied from the triggering route message.
    queryId: uint64
    /// Success code `56647` or a caught VM/argument error code.
    exitCode: uint32
}

/// Wrapped native route fee notification emitted to fee recipients.
struct (0x70502933) OmnistonWrappedNativeExcesses {
    /// Query id copied from the triggering route message.
    queryId: uint64
}

/// Wrapped native route result callback carrying a 32-bit success or error code.
struct (0x64a7847e) OmnistonWrappedNativeResult {
    /// Query id copied from the triggering route message.
    queryId: uint64
    /// Success code `56647` or a caught VM/argument error code.
    exitCode: uint32
}

/// pTON route fee notification emitted to fee recipients.
struct (0x01343b55) OmnistonPtonFeeExcesses {
    /// Query id copied from the triggering pTON transfer.
    queryId: uint64
}

/// pTON route result callback carrying a 32-bit success or error code.
struct (0x0cd3434f) OmnistonPtonFeeResult {
    /// Query id copied from the triggering pTON transfer.
    queryId: uint64
    /// Success code or caught VM/argument error code.
    exitCode: uint32
}

/// Standard excesses body emitted by admin commands.
struct (0xd53276db) OmnistonExcesses {
    /// Query id copied from the admin command.
    queryId: uint64
}

/// Internal message bodies accepted by the Omniston Fee Vault contract.
type OmnistonFeeVaultIncomingMessage =
    | OmnistonJettonFeeNotification
    | OmnistonNativeFeeDistribution
    | OmnistonWrappedNativeFeeDistribution
    | OmnistonPtonTonTransfer
    | OmnistonVaultJettonPayout
    | OmnistonAdminWithdrawTons
    | OmnistonAdminStageUpgrade
    | OmnistonAdminCancelUpgrade
    | OmnistonAdminApplyUpgrade

/// Internal message bodies emitted by the Omniston Fee Vault contract.
type OmnistonFeeVaultOutgoingMessage =
    | OmnistonVaultDeposit
    | OmnistonJettonTransfer
    | OmnistonNativeTonExcesses
    | OmnistonNativeTonPayResult
    | OmnistonWrappedNativeExcesses
    | OmnistonWrappedNativeResult
    | OmnistonPtonFeeExcesses
    | OmnistonPtonFeeResult
    | OmnistonExcesses

/// Exit codes thrown directly by the Omniston Fee Vault dispatcher and getters.
enum Errors {
    /// Fee split leaves no positive remaining amount for the route destination.
    InvalidRemainingAmount = 7960
    /// pTON forward payload is not encoded as the required referenced-cell variant.
    PtonForwardPayloadMustBeRef = 12490
    /// Address or deterministic vault sender check failed.
    InvalidAddressOrSender = 32950
    /// Message address, route address, or getter address is outside workchain 0.
    WrongWorkchain = 33533
    /// Attached TON value is below the route or upgrade processing requirement.
    InsufficientValue = 33565
    /// One of the three fee shares is outside the accepted range.
    InvalidFeeShare = 34413
    /// Jetton or pTON amount is zero.
    ZeroAmount = 34643
    /// A delayed upgrade is already staged.
    UpgradeAlreadyPending = 5190
    /// Staged upgrade code or data cell is empty.
    EmptyUpgradeCell = 63732
    /// Unsupported opcode or invalid wrapped payload opcode.
    UnsupportedOperation = 65535
}

/// Structured result returned by `get_version`.
struct OmnistonFeeVaultVersionReply {
    /// Major version component returned by the getter.
    major: uint32
    /// Minor version component returned by the getter.
    minor: uint32
    /// Development tag returned by the getter, such as `beta2.0`.
    development: string
}

/// Return the Fee-Vault Minter storage tuple.
get fun get_minter_data(): OmnistonFeeVaultMinterDataReply {
    throw 0;
}

/// Return the deterministic fee vault address for an owner and token wallet.
get fun get_vault_address(ownerAddress: address, tokenWalletAddress: address): any_address {
    throw 0;
}

/// Return the compiled Omniston Fee Vault version tuple.
get fun get_version(): OmnistonFeeVaultVersionReply {
    throw 0;
}
