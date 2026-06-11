/// Curated ABI for the live DeDust Factory v1 contract.
contract DedustFactoryV1 {
    author: "DeDust"
    version: "1.0"
    description: "DeDust Factory v1 ABI for deterministic Vault, Pool, and Liquidity Deposit derivation plus factory administration messages."
    storage: DedustFactoryV1Storage
    incomingMessages: DedustFactoryV1IncomingMessage
    outgoingMessages: DedustFactoryV1OutgoingMessage
    thrownErrors: DedustFactoryV1Errors
}

/// Runtime Factory storage loaded from the v1 root data cell.
struct DedustFactoryV1Storage {
    /// Current Factory owner authorized for administrative messages.
    ownerAddress: address
    /// Pending owner selected by `transfer_ownership`, or `addr_none`.
    pendingOwnerAddress: address?
    /// Unix timestamp after which `accept_ownership` can complete.
    canAcceptAfter: uint32
    /// Factory code/configuration version returned by `get_version`.
    version: uint16
    /// Blank contract code used for deterministic child deployments.
    blankCode: cell
    /// Referenced common Factory child-code configuration.
    config: Cell<DedustFactoryV1Config>
}

/// Referenced Factory child-code configuration cell.
struct DedustFactoryV1Config {
    /// Installed Pool implementation code version.
    poolCodeVersion: uint16
    /// Installed Pool implementation code cell.
    poolCode: cell
    /// Installed Liquidity Deposit implementation code version.
    liquidityDepositCodeVersion: uint16
    /// Installed Liquidity Deposit implementation code cell.
    liquidityDepositCode: cell
    /// Optional dictionary of Vault implementation `(version, code)` entries by DeDust asset type.
    vaultCodeByAssetType: cell?
    /// LP Jetton wallet code forwarded into newly installed Pool storage.
    lpWalletCode: cell
}

/// Native TON asset tag accepted by the Factory asset parser.
struct (0b0000) DedustFactoryV1NativeAsset {}

/// Jetton asset tag accepted by the Factory asset parser.
struct (0b0001) DedustFactoryV1JettonAsset {
    /// Jetton master workchain id encoded as signed 8-bit integer.
    workchainId: int8
    /// Jetton master address hash encoded without the standard address tag.
    address: bits256
}

/// Asset variants accepted by Factory asset cells.
type DedustFactoryV1Asset =
    | DedustFactoryV1NativeAsset
    | DedustFactoryV1JettonAsset

/// Pool identity used in deterministic pool and liquidity-deposit derivation.
struct DedustFactoryV1PoolParams {
    /// False for volatile pools and true for stable pools.
    isStable: bool
    /// First sorted pool asset.
    asset0: DedustFactoryV1Asset
    /// Second sorted pool asset.
    asset1: DedustFactoryV1Asset
}

/// Factory proof for a Vault-derived request.
struct DedustFactoryV1VaultProof {
    /// Factory address embedded in the generated child StateInit proof.
    factoryAddress: address
    /// Contract type tag for Vault proofs.
    contractType: uint8
    /// Vault asset parameter committed to the proof.
    asset: DedustFactoryV1Asset
}

/// Referenced extra values used by `create_liquidity_deposit`.
struct DedustFactoryV1CreateLiquidityDepositExtra {
    /// Target balance for pool asset0 after the deposit is fulfilled.
    asset0TargetBalance: coins
    /// Target balance for pool asset1 after the deposit is fulfilled.
    asset1TargetBalance: coins
    /// Asset being deposited by the Vault that requests deposit creation.
    depositAsset: DedustFactoryV1Asset
    /// Amount of `depositAsset` forwarded to the Liquidity Deposit.
    depositAmount: coins
    /// Minimum LP amount required by the original user request.
    minLpAmount: coins
}

/// Install payload sent by the Factory to a Blank contract during child deployment.
struct (0x9b3aa3fa) DedustFactoryV1Install {
    /// Query id copied from the factory request that triggered deployment.
    queryId: uint64
    /// Blank contract code used for the deterministic StateInit.
    blankCode: cell
    /// Version of the contract code installed into the Blank.
    codeVersion: uint16
    /// Contract code cell installed into the Blank.
    code: cell
    /// Child-specific initialization tail stored inline by factory send sites.
    extraParams: RemainingBitsAndRefs
}

/// Child upgrade payload sent from Factory to an existing child contract.
struct (0x000001bc) DedustFactoryV1UpgradeChildCode {
    /// Query id copied from the factory request that triggered the upgrade.
    queryId: uint64
    /// Version of the replacement child code.
    codeVersion: uint16
    /// Replacement child code cell.
    code: cell
}

/// Command sent by the Factory to destroy a non-ready Vault.
struct (0x9d65482b) DedustFactoryV1DestroyNonReadyVaultCommand {
    /// Query id copied from `destroy_non_ready_vault`.
    queryId: uint64
}

/// Asset deposit forwarded from Factory to the created Liquidity Deposit.
struct (0x54240fe5) DedustFactoryV1DepositAsset {
    /// Query id copied from `create_liquidity_deposit`.
    queryId: uint64
    /// Asset deposited into the Liquidity Deposit.
    asset: DedustFactoryV1Asset
    /// Amount forwarded to the Liquidity Deposit.
    amount: coins
}

/// Request to transfer Factory ownership to `newOwnerAddress`.
struct (0xca61554e) DedustFactoryV1TransferOwnership {
    /// Caller-selected query id for ownership management traceability.
    queryId: uint64
    /// New owner address; TL-B allows `addr_none` to be encoded.
    newOwnerAddress: address?
}

/// Pending owner request to accept ownership.
struct (0xdee60404) DedustFactoryV1AcceptOwnership {
    /// Body tail ignored by this opcode handler.
    tail: RemainingBitsAndRefs
}

/// Current owner request to cancel a pending ownership transfer.
struct (0x16cb7fc2) DedustFactoryV1CancelOwnershipTransfer {
    /// Body tail ignored by this opcode handler.
    tail: RemainingBitsAndRefs
}

/// Owner request to install a Vault implementation for an asset type.
struct (0xbc3f26f6) DedustFactoryV1InstallVaultCode {
    /// Caller-selected query id.
    queryId: uint64
    /// DeDust asset type tag encoded as four bits.
    assetType: uint4
    /// Monotonic Vault code version.
    codeVersion: uint16
    /// New Vault code cell.
    code: cell
}

/// Public request to deploy the Vault for an asset if it is missing.
struct (0x21cfe02b) DedustFactoryV1CreateVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose deterministic Vault address is deployed.
    asset: DedustFactoryV1Asset
}

/// Request to deploy a legacy Jetton Vault through a resolver.
struct (0xc9a5752d) DedustFactoryV1CreateLegacyJettonVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Jetton master address for the legacy Vault.
    minterAddress: address
    /// Resolver address used by the legacy deployment path.
    resolverAddress: address
}

/// Request to upgrade the Vault for an existing asset.
struct (0x25d66911) DedustFactoryV1UpgradeVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose Vault code should be upgraded.
    asset: DedustFactoryV1Asset
}

/// Owner request to remove a non-ready Vault for an asset.
struct (0x8a518d0d) DedustFactoryV1DestroyNonReadyVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose non-ready Vault should be destroyed.
    asset: DedustFactoryV1Asset
}

/// Owner request to replace Factory code.
struct (0xdf4a27aa) DedustFactoryV1Upgrade {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Factory code version.
    codeVersion: uint16
    /// Replacement Factory code cell.
    code: cell
}

/// Owner request to return Factory excess gas.
struct (0x9f3f0937) DedustFactoryV1ResetGas {
    /// Body tail ignored by this opcode handler.
    tail: RemainingBitsAndRefs
}

/// Owner request to install Pool implementation code.
struct (0xa3e45df1) DedustFactoryV1InstallPoolCode {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Pool code version.
    codeVersion: uint16
    /// New Pool code cell.
    code: cell
}

/// Public request to deploy a volatile Pool for two sorted assets.
struct (0x97d51f2f) DedustFactoryV1CreateVolatilePool {
    /// Caller-selected query id.
    queryId: uint64
    /// First sorted pool asset.
    asset0: DedustFactoryV1Asset
    /// Second sorted pool asset.
    asset1: DedustFactoryV1Asset
}

/// Owner request to deploy a stable Pool.
struct (0x7c40ac87) DedustFactoryV1CreateStablePool {
    /// Caller-selected query id.
    queryId: uint64
    /// First sorted pool asset.
    asset0: DedustFactoryV1Asset
    /// Decimals for `asset0`, encoded as uint8.
    asset0Decimals: uint8
    /// Second sorted pool asset.
    asset1: DedustFactoryV1Asset
    /// Decimals for `asset1`, encoded as uint8.
    asset1Decimals: uint8
}

/// Owner request to upgrade an existing Pool implementation.
struct (0x53e252ae) DedustFactoryV1UpgradePool {
    /// Caller-selected query id.
    queryId: uint64
    /// Pool identity committed to the deterministic Pool address.
    poolParams: DedustFactoryV1PoolParams
}

/// Owner request to install Liquidity Deposit implementation code.
struct (0x99a84311) DedustFactoryV1InstallLiquidityDepositCode {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Liquidity Deposit code version.
    codeVersion: uint16
    /// New Liquidity Deposit code cell.
    code: cell
}

/// Vault request to create a Liquidity Deposit for an owner and pool.
struct (0xf04ec526) DedustFactoryV1CreateLiquidityDeposit {
    /// Query id copied from the user deposit request.
    queryId: uint64
    /// Proof that the requesting Vault belongs to this Factory.
    proof: Cell<DedustFactoryV1VaultProof>
    /// Owner whose deterministic Liquidity Deposit is created.
    ownerAddress: address
    /// Pool identity committed to the Liquidity Deposit address.
    poolParams: DedustFactoryV1PoolParams
    /// Referenced balance and deposit values.
    extra: Cell<DedustFactoryV1CreateLiquidityDepositExtra>
    /// Optional payload returned when the deposit succeeds.
    fulfillPayload: cell?
    /// Optional payload returned when the deposit is rejected.
    rejectPayload: cell?
}

/// Internal message bodies accepted by the Factory v1 dispatcher.
type DedustFactoryV1IncomingMessage =
    | DedustFactoryV1TransferOwnership
    | DedustFactoryV1AcceptOwnership
    | DedustFactoryV1CancelOwnershipTransfer
    | DedustFactoryV1InstallVaultCode
    | DedustFactoryV1CreateVault
    | DedustFactoryV1CreateLegacyJettonVault
    | DedustFactoryV1UpgradeVault
    | DedustFactoryV1DestroyNonReadyVault
    | DedustFactoryV1Upgrade
    | DedustFactoryV1ResetGas
    | DedustFactoryV1InstallPoolCode
    | DedustFactoryV1CreateVolatilePool
    | DedustFactoryV1CreateStablePool
    | DedustFactoryV1UpgradePool
    | DedustFactoryV1InstallLiquidityDepositCode
    | DedustFactoryV1CreateLiquidityDeposit

/// Message bodies proven at Factory v1 send sites.
type DedustFactoryV1OutgoingMessage =
    | DedustFactoryV1Install
    | DedustFactoryV1UpgradeChildCode
    | DedustFactoryV1DestroyNonReadyVaultCommand
    | DedustFactoryV1DepositAsset

/// DeDust Factory v1 exit-code catalog.
enum DedustFactoryV1Errors {
    /// Incoming administration message sender is not the current Factory owner.
    InvalidOwnerSender = 256
    /// Ownership acceptance sender is not the pending owner.
    InvalidPendingOwnerSender = 257
    /// Ownership acceptance delay has not elapsed.
    OwnershipDelayNotElapsed = 258
    /// Requested child implementation code is not installed.
    MissingChildCode = 260
    /// Asset tag or proof shape is invalid for this Factory.
    InvalidAssetOrProof = 261
    /// Pool asset order is invalid.
    InvalidAssetOrder = 262
    /// Liquidity-deposit creation sender is not the authenticated Vault.
    InvalidVaultSender = 264
    /// Replacement code version is not the next version.
    InvalidCodeVersion = 275
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Structured result returned by `get_ownership`.
struct DedustFactoryV1Ownership {
    /// Current owner stack address.
    ownerAddress: any_address
    /// Pending owner stack address, or `addr_none` when no transfer is pending.
    pendingOwnerAddress: any_address
    /// Unix timestamp after which the pending owner can accept.
    canAcceptAfter: uint32
}

/// Return current and pending owner addresses plus ownership acceptance timestamp.
get fun get_ownership(): DedustFactoryV1Ownership {
    throw 0;
}

/// Return the live Factory code/storage version.
get fun get_version(): uint16 {
    throw 0;
}

/// Return the deterministic Vault address for `asset`.
get fun get_vault_address(asset: slice): address {
    throw 0;
}

/// Return the deterministic Pool address for `poolType` (`0` volatile, `1` stable) and assets.
get fun get_pool_address(poolType: int, asset0: slice, asset1: slice): address {
    throw 0;
}

/// Return the deterministic Liquidity Deposit address for owner, pool type, and assets.
get fun get_liquidity_deposit_address(
    ownerAddress: address,
    poolType: int,
    asset0: slice,
    asset1: slice,
): address {
    throw 0;
}
