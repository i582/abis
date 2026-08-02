/// JVault pool factory interface confirmed against exact source and mainnet block 43915595.
contract JVaultPoolFactory {
    author: "JVault"
    description: "JVault staking-pool factory storage, NFT collection getters, pool deployment, fee collection, and administrative messages."
    storage: JVaultPoolFactoryStorage
    incomingMessages: JVaultPoolFactoryIncomingMessage
    outgoingMessages: JVaultPoolFactoryOutgoingMessage
    thrownErrors: JVaultPoolFactoryErrors
    forceAbiExport: JVaultPoolFactoryDeployNewPoolPayload | JVaultPoolFactoryDeployPoolPayload
}

/// Referenced administrator addresses, child code cells, and factory version.
struct JVaultPoolFactoryCodeState {
    /// Administrator allowed to collect protocol fees.
    adminAddress: address
    /// Owner allowed to replace child code and factory parameters.
    ownerAddress: address
    /// Uninitialized pool code variants keyed by the first pool index using the variant.
    poolUninitedCodes: map<uint32, cell>
    /// Initialized staking-pool code installed after deployment.
    poolInitedCode: cell
    /// Code used to derive staking-wallet children.
    stakeWalletCode: cell
    /// Code used to deploy reward Jetton minters.
    jettonMinterCode: cell
    /// Stored factory implementation version.
    version: uint16
}

/// Persistent state of the deployed JVault pool factory.
struct JVaultPoolFactoryStorage {
    /// Index assigned to the next staking pool.
    nextPoolId: uint32
    /// Optional referenced TEP-64 NFT collection content cell.
    collectionContent: cell?
    /// Minimum allowed commission for pool reward deposits.
    minRewardsCommission: uint16
    /// Fixed TON fee charged for an instant unstake.
    unstakeFee: coins
    /// Factory-owned JVT Jetton wallet receiving pool-creation fees.
    feesWalletAddress: address
    /// Pool-creation fee denominated in JVT basic units.
    creationFee: coins
    /// Referenced administrator addresses, child code, and version.
    codeState: Cell<JVaultPoolFactoryCodeState>
}

/// Tuple returned by the factory `get_storage_data` method.
struct JVaultPoolFactoryStorageData {
    /// Administrator allowed to collect protocol fees.
    adminAddress: address
    /// Owner allowed to replace code and factory parameters.
    ownerAddress: address
    /// Index assigned to the next staking pool.
    nextPoolId: int
    /// Optional NFT collection content stack cell.
    collectionContent: cell?
    /// Minimum allowed reward commission.
    minRewardsCommission: int
    /// Fixed TON fee for instant unstaking.
    unstakeFee: int
    /// Factory-owned JVT Jetton wallet.
    feesWalletAddress: address
    /// Pool-creation fee in JVT basic units.
    creationFee: int
    /// Raw optional uninitialized-pool-code dictionary returned on the TVM stack.
    poolUninitedCodes: cell?
    /// Initialized staking-pool code.
    poolInitedCode: cell
    /// Staking-wallet child code.
    stakeWalletCode: cell
    /// Reward Jetton-minter code.
    jettonMinterCode: cell
    /// Factory implementation version.
    version: int
}

/// Standard NFT collection data returned by `get_collection_data`.
struct JVaultPoolFactoryCollectionData {
    /// Index assigned to the next pool/NFT item.
    nextItemIndex: int
    /// Optional referenced TEP-64 collection content cell.
    collectionContent: cell?
    /// Collection owner represented by the factory administrator.
    ownerAddress: address
}

/// One lock-period configuration embedded in a new-pool deployment request.
struct JVaultPoolFactoryDeployLockPeriod {
    /// Maximum staking TVL accepted for this lock period.
    tvlLimit: coins
    /// Reward multiplier in thousandths, where 1000 means 1x.
    rewardMultiplier: uint16
    /// Deposit commission in protocol basis points.
    depositCommission: uint16
    /// Instant-unstake commission in protocol basis points.
    unstakeCommission: uint16
    /// Optional referenced TEP-64 content for the reward Jetton minter.
    jettonContent: cell?
}

/// Payload nested in a JVT transfer notification to create a staking pool.
struct (0xda861f17) JVaultPoolFactoryDeployNewPoolPayload {
    /// Jetton wallet owned by the future pool and holding the staked asset.
    lockWalletAddress: address
    /// Minimum accepted staking deposit.
    minDeposit: coins
    /// Maximum accepted staking deposit.
    maxDeposit: coins
    /// Pool configurations keyed by lock duration in seconds.
    lockPeriods: map<uint32, JVaultPoolFactoryDeployLockPeriod>
    /// Accounts permitted to stake; an empty dictionary disables membership.
    whitelist: map<address, bool>
    /// Commission charged when rewards are added, in protocol basis points.
    rewardsCommission: uint16
    /// Optional referenced TEP-64 content for the pool NFT item.
    nftContent: cell?
}

/// TEP-74 transfer notification accepted from the factory's JVT wallet.
struct (0x7362d09c) JVaultPoolFactoryTransferNotification {
    /// Query identifier copied from the originating Jetton transfer.
    queryId: uint64
    /// Number of JVT basic units transferred to the factory wallet.
    amount: coins
    /// Logical sender recorded by the notifying Jetton wallet.
    sender: address
    /// TEP-74 `Either Cell ^Cell` tail containing the nested deployment payload.
    forwardPayload: RemainingBitsAndRefs
}

/// Administrator request to withdraw all TON not needed for the reserve.
struct (0x37726bdb) JVaultPoolFactoryWithdrawTon {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
}

/// Administrator request to withdraw arbitrary Jettons held by a wallet.
struct (0x11c09682) JVaultPoolFactoryWithdrawJetton {
    /// Correlation identifier copied into the Jetton transfer.
    queryId: uint64
    /// Jetton wallet instructed to send the withdrawal.
    jettonWalletAddress: address
    /// Jetton amount transferred to the administrator.
    amount: coins
    /// Opaque payload forwarded after the Jetton transfer fields.
    forwardPayload: RemainingBitsAndRefs
}

/// Administrator request forwarded to one pool as a TON withdrawal command.
struct (0xe5b8268f) JVaultPoolFactorySendWithdrawTon {
    /// Correlation identifier forwarded to the pool.
    queryId: uint64
    /// Pool that receives the withdrawal command.
    poolAddress: address
}

/// Owner response that installs the factory-owned JVT wallet address.
struct (0xd1735400) JVaultPoolFactoryTakeWalletAddress {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// JVT wallet owned by the factory.
    walletAddress: address
}

/// Owner request to replace the JVT pool-creation fee.
struct (0x66d5528b) JVaultPoolFactoryChangeCreationFee {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// New fee in JVT basic units.
    creationFee: coins
}

/// Owner request to replace referenced NFT collection content.
struct (0x0ec29200) JVaultPoolFactoryChangeContent {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// Optional replacement TEP-64 content cell.
    collectionContent: cell?
}

/// Owner request to add the code used for pools starting at the next index.
struct (0x7c2e94e0) JVaultPoolFactoryUpdateUninitedCode {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// New uninitialized staking-pool code.
    poolUninitedCode: cell
}

/// Owner request to replace the three child implementation code cells.
struct (0x85c923cf) JVaultPoolFactoryUpdateCodes {
    /// Correlation identifier copied into the excess response.
    queryId: uint64
    /// Initialized staking-pool code.
    poolInitedCode: cell
    /// Staking-wallet child code.
    stakeWalletCode: cell
    /// Reward Jetton-minter code.
    jettonMinterCode: cell
}

/// Owner request to replace factory code and optionally persistent data.
struct (0xe2d2d211) JVaultPoolFactorySetCode {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// Replacement executable code stored as a mandatory reference.
    code: cell
    /// Empty to preserve current data, or a trailing untagged data reference.
    optionalData: RemainingBitsAndRefs
}

/// Owner request to forward an arbitrary referenced body.
struct (0xa47d989c) JVaultPoolFactorySendAnyMessage {
    /// Correlation identifier accepted by the management envelope.
    queryId: uint64
    /// Contract that receives the arbitrary body.
    destination: address
    /// Complete body cell forwarded without interpretation.
    payload: cell
}

/// Untagged initialization payload sent while deploying a new staking pool.
struct JVaultPoolFactoryDeployPoolPayload {
    /// Jetton wallet owned by the new pool.
    lockWalletAddress: address
    /// Complete initial persistent pool data.
    poolData: cell
    /// Initialized pool code installed by the new pool.
    poolInitedCode: cell
}

/// Standard Jetton transfer emitted for creation fees and withdrawal refunds.
struct (0x0f8a7ea5) JVaultPoolFactoryJettonTransfer {
    /// Correlation identifier copied from the triggering request.
    queryId: uint64
    /// Jetton amount transferred by the addressed Jetton wallet.
    amount: coins
    /// Logical Jetton recipient.
    destination: address
    /// Address receiving any excess TON, or `addr_none` when omitted.
    responseDestination: address?
    /// Optional custom payload; JVault emits no custom payload in these flows.
    customPayload: cell?
    /// TON forwarded with the Jetton notification.
    forwardTonAmount: coins
    /// Optional referenced comment or application payload.
    forwardPayload: Cell<RemainingBitsAndRefs>?
}

/// Standard excess-value response emitted after a code update.
struct (0xd53276db) JVaultPoolFactoryExcesses {
    /// Correlation identifier copied from the triggering request.
    queryId: uint64
}

/// TON-withdrawal command forwarded to a selected staking pool.
struct (0x37726bdb) JVaultPoolFactoryForwardWithdrawTon {
    /// Correlation identifier copied from the administrator request.
    queryId: uint64
}

/// UTF-8 comment body emitted for fee, content, code, and TON notices.
struct (0x00000000) JVaultPoolFactoryTextComment {
    /// Remaining UTF-8 comment bytes after the zero opcode.
    text: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the pinned factory implementation.
type JVaultPoolFactoryIncomingMessage =
    | JVaultPoolFactoryTransferNotification
    | JVaultPoolFactoryWithdrawTon
    | JVaultPoolFactoryWithdrawJetton
    | JVaultPoolFactorySendWithdrawTon
    | JVaultPoolFactoryTakeWalletAddress
    | JVaultPoolFactoryChangeCreationFee
    | JVaultPoolFactoryChangeContent
    | JVaultPoolFactoryUpdateUninitedCode
    | JVaultPoolFactoryUpdateCodes
    | JVaultPoolFactorySetCode
    | JVaultPoolFactorySendAnyMessage
    | JVaultPoolFactoryExcesses
    | JVaultPoolFactoryTextComment

/// Tagged internal message bodies emitted by the pinned factory implementation.
type JVaultPoolFactoryOutgoingMessage =
    | JVaultPoolFactoryJettonTransfer
    | JVaultPoolFactoryExcesses
    | JVaultPoolFactoryForwardWithdrawTon
    | JVaultPoolFactoryTextComment

/// Exit codes thrown by the pinned factory implementation.
enum JVaultPoolFactoryErrors {
    /// Attached TON does not cover pool/minter deployment and compute fees.
    OutOfGas = 13
    /// Maximum deposit is lower than the minimum deposit.
    MoreThanMaximumDeposit = 42
    /// Pool-creation notification came from a wallet other than the configured JVT wallet.
    IncorrectJetton = 43
    /// Requested rewards commission is lower than the factory minimum.
    IncorrectRewardsCommission = 45
    /// Transferred JVT amount does not equal the pool-creation fee.
    NotEnoughJettons = 46
    /// Sender is not the configured administrator or owner.
    IncorrectSender = 50
    /// Incoming opcode is not implemented by the factory.
    UnsupportedOperation = 65535
}

/// Return NFT collection count, referenced content, and administrator address.
get fun get_collection_data(): JVaultPoolFactoryCollectionData {
    throw 0;
}

/// Return individual NFT content unchanged, as required by the collection standard.
get fun get_nft_content(index: int, individualContent: cell): cell {
    throw 0;
}

/// Derive a staking-pool address from its factory index.
get fun get_nft_address_by_index(index: int): address {
    throw 0;
}

/// Return all public factory storage fields and child code cells.
get fun get_storage_data(): JVaultPoolFactoryStorageData {
    throw 0;
}
