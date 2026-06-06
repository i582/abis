/// Storm Trade SmartAccount factory and deployer interface.
contract SmartAccountFactory {
    author: "Storm Trade"
    version: "1.0"
    description: "Storm Trade SmartAccountFactory ABI for storage, ordinary SmartAccount deployment messages, fee getters, and working NFT helpers."
    storage: SmartAccountFactoryStorage
    incomingMessages: SmartAccountFactoryIncomingMessage
    outgoingMessages: SmartAccountFactoryOutgoingMessage
}

/// Runtime storage for SmartAccountFactory.
struct SmartAccountFactoryStorage {
    /// Admin address authorized to mutate factory configuration.
    adminAddress: address
    /// Highload query timeout in seconds, stored as uint24.
    highloadTimeout: uint24
    /// Factory hot public key copied into newly initialized SmartAccount key storage.
    hotPublicKey: uint256
    /// Factory cold public key copied into newly initialized SmartAccount key storage.
    coldPublicKey: uint256
    /// Referenced NFT-style content cell.
    content: cell
    /// Ordinary SmartAccount code version stored alongside the deploy code cell.
    saOrdinaryVersion: uint8
    /// Referenced ordinary SmartAccount code used in initialization messages.
    saOrdinaryCode: cell
}

/// Key bundle embedded into SmartAccount initialization data.
struct SmartAccountFactoryKeys {
    /// Hot public key accepted by initialized SmartAccounts.
    hotPublicKey: uint256
    /// Cold public key accepted by initialized SmartAccounts.
    coldPublicKey: uint256
    /// User public keys stored as cells.
    userPublicKeys: map<uint256, cell>
    /// Number of user public keys included in the dictionary.
    keysCount: uint8
}

/// SmartAccount initialization payload forwarded from factory to the blank account code.
struct SmartAccountFactoryInitializationData {
    /// Highload query timeout in seconds copied from factory storage.
    highloadTimeout: uint24
    /// Referenced key bundle with factory and user public keys.
    keys: Cell<SmartAccountFactoryKeys>
    /// SmartAccount code version to store after initialization.
    version: uint8
    /// Ordinary SmartAccount code cell installed by the initialization flow.
    newCode: cell
}

/// Vault-originated deploy notification authenticated by the factory before deploying a blank account.
struct (0x5a89f5a2) StormNotifyWithDeploy {
    /// Query id copied into the outgoing deploy-with-deposit notification.
    queryId: uint64
    /// Asset amount forwarded from the vault notification.
    amount: coins
    /// User public keys dictionary for the new SmartAccount.
    userPublicKeys: map<uint256, cell>
    /// Original sender address forwarded into the outgoing deposit notification.
    senderAddress: address
    /// SmartAccount owner address used to derive the blank account StateInit.
    ownerAddress: address
    /// Jetton minter address authenticated as part of the vault-originated flow.
    jettonMinterAddress: address
}

/// User/admin deploy request for an ordinary SmartAccount without a deposit amount.
struct (0x0302cd79) StormDeployOrdinarySa {
    /// Query id copied into the outgoing initialization message.
    queryId: uint64
    /// User public keys dictionary for the new SmartAccount.
    userPublicKeys: map<uint256, cell>
}

/// Deposit-plus-initialization body emitted to a newly deployed blank SmartAccount.
struct (0x18a092f7) StormDepositNotifyWithDeploy {
    /// Query id copied from the incoming vault notification.
    queryId: uint64
    /// Vault address that authenticated the deploy-with-deposit flow.
    vaultAddress: address
    /// Deposit amount forwarded to the SmartAccount.
    amount: coins
    /// Original sender address forwarded from the vault notification.
    senderAddress: address
    /// Initialization data installed by the blank SmartAccount before processing the deposit.
    initData: SmartAccountFactoryInitializationData
}

/// Initialization body emitted to a newly deployed blank SmartAccount without a deposit amount.
struct (0x5b0dd9f4) StormInitSa {
    /// Query id copied from the ordinary deploy request.
    queryId: uint64
    /// Initialization data installed by the blank SmartAccount.
    initData: SmartAccountFactoryInitializationData
}

/// Admin request to replace the factory code cell and current continuation.
struct (0x179d61f9) SmartAccountFactoryUpgradeCode {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// New factory code cell installed with `set_code`.
    newCode: cell
}

/// Admin request to replace the hot public key stored by the factory.
struct (0x1bd24ca6) SmartAccountFactorySetHotPublicKey {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// Replacement hot public key stored as uint256.
    hotPublicKey: uint256
}

/// Admin request to send the stored cold public key to another address.
struct (0x7a0bda1c) SmartAccountFactoryRequestColdPublicKey {
    /// Query id copied into the outgoing cold-key reply.
    queryId: uint64
    /// Destination address that receives the cold-key reply body.
    replyAddress: address
}

/// Admin request to replace the cold public key stored by the factory.
struct (0x0b9d20cc) SmartAccountFactorySetColdPublicKey {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// Replacement cold public key stored as uint256.
    coldPublicKey: uint256
}

/// Admin request to replace ordinary SmartAccount code version and code cell.
struct (0x0c6ca95e) SmartAccountFactorySetOrdinarySmartAccountCode {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// Replacement ordinary SmartAccount code version.
    version: uint8
    /// Replacement ordinary SmartAccount code cell.
    code: cell
}

/// Admin request to replace the factory content cell.
struct (0x13559d58) SmartAccountFactorySetContent {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// Replacement NFT-style content cell.
    content: cell
}

/// Admin request to replace the factory admin address.
struct (0x5fc230d4) SmartAccountFactorySetAdmin {
    /// Query id echoed in the standard excess response.
    queryId: uint64
    /// Replacement admin address.
    newAdminAddress: address
}

/// Standard excess response emitted after successful admin mutations.
struct (0xd53276db) StormExcesses {
    /// Query id copied from the accepted admin request.
    queryId: uint64
}

/// Cold public key reply emitted to the admin-supplied destination address.
struct (0x70246da6) SmartAccountFactoryColdPublicKeyReply {
    /// Query id copied from the cold-key request.
    queryId: uint64
    /// Current admin address included in the reply body.
    adminAddress: address
    /// Current cold public key stored by the factory.
    coldPublicKey: uint256
}

/// Internal message bodies accepted by SmartAccountFactory deploy and admin dispatchers.
type SmartAccountFactoryIncomingMessage =
    | StormNotifyWithDeploy
    | StormDeployOrdinarySa
    | SmartAccountFactoryUpgradeCode
    | SmartAccountFactorySetHotPublicKey
    | SmartAccountFactoryRequestColdPublicKey
    | SmartAccountFactorySetColdPublicKey
    | SmartAccountFactorySetOrdinarySmartAccountCode
    | SmartAccountFactorySetContent
    | SmartAccountFactorySetAdmin

/// Internal message bodies emitted by SmartAccountFactory deploy and admin flows.
type SmartAccountFactoryOutgoingMessage =
    | StormDepositNotifyWithDeploy
    | StormInitSa
    | StormExcesses
    | SmartAccountFactoryColdPublicKeyReply

/// Factory configuration returned by `get_factory_data`.
struct SmartAccountFactoryDataReply {
    /// Admin address from factory storage.
    adminAddress: address
    /// Highload query timeout in seconds returned as a stack integer.
    highloadTimeout: uint32
    /// Factory hot public key returned as a stack integer.
    hotPublicKey: int
    /// Factory cold public key returned as a stack integer.
    coldPublicKey: int
    /// Raw content cell from factory storage.
    content: cell
    /// Ordinary SmartAccount code version from factory storage.
    saOrdinaryVersion: uint8
    /// Ordinary SmartAccount code cell from factory storage.
    saOrdinaryCode: cell
}

/// Minimum fee tuple returned by `get_min_fees`.
struct SmartAccountFactoryMinFeesReply {
    /// Minimum native-asset deposit fee in nanotons.
    depositMinFeeNative: coins
    /// Minimum jetton deposit fee in nanotons.
    depositMinFeeJetton: coins
    /// Minimum native-asset deposit-with-deploy fee in nanotons.
    depositWithDeployMinFeeNative: coins
    /// Minimum jetton deposit-with-deploy fee in nanotons.
    depositWithDeployMinFeeJetton: coins
    /// Minimum withdrawal fee in nanotons.
    withdrawMinFee: coins
    /// One-year storage fee estimate for an ordinary SmartAccount.
    ordinarySaStorageFee: coins
}

/// TEP-66-style royalty parameters returned by `royalty_params`.
struct SmartAccountFactoryRoyaltyParams {
    /// Royalty numerator.
    numerator: int
    /// Royalty denominator.
    denominator: int
    /// Royalty payout address, currently the factory admin address.
    royaltyAddress: address
}

/// SmartAccountFactory exit codes.
enum SmartAccountFactoryErrors {
    /// Deployment request did not attach enough balance for deploy and storage fees.
    NotEnoughGasToDeploy = 150
    /// Sender is not authorized for the requested factory operation.
    Unauthorized = 401
    /// Admin operation attached less value than required.
    InsufficientGas = 406
    /// SmartAccount deployment was attempted outside basechain workchain 0.
    WrongWorkchain = 710
    /// Incoming internal message opcode is not supported.
    WrongOperation = 65535
}

/// Return factory configuration and the ordinary SmartAccount code cell.
get fun get_factory_data(): SmartAccountFactoryDataReply {
    assert (true) throw SmartAccountFactoryErrors.NotEnoughGasToDeploy;
    assert (true) throw SmartAccountFactoryErrors.Unauthorized;
    assert (true) throw SmartAccountFactoryErrors.InsufficientGas;
    assert (true) throw SmartAccountFactoryErrors.WrongWorkchain;
    assert (true) throw SmartAccountFactoryErrors.WrongOperation;
    return {
        adminAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        highloadTimeout: 0,
        hotPublicKey: 0,
        coldPublicKey: 0,
        content: createEmptyCell(),
        saOrdinaryVersion: 0,
        saOrdinaryCode: createEmptyCell(),
    };
}

/// Return minimum fee thresholds for deposit, deposit-with-deploy, withdrawal, and ordinary SmartAccount storage.
get fun get_min_fees(): SmartAccountFactoryMinFeesReply {
    return {
        depositMinFeeNative: 0,
        depositMinFeeJetton: 0,
        depositWithDeployMinFeeNative: 0,
        depositWithDeployMinFeeJetton: 0,
        withdrawMinFee: 0,
        ordinarySaStorageFee: 0,
    };
}

/// Return royalty numerator, denominator, and payout address for the factory NFT collection helper.
get fun royalty_params(): SmartAccountFactoryRoyaltyParams {
    return {
        numerator: 0,
        denominator: 1,
        royaltyAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
    };
}

/// Return the deterministic blank SmartAccount address for the supplied item index.
get fun get_nft_address_by_index(itemIndex: int): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
