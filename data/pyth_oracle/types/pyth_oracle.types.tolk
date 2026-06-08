/// Pyth Network price oracle for TON with Wormhole governance, price-feed updates, parsing responses, storage, and public getters.
contract PythOracle {
    author: "Pyth Network"
    version: "1.0"
    description: "Pyth Network TON oracle ABI for price updates, Wormhole governance state, parsing responses, storage, and live public getters."
    storage: PythOracleStorage
    incomingMessages: PythOracleIncomingMessage
    outgoingMessages: PythOracleOutgoingMessage
    thrownErrors: PythOracleErrors
}

/// Root account data cell split into four referenced storage sections.
struct PythOracleStorage {
    /// Referenced price-feed dictionary and update-fee section.
    priceFeeds: Cell<PythPriceFeedsStorage>
    /// Referenced valid data-source dictionary section.
    dataSources: Cell<PythDataSourcesStorage>
    /// Referenced guardian-set index and dictionary section.
    guardianSets: Cell<PythGuardianSetsStorage>
    /// Referenced chain, governance, and upgrade-control section.
    governance: Cell<PythGovernanceStorage>
}

/// Price-feed storage section.
struct PythPriceFeedsStorage {
    /// Latest price feeds keyed by 256-bit price feed id.
    latestPriceFeeds: map<uint256, PythStoredPriceFeed>
    /// Fee charged per update, stored as a 256-bit unsigned integer.
    singleUpdateFee: uint256
}

/// Dictionary value wrapping a stored price-feed cell.
struct PythStoredPriceFeed {
    /// Referenced current and EMA price pair.
    priceFeed: Cell<PythPriceFeed>
}

/// Current and exponential moving-average prices for a feed.
struct PythPriceFeed {
    /// Referenced latest price data.
    price: Cell<PythPrice>
    /// Referenced EMA price data.
    emaPrice: Cell<PythPrice>
}

/// Price tuple encoded in cells and returned by price getters.
struct PythPrice {
    /// Signed price value.
    price: int64
    /// Unsigned confidence interval.
    conf: uint64
    /// Signed decimal exponent.
    expo: int32
    /// Unix publish timestamp.
    publishTime: uint64
}

/// Valid data-source dictionary section.
struct PythDataSourcesStorage {
    /// One-bit signed validity flags keyed by the 256-bit data-source cell hash.
    isValidDataSource: map<uint256, int1>
}

/// Wormhole data source tuple.
struct PythDataSource {
    /// Wormhole emitter chain id.
    emitterChainId: uint16
    /// Wormhole emitter address as a 256-bit value.
    emitterAddress: uint256
}

/// Guardian-set storage section.
struct PythGuardianSetsStorage {
    /// Current guardian set index.
    currentGuardianSetIndex: uint32
    /// Guardian sets keyed by 32-bit guardian set index.
    guardianSets: map<uint32, PythStoredGuardianSet>
}

/// Dictionary value wrapping a guardian-set cell.
struct PythStoredGuardianSet {
    /// Referenced guardian set payload.
    guardianSet: Cell<PythGuardianSet>
}

/// Wormhole guardian set.
struct PythGuardianSet {
    /// Unix expiration timestamp, or zero for the active set.
    expirationTime: uint64
    /// Guardian Ethereum addresses keyed by 8-bit guardian index.
    keys: map<uint8, uint160>
}

/// Governance and upgrade-control storage section.
struct PythGovernanceStorage {
    /// Current Wormhole chain id for this contract.
    chainId: uint16
    /// Wormhole governance chain id.
    governanceChainId: uint16
    /// Wormhole governance contract address as a 256-bit value.
    governanceContract: uint256
    /// Consumed governance-action flags keyed by action hash.
    consumedGovernanceActions: map<uint256, int1>
    /// Referenced governance data-source tuple.
    governanceDataSource: Cell<PythDataSource>
    /// Last executed governance sequence.
    lastExecutedGovernanceSequence: uint64
    /// Governance data-source transfer index.
    governanceDataSourceIndex: uint32
    /// Authorized upgrade code hash, or zero when no upgrade is pending.
    upgradeCodeHash: uint256
}

/// Update guardian set from a referenced Wormhole VAA payload.
struct (0x00000001) PythUpdateGuardianSet {
    /// Referenced Wormhole VAA bytes encoded as a cell chain.
    vm: cell
}

/// Update stored price feeds from a referenced accumulator update payload.
struct (0x00000002) PythUpdatePriceFeeds {
    /// Referenced accumulator update bytes encoded as a cell chain.
    updateData: cell
}

/// Execute a referenced Wormhole governance action payload.
struct (0x00000003) PythExecuteGovernanceAction {
    /// Referenced governance VAA bytes encoded as a cell chain.
    governanceAction: cell
}

/// Upgrade contract code from a referenced code cell.
struct (0x00000004) PythUpgradeContract {
    /// New contract code cell.
    newCode: cell
}

/// Parse price feed updates and send selected feeds to a target address.
struct (0x00000005) PythParsePriceFeedUpdates {
    /// Referenced accumulator update bytes encoded as a cell chain.
    updateData: cell
    /// Referenced price-id request cell.
    priceIds: cell
    /// Minimum accepted publish timestamp.
    minPublishTime: uint64
    /// Maximum accepted publish timestamp.
    maxPublishTime: uint64
    /// Target address for the response body.
    targetAddress: address?
    /// Referenced custom payload returned in the response.
    customPayload: cell
}

/// Parse unique price feed updates and send selected feeds to a target address.
struct (0x00000006) PythParseUniquePriceFeedUpdates {
    /// Referenced accumulator update bytes encoded as a cell chain.
    updateData: cell
    /// Referenced price-id request cell.
    priceIds: cell
    /// Target publish timestamp.
    publishTime: uint64
    /// Maximum allowed staleness in seconds.
    maxStaleness: uint64
    /// Target address for the response body.
    targetAddress: address?
    /// Referenced custom payload returned in the response.
    customPayload: cell
}

/// Internal message bodies accepted by the Pyth oracle.
type PythOracleIncomingMessage =
    | PythUpdateGuardianSet
    | PythUpdatePriceFeeds
    | PythExecuteGovernanceAction
    | PythUpgradeContract
    | PythParsePriceFeedUpdates
    | PythParseUniquePriceFeedUpdates

/// Parse-updates response carrying selected price feeds.
struct (0x00000005) PythParsePriceFeedUpdatesResponse {
    /// Number of price feeds in the referenced response chain.
    numberOfPriceFeeds: uint8
    /// Referenced chain of selected price-feed cells.
    priceFeeds: cell
    /// Original internal-message sender address.
    senderAddress: address?
    /// Referenced original custom payload.
    customPayload: cell
}

/// Parse-unique-updates response carrying selected price feeds.
struct (0x00000006) PythParseUniquePriceFeedUpdatesResponse {
    /// Number of price feeds in the referenced response chain.
    numberOfPriceFeeds: uint8
    /// Referenced chain of selected price-feed cells.
    priceFeeds: cell
    /// Original internal-message sender address.
    senderAddress: address?
    /// Referenced original custom payload.
    customPayload: cell
}

/// Generic success response body.
struct (0x00010001) PythResponseSuccess {
    /// Referenced result payload.
    result: cell
    /// Referenced original custom payload.
    originalCustomPayload: cell
}

/// Error response body returned to the original sender.
struct (0x00010002) PythResponseError {
    /// Contract exit code that caused the response.
    errorCode: uint32
    /// Original request opcode.
    originalOpCode: uint32
    /// Referenced original custom payload.
    originalCustomPayload: cell
}

/// Internal message bodies emitted by the Pyth oracle.
type PythOracleOutgoingMessage =
    | PythParsePriceFeedUpdatesResponse
    | PythParseUniquePriceFeedUpdatesResponse
    | PythResponseSuccess
    | PythResponseError

/// Structured result returned by `get_guardian_set`.
struct GetPythGuardianSetReply {
    /// Guardian set expiration timestamp.
    expirationTime: int
    /// Raw guardian-key dictionary cell.
    keys: cell
    /// Number of guardian keys in the dictionary.
    keyCount: int
}

/// Pyth and Wormhole exit-code catalog.
enum PythOracleErrors {
    /// Guardian set is invalid for the verified Wormhole message.
    InvalidGuardianSet = 1000
    /// Wormhole VM version is invalid.
    InvalidVersion = 1001
    /// Requested guardian set was not found.
    GuardianSetNotFound = 1002
    /// Guardian set has expired.
    GuardianSetExpired = 1003
    /// Wormhole signatures are invalid.
    InvalidSignatures = 1004
    /// Wormhole emitter address is invalid.
    InvalidEmitterAddress = 1005
    /// Governance action was already consumed.
    GovernanceActionAlreadyConsumed = 1006
    /// Guardian-set keys length is invalid.
    InvalidGuardianSetKeysLength = 1007
    /// Signature length is invalid.
    InvalidSignatureLength = 1008
    /// Signature indices are not ascending.
    SignatureIndicesNotAscending = 1009
    /// Verified signatures do not reach quorum.
    NoQuorum = 1010
    /// Governance module is invalid.
    InvalidModule = 1011
    /// Governance action is invalid.
    InvalidGovernanceAction = 1012
    /// New guardian set index is invalid.
    NewGuardianSetIndexIsInvalid = 1013
    /// Guardian set key count does not match the payload length.
    GuardianSetKeysLengthNotEqual = 1014
    /// Guardian set upgrade payload length is invalid.
    InvalidGuardianSetUpgradeLength = 1015
    /// Governance chain is invalid.
    InvalidGovernanceChain = 1016
    /// Governance contract is invalid.
    InvalidGovernanceContract = 1017
    /// Guardian address is invalid.
    InvalidGuardianAddress = 1018
    /// Signature index is not increasing.
    SignatureIndexNotIncreasing = 1019
    /// Price feed was not found.
    PriceFeedNotFound = 2000
    /// Price is older than the requested period.
    OutdatedPrice = 2001
    /// Accumulator or governance magic is invalid.
    InvalidMagic = 2002
    /// Accumulator major version is invalid.
    InvalidMajorVersion = 2003
    /// Accumulator minor version is invalid.
    InvalidMinorVersion = 2004
    /// Update data source was not found.
    UpdateDataSourceNotFound = 2005
    /// Update data source is invalid.
    InvalidUpdateDataSource = 2006
    /// Merkle digest does not match.
    DigestMismatch = 2007
    /// Update data has trailing bytes.
    InvalidUpdateDataLength = 2008
    /// Update data type is invalid.
    InvalidUpdateDataType = 2009
    /// Price-feed message type is invalid.
    InvalidMessageType = 2010
    /// Attached value does not cover update fees.
    InsufficientFee = 2011
    /// Merkle proof size is invalid.
    InvalidProofSize = 2012
    /// Governance data source is invalid.
    InvalidGovernanceDataSource = 2013
    /// Governance message sequence is too old.
    OldGovernanceMessage = 2014
    /// Governance target chain is invalid.
    InvalidGovernanceTarget = 2015
    /// Governance magic is invalid.
    InvalidGovernanceMagic = 2016
    /// Governance module is invalid.
    InvalidGovernanceModule = 2017
    /// Pending upgrade code hash does not match.
    InvalidCodeHash = 2018
    /// Governance payload length is invalid.
    InvalidPayloadLength = 2019
    /// Requested price feed was not found in the accepted publish-time range.
    PriceFeedNotFoundWithinRange = 2020
    /// Attached value does not cover compute gas.
    InsufficientGas = 3000
}

/// Calculate total update fee for an accumulator update payload.
get fun get_update_fee(data: slice): int {
    throw 0;
}

/// Return the fee charged for a single price update.
get fun get_single_update_fee(): int {
    throw 0;
}

/// Return the governance data-source transfer index.
get fun get_governance_data_source_index(): int {
    throw 0;
}

/// Return the raw governance data-source cell.
get fun get_governance_data_source(): cell {
    throw 0;
}

/// Return the last executed governance sequence.
get fun get_last_executed_governance_sequence(): int {
    throw 0;
}

/// Return the one-bit validity flag for a data-source cell.
get fun get_is_valid_data_source(dataSource: cell): int {
    throw 0;
}

/// Return the latest stored price for a price feed id.
get fun get_price_unsafe(priceFeedId: int): PythPrice {
    throw 0;
}

/// Return the latest stored price if it is no older than `timePeriod` seconds.
get fun get_price_no_older_than(timePeriod: int, priceFeedId: int): PythPrice {
    throw 0;
}

/// Return the latest stored EMA price for a price feed id.
get fun get_ema_price_unsafe(priceFeedId: int): PythPrice {
    throw 0;
}

/// Return the latest stored EMA price if it is no older than `timePeriod` seconds.
get fun get_ema_price_no_older_than(timePeriod: int, priceFeedId: int): PythPrice {
    throw 0;
}

/// Return this contract's Wormhole chain id.
get fun get_chain_id(): int {
    throw 0;
}

/// Return the active Wormhole guardian set index.
get fun get_current_guardian_set_index(): int {
    throw 0;
}

/// Return guardian-set metadata and raw key dictionary for an index.
get fun get_guardian_set(index: int): GetPythGuardianSetReply {
    throw 0;
}

/// Return the Wormhole governance chain id.
get fun get_governance_chain_id(): int {
    throw 0;
}

/// Return the Wormhole governance contract address as a 256-bit value.
get fun get_governance_contract(): uint256 {
    throw 0;
}

/// Return whether a governance action hash has been consumed.
get fun governance_action_is_consumed(hash: uint256): int {
    throw 0;
}
