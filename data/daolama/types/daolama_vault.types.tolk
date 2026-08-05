/// GRAM lending vault and TON-DLP jetton master used by DAOLama.
contract DaolamaVault {
    author: "DAOLama"
    version: "1.0"
    description: "DAOLama TON Vault accepts signed GRAM liquidity supplies, funds NFT-backed loans, processes repayments, and issues TON-DLP jettons."
    storage: DaolamaVaultStorage
    incomingMessages: DaolamaVaultIncomingMessage
    outgoingMessages: DaolamaVaultOutgoingMessage
    thrownErrors: DaolamaVaultErrors
}

/// Persistent scalar state and referenced configuration of the GRAM vault.
struct DaolamaVaultStorage {
    /// Authorization, administration, wallet-code, and metadata configuration.
    config: Cell<DaolamaVaultConfig>
    /// Capacity and repayment-profit fee settings.
    params: Cell<DaolamaVaultParams>
    /// Whether new borrow flows are disabled.
    halted: bool
    /// Liquid nanograms available in the lending vault.
    balance: coins
    /// Principal nanograms currently assigned to active loans.
    borrowed: coins
    /// Total TON-DLP supply in base units.
    lpTokenBalance: coins
    /// Accrued protocol fees in nanograms.
    feeCollected: coins
}

/// Authorization key, administrator, and TEP-74 jetton configuration.
struct DaolamaVaultConfig {
    /// Ed25519 public key used to verify signed supply and loan authorizations.
    authorizationPublicKey: uint256
    /// Address authorized to update configuration, halt the vault, and upgrade code.
    adminAddress: address
    /// TON-DLP wallet code used for deterministic wallet-address derivation.
    jettonWalletCode: cell
    /// TON-DLP metadata content returned by `get_jetton_data`.
    jettonContent: cell
}

/// Liquidity-cap and protocol-fee parameters.
struct DaolamaVaultParams {
    /// Maximum `balance + borrowed` amount in nanograms; zero disables the cap.
    maxTotalLiquidity: coins
    /// Positive repayment-profit share charged to the protocol, in thousandths.
    profitFeePerMille: uint16
}

/// Signed authorization envelope for one liquidity-supply request.
struct DaolamaSupplyAuthorizationProof {
    /// Ed25519 signature over the referenced authorization cell.
    signature: bits512
    /// Referenced supply authorization checked by the vault.
    authorization: Cell<DaolamaSupplyAuthorization>
}

/// Signed authorization envelope for a loan deployment or repayment.
struct DaolamaLoanAuthorizationProof {
    /// Ed25519 signature over the referenced authorization cell.
    signature: bits512
    /// Referenced loan authorization checked by the vault.
    authorization: Cell<DaolamaLoanAuthorization>
}

/// Signed payload authorizing one liquidity supply.
struct DaolamaSupplyAuthorization {
    /// Vault address for which the authorization is valid.
    vaultAddress: address
    /// Supplier address that must equal the internal-message sender.
    supplierAddress: address
    /// Unix timestamp after which the authorization is rejected.
    validUntil: uint32
    /// Signed operation tag, required to equal `0x5c11ada9`.
    operation: uint32
    /// Authorized supply amount in nanograms.
    amount: coins
}

/// Signed payload authorizing a loan-contract deployment or repayment.
struct DaolamaLoanAuthorization {
    /// Vault address for which the authorization is valid.
    vaultAddress: address
    /// Borrower or derived loan address bound by the authorization.
    counterpartyAddress: address
    /// Unix timestamp after which the authorization is rejected.
    validUntil: uint32
    /// Loan contract code used in the deterministic StateInit.
    loanCode: cell
    /// Loan contract data used in the deterministic StateInit.
    loanData: cell
}

/// Signed GRAM liquidity supply that mints TON-DLP shares.
struct (0x5c11ada9) DaolamaSupply {
    /// Caller-selected id copied to the TON-DLP mint transfer.
    queryId: uint64
    /// Supplied nanograms.
    amount: coins
    /// Signature and signed `DaolamaSupplyAuthorization` payload.
    proof: Cell<DaolamaSupplyAuthorizationProof>
}

/// Standard TEP-74 burn notification used to withdraw underlying GRAM.
struct (0x7bdd97de) DaolamaLpBurnNotification {
    /// Query id copied from the TON-DLP wallet burn.
    queryId: uint64
    /// Burned TON-DLP amount in base units.
    amount: coins
    /// TON-DLP owner whose deterministic wallet sent the notification.
    senderAddress: address
    /// Address that receives an excess-value response when present.
    responseDestination: address?
}

/// Standard NFT ownership notification that carries a signed loan authorization.
struct (0x05138d91) DaolamaNftOwnershipAssigned {
    /// Query id copied from the NFT transfer.
    queryId: uint64
    /// Previous NFT owner address.
    previousOwnerAddress: address
    /// Raw TEP-62 `Either Cell ^Cell` tail containing the loan proof.
    forwardPayload: RemainingBitsAndRefs
}

/// Signed request to fund and deploy an NFT-backed loan contract.
struct (0x00000001) DaolamaBorrow {
    /// Caller-selected id copied to the loan-funding message.
    queryId: uint64
    /// Signature and signed `DaolamaLoanAuthorization` payload.
    proof: Cell<DaolamaLoanAuthorizationProof>
}

/// Repayment delivered by the deterministic loan contract.
struct (0x00000002) DaolamaRepay {
    /// Loan-selected correlation id.
    queryId: uint64
    /// Repaid principal removed from the vault's borrowed balance.
    principal: coins
    /// Total nanograms returned by the loan contract before fee accounting.
    receivedAmount: coins
    /// Optional destination for remaining message value.
    excessDestination: address?
    /// Maybe-ref signature and signed `DaolamaLoanAuthorization` payload.
    proof: Cell<DaolamaLoanAuthorizationProof>?
}

/// Admin request to collect accrued protocol fees.
struct (0x27b385ca) DaolamaCollectFees {
    /// Admin-selected correlation id.
    queryId: uint64
}

/// Admin request to replace liquidity-cap and protocol-fee parameters.
struct (0xa98f8b87) DaolamaUpdateParams {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Replacement parameter cell.
    params: Cell<DaolamaVaultParams>
}

/// Admin request to replace authorization, admin, wallet-code, and metadata configuration.
struct (0x32d84abd) DaolamaUpdateConfig {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Replacement configuration cell.
    config: Cell<DaolamaVaultConfig>
}

/// Admin request to enable or disable new borrow flows.
struct (0xe756d6cc) DaolamaSetHalted {
    /// Admin-selected correlation id.
    queryId: uint64
    /// New halted flag.
    halted: bool
}

/// Admin request to send an arbitrary prebuilt internal message.
struct (0xc75450b0) DaolamaAdminSendMessage {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Complete serialized message passed to `send_raw_message`.
    message: cell
    /// TVM send mode applied to the serialized message.
    mode: uint8
}

/// Admin request to replace contract code and optionally persistent data.
struct (0xdbfaf817) DaolamaUpgrade {
    /// Admin-selected correlation id.
    queryId: uint64
    /// Optional replacement code cell.
    newCode: cell?
    /// Optional replacement persistent-data cell.
    newData: cell?
}

/// Internal message bodies accepted by the DAOLama vault.
type DaolamaVaultIncomingMessage =
    | DaolamaSupply
    | DaolamaLpBurnNotification
    | DaolamaNftOwnershipAssigned
    | DaolamaBorrow
    | DaolamaRepay
    | DaolamaCollectFees
    | DaolamaUpdateParams
    | DaolamaUpdateConfig
    | DaolamaSetHalted
    | DaolamaAdminSendMessage
    | DaolamaUpgrade

/// Standard TON-DLP wallet internal transfer emitted for mint and burn rollback.
struct (0x178d4519) DaolamaLpInternalTransfer {
    /// Query id copied from the supply or failed burn.
    queryId: uint64
    /// TON-DLP amount minted or restored.
    amount: coins
    /// Vault address acting as the jetton sender.
    fromAddress: address
    /// Address that receives remaining message value.
    responseDestination: address?
    /// Nanograms forwarded by the TON-DLP wallet.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard NFT transfer emitted after accepting a loan authorization.
struct (0x5fcc3d14) DaolamaNftTransfer {
    /// Query id copied from the ownership notification.
    queryId: uint64
    /// New NFT owner, normally the derived loan contract.
    newOwnerAddress: address
    /// Previous owner that receives transfer excesses.
    responseDestination: address?
    /// Optional NFT custom payload.
    customPayload: cell?
    /// Nanograms forwarded to the new NFT owner.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward-payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard excess-value response emitted after a successful TON-DLP burn.
struct (0xd53276db) DaolamaExcesses {
    /// Query id copied from the burn notification.
    queryId: uint64
}

/// Loan-funding body emitted to a newly deployed or existing loan contract.
struct (0x00000001) DaolamaFundLoan {
    /// Query id copied from the initiating request.
    queryId: uint64
    /// Principal nanograms assigned to the loan.
    amount: coins
    /// Maybe-ref signed authorization forwarded to the loan contract.
    proof: Cell<DaolamaLoanAuthorizationProof>?
}

/// Statically typed internal bodies emitted by the DAOLama vault.
type DaolamaVaultOutgoingMessage =
    | DaolamaLpInternalTransfer
    | DaolamaNftTransfer
    | DaolamaExcesses
    | DaolamaFundLoan

/// Five scalar lending-pool values exposed by `get_pool_data`.
struct DaolamaPoolData {
    /// Whether new borrow flows are disabled.
    halted: bool
    /// Liquid nanograms available in the vault.
    balance: int
    /// Principal nanograms currently assigned to active loans.
    borrowed: int
    /// Total TON-DLP supply in base units.
    lpTokenBalance: int
    /// Accrued protocol fees in nanograms.
    feeCollected: int
}

/// Standard TEP-74 jetton-master data for TON-DLP.
struct DaolamaJettonData {
    /// Total TON-DLP supply in base units.
    totalSupply: int
    /// Always true while signed TON-DLP supply messages are supported.
    mintable: bool
    /// Vault administrator address.
    adminAddress: address
    /// TON-DLP metadata content cell.
    jettonContent: cell
    /// TON-DLP wallet code cell.
    jettonWalletCode: cell
}

/// Exit codes produced by authorization, balance, admin, and dispatcher checks.
enum DaolamaVaultErrors {
    /// Destination address must belong to basechain workchain zero.
    InvalidWorkchain = 333
    /// Attached value or repayment funds are insufficient for the requested flow.
    InsufficientValue = 401
    /// Sender is neither the configured admin nor the expected deterministic wallet.
    UnauthorizedSender = 402
    /// Vault liquid or borrowed balance is insufficient.
    InsufficientVaultBalance = 403
    /// Signed supply amount, capacity check, or minted share amount is invalid.
    InvalidSupply = 404
    /// TON-DLP burn amount is invalid for withdrawal.
    InvalidWithdrawal = 405
    /// New borrowing is disabled while the vault is halted.
    VaultHalted = 406
    /// Signed authorization does not match the configured public key.
    InvalidSignature = 490
    /// Signed authorization targets another vault.
    InvalidVault = 491
    /// Signed authorization sender or derived loan address does not match.
    InvalidCounterparty = 492
    /// Signed authorization has expired.
    AuthorizationExpired = 493
    /// Signed operation tag does not match the dispatched request.
    InvalidSignedOperation = 494
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return halted, liquid, borrowed, LP-supply, and fee balances.
get fun get_pool_data(): DaolamaPoolData {
    throw 0;
}

/// Return the deterministic TON-DLP wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return standard TON-DLP jetton-master supply, admin, metadata, and wallet code.
get fun get_jetton_data(): DaolamaJettonData {
    throw 0;
}
