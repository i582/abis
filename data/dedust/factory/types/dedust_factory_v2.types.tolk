/// Curated ABI for the live DeDust Protocol v2 Factory contract.
contract DedustFactoryV2 {
    author: "DeDust"
    version: "2.0"
    description: "DeDust Protocol v2 Factory ABI for deterministic Vault, Pool, Operator, and Liquidity Deposit derivation, verified factory administration messages, and exit codes."
    storage: DedustFactoryV2Storage
    incomingMessages: DedustFactoryV2IncomingMessage
    outgoingMessages: DedustFactoryV2OutgoingMessage
}

/// Runtime Factory storage loaded by the verified v2 code root data cell.
struct DedustFactoryV2Storage {
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
    config: Cell<DedustFactoryV2Config>
    /// Version of the installed Operator implementation code.
    operatorCodeVersion: uint16
    /// Optional Operator implementation code cell used by deterministic operator deployments.
    operatorCode: cell?
}

/// Referenced Factory child-code configuration cell.
struct DedustFactoryV2Config {
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

/// Native TON asset tag accepted by the live factory asset parser.
struct (0b0000) DedustFactoryV2NativeAsset {}

/// Jetton asset tag accepted by the live factory asset parser.
struct (0b0001) DedustFactoryV2JettonAsset {
    /// Jetton master workchain id encoded as signed 8-bit integer.
    workchainId: int8
    /// Jetton master address hash encoded without the standard address tag.
    address: bits256
}

/// Asset variants accepted by Factory asset cells.
type DedustFactoryV2Asset =
    | DedustFactoryV2NativeAsset
    | DedustFactoryV2JettonAsset

/// Pool identity used in deterministic pool and liquidity-deposit derivation.
struct DedustFactoryV2PoolParams {
    /// False for volatile pools and true for stable pools.
    isStable: bool
    /// First sorted pool asset.
    asset0: DedustFactoryV2Asset
    /// Second sorted pool asset.
    asset1: DedustFactoryV2Asset
}

/// Factory proof for a Vault-derived request.
struct DedustFactoryV2VaultProof {
    /// Factory address embedded in the generated child StateInit proof.
    factoryAddress: address
    /// Contract type tag; TL-B assigns `1` to Vault proofs.
    contractType: uint8
    /// Vault asset parameter committed to the proof.
    asset: DedustFactoryV2Asset
}

/// Referenced extra values used by `create_liquidity_deposit`.
struct DedustFactoryV2CreateLiquidityDepositExtra {
    /// Target balance for pool asset0 after the deposit is fulfilled.
    asset0TargetBalance: coins
    /// Target balance for pool asset1 after the deposit is fulfilled.
    asset1TargetBalance: coins
    /// Asset being deposited by the Vault that requests deposit creation.
    depositAsset: DedustFactoryV2Asset
    /// Amount of `depositAsset` forwarded to the Liquidity Deposit.
    depositAmount: coins
    /// Minimum LP amount required by the original user request.
    minLpAmount: coins
}

/// Install payload sent by the Factory to a Blank contract during child deployment.
struct (0x9b3aa3fa) DedustFactoryV2Install {
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

/// Asset deposit forwarded from Factory to the created Liquidity Deposit.
struct (0x54240fe5) DedustFactoryV2DepositAsset {
    /// Query id copied from `create_liquidity_deposit`.
    queryId: uint64
    /// Asset deposited into the Liquidity Deposit.
    asset: DedustFactoryV2Asset
    /// Amount forwarded to the Liquidity Deposit.
    amount: coins
}

/// Request to transfer Factory ownership to `newOwnerAddress`.
struct (0xca61554e) DedustFactoryV2TransferOwnership {
    /// Caller-selected query id for ownership management traceability.
    queryId: uint64
    /// New owner address; TL-B allows `addr_none` to be encoded.
    newOwnerAddress: address?
}

/// Pending owner request to accept ownership after the configured delay.
struct (0xdee60404) DedustFactoryV2AcceptOwnership {
    /// Caller-selected query id for ownership management traceability.
    queryId: uint64
}

/// Current owner request to cancel a pending ownership transfer.
struct (0x16cb7fc2) DedustFactoryV2CancelOwnershipTransfer {
    /// Caller-selected query id for ownership management traceability.
    queryId: uint64
}

/// Owner/operator request to install a Vault implementation for an asset type.
struct (0xbc3f26f6) DedustFactoryV2InstallVaultCode {
    /// Caller-selected query id.
    queryId: uint64
    /// DeDust asset type tag encoded as four bits; live parser proves native and jetton tags.
    assetType: uint4
    /// Monotonic Vault code version.
    codeVersion: uint16
    /// New Vault code cell.
    code: cell
}

/// Public request to deploy the Vault for an asset if it is missing.
struct (0x21cfe02b) DedustFactoryV2CreateVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose deterministic Vault address is deployed.
    asset: DedustFactoryV2Asset
}

/// Request to deploy a legacy Jetton Vault through a resolver.
struct (0xc9a5752d) DedustFactoryV2CreateLegacyJettonVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Jetton master address for the legacy Vault.
    minterAddress: address
    /// Resolver address used by the legacy deployment path.
    resolverAddress: address
}

/// Request to upgrade the Vault for an existing asset.
struct (0x25d66911) DedustFactoryV2UpgradeVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose Vault code should be upgraded.
    asset: DedustFactoryV2Asset
}

/// Owner request to replace Factory code.
struct (0xdf4a27aa) DedustFactoryV2Upgrade {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Factory code version.
    codeVersion: uint16
    /// Replacement Factory code cell.
    code: cell
}

/// Owner request to return Factory excess gas.
struct (0x9f3f0937) DedustFactoryV2ResetGas {
    /// Caller-selected query id.
    queryId: uint64
}

/// Owner request to deploy an Operator contract for a role and user.
struct (0xb9d29997) DedustFactoryV2DeployOperator {
    /// Caller-selected query id.
    queryId: uint64
    /// Role tag encoded as uint8 in Factory proofs.
    role: uint8
    /// User address assigned to the Operator.
    userAddress: address
}

/// Owner request to change the user address for an existing Operator role.
struct (0x1be6df93) DedustFactoryV2ChangeOperatorUserAddress {
    /// Caller-selected query id.
    queryId: uint64
    /// Role tag encoded as uint8 in Factory proofs.
    role: uint8
    /// Replacement user address.
    userAddress: address
}

/// Owner request to install Operator contract code.
struct (0xe505d21a) DedustFactoryV2InstallOperatorCode {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Operator code version.
    codeVersion: uint16
    /// New Operator code cell.
    code: cell
}

/// Owner request to upgrade an Operator contract for a role.
struct (0x0085f5a3) DedustFactoryV2UpgradeOperator {
    /// Caller-selected query id.
    queryId: uint64
    /// Role tag encoded as uint8 in Factory proofs.
    role: uint8
}

/// Owner/operator request to install Pool implementation code.
struct (0xa3e45df1) DedustFactoryV2InstallPoolCode {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Pool code version.
    codeVersion: uint16
    /// New Pool code cell.
    code: cell
}

/// Public request to deploy a volatile Pool for two sorted assets.
struct (0x97d51f2f) DedustFactoryV2CreateVolatilePool {
    /// Caller-selected query id.
    queryId: uint64
    /// First sorted pool asset.
    asset0: DedustFactoryV2Asset
    /// Second sorted pool asset.
    asset1: DedustFactoryV2Asset
}

/// Stable-pool-factory operator request to deploy a stable Pool.
struct (0x7c40ac87) DedustFactoryV2CreateStablePool {
    /// Caller-selected query id.
    queryId: uint64
    /// First sorted pool asset.
    asset0: DedustFactoryV2Asset
    /// Decimals for `asset0`, encoded as uint8.
    asset0Decimals: uint8
    /// Second sorted pool asset.
    asset1: DedustFactoryV2Asset
    /// Decimals for `asset1`, encoded as uint8.
    asset1Decimals: uint8
}

/// Owner/operator request to upgrade an existing Pool implementation.
struct (0x53e252ae) DedustFactoryV2UpgradePool {
    /// Caller-selected query id.
    queryId: uint64
    /// Pool identity committed to the deterministic Pool address.
    poolParams: DedustFactoryV2PoolParams
}

/// Owner/operator request to install Liquidity Deposit implementation code.
struct (0x99a84311) DedustFactoryV2InstallLiquidityDepositCode {
    /// Caller-selected query id.
    queryId: uint64
    /// Monotonic Liquidity Deposit code version.
    codeVersion: uint16
    /// New Liquidity Deposit code cell.
    code: cell
}

/// Vault request to create a Liquidity Deposit for an owner and pool.
struct (0xf04ec526) DedustFactoryV2CreateLiquidityDeposit {
    /// Query id copied from the user deposit request.
    queryId: uint64
    /// Proof that the requesting Vault belongs to this Factory.
    proof: Cell<DedustFactoryV2VaultProof>
    /// Owner whose deterministic Liquidity Deposit is created.
    ownerAddress: address
    /// Pool identity committed to the Liquidity Deposit address.
    poolParams: DedustFactoryV2PoolParams
    /// Referenced balance and deposit values.
    extra: Cell<DedustFactoryV2CreateLiquidityDepositExtra>
    /// Optional payload returned when the deposit succeeds.
    fulfillPayload: cell?
    /// Optional payload returned when the deposit is rejected.
    rejectPayload: cell?
}

/// Owner request to remove a non-ready Vault for an asset.
struct (0x8a518d0d) DedustFactoryV2DestroyNonReadyVault {
    /// Caller-selected query id.
    queryId: uint64
    /// Asset whose non-ready Vault should be destroyed.
    asset: DedustFactoryV2Asset
}

/// Internal message bodies accepted by the verified Factory v2 dispatcher.
type DedustFactoryV2IncomingMessage =
    | DedustFactoryV2TransferOwnership
    | DedustFactoryV2AcceptOwnership
    | DedustFactoryV2CancelOwnershipTransfer
    | DedustFactoryV2InstallVaultCode
    | DedustFactoryV2CreateVault
    | DedustFactoryV2CreateLegacyJettonVault
    | DedustFactoryV2UpgradeVault
    | DedustFactoryV2DestroyNonReadyVault
    | DedustFactoryV2Upgrade
    | DedustFactoryV2ResetGas
    | DedustFactoryV2DeployOperator
    | DedustFactoryV2ChangeOperatorUserAddress
    | DedustFactoryV2InstallOperatorCode
    | DedustFactoryV2UpgradeOperator
    | DedustFactoryV2InstallPoolCode
    | DedustFactoryV2CreateVolatilePool
    | DedustFactoryV2CreateStablePool
    | DedustFactoryV2UpgradePool
    | DedustFactoryV2InstallLiquidityDepositCode
    | DedustFactoryV2CreateLiquidityDeposit

/// Message bodies proven at Factory send sites.
type DedustFactoryV2OutgoingMessage =
    | DedustFactoryV2Install
    | DedustFactoryV2DepositAsset

/// DeDust Factory v2 exit-code catalog.
enum DedustFactoryV2Errors {
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
    /// Attached value cannot cover the required deployment budget.
    InsufficientValue = 263
    /// Liquidity-deposit creation sender is not the authenticated Vault.
    InvalidVaultSender = 264
    /// Replacement code version is not the next version.
    InvalidCodeVersion = 275
    /// Operator-only request sender is not the deterministic Operator contract.
    InvalidOperatorSender = 296
    /// Incoming internal message opcode is unsupported.
    UnsupportedOperation = 65535
}

/// Structured result returned by `get_ownership`.
struct DedustFactoryV2Ownership {
    /// Current owner stack address; expected to be an internal address on live mainnet.
    ownerAddress: any_address
    /// Pending owner stack address, or `addr_none` when no transfer is pending.
    pendingOwnerAddress: any_address
    /// Unix timestamp after which the pending owner can accept.
    canAcceptAfter: uint32
}

/// Return current and pending owner addresses plus ownership acceptance timestamp.
get fun get_ownership(): DedustFactoryV2Ownership {
    return {
        ownerAddress: createAddressNone(),
        pendingOwnerAddress: createAddressNone(),
        canAcceptAfter: 0,
    };
}

/// Return the live Factory code/storage version.
get fun get_version(): uint16 {
    assert (true) throw DedustFactoryV2Errors.InvalidOwnerSender;
    assert (true) throw DedustFactoryV2Errors.InvalidPendingOwnerSender;
    assert (true) throw DedustFactoryV2Errors.OwnershipDelayNotElapsed;
    assert (true) throw DedustFactoryV2Errors.MissingChildCode;
    assert (true) throw DedustFactoryV2Errors.InvalidAssetOrProof;
    assert (true) throw DedustFactoryV2Errors.InvalidAssetOrder;
    assert (true) throw DedustFactoryV2Errors.InsufficientValue;
    assert (true) throw DedustFactoryV2Errors.InvalidVaultSender;
    assert (true) throw DedustFactoryV2Errors.InvalidCodeVersion;
    assert (true) throw DedustFactoryV2Errors.InvalidOperatorSender;
    assert (true) throw DedustFactoryV2Errors.UnsupportedOperation;
    return 0;
}

/// Return the deterministic Vault address for `asset`.
get fun get_vault_address(asset: slice): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the deterministic Pool address for `poolType` (`0` volatile, `1` stable) and assets.
get fun get_pool_address(poolType: int, asset0: slice, asset1: slice): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

/// Return the deterministic Liquidity Deposit address for owner, pool type, and assets.
get fun get_liquidity_deposit_address(ownerAddress: address, poolType: int, asset0: slice, asset1: slice): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
