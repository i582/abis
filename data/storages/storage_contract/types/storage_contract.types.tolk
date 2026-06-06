/// TON Storage per-file agreement contract interface.
contract StorageContract {
    author: "TON Core"
    version: "1.0"
    description: "Official TON Storage per-file storage agreement contract interface"
    storage: StorageContractStorage
    incomingMessages: StorageContractIncomingMessage
    outgoingMessages: StorageContractOutgoingMessage
    forceAbiExport: StorageContractClientData
}

/// Persistent storage state stored in the root data cell.
struct StorageContractStorage {
    /// Whether the provider has accepted and activated the agreement.
    active: bool
    /// Client balance available to pay storage rewards, in nanotons.
    balance: coins
    /// Provider address authorized for accept, proof, withdraw, and close flows.
    provider: address
    /// Merkle root hash committed by the storage agreement.
    merkleHash: uint256
    /// Stored file size in bytes.
    fileSize: uint64
    /// Next random proof challenge index.
    nextProof: uint64
    /// Storage price in nanotons per MiB per day.
    ratePerMbDay: coins
    /// Maximum allowed span between proofs, in seconds.
    maxSpan: uint32
    /// Unix timestamp of the last accepted proof or deployment initialization.
    lastProofTime: uint32
    /// Referenced client address and torrent hash pair.
    clientData: Cell<StorageContractClientData>
}

/// Referenced client/torrent identity pair stored at the end of contract data.
struct StorageContractClientData {
    /// Client address authorized to close or top up the agreement.
    client: address
    /// Torrent hash identifying the stored bag metadata.
    torrentHash: uint256
}

/// Opcode-zero body treated as a balance top-up.
struct (0x00000000) StorageContractTopUp {
    /// Raw optional text/comment tail ignored by the contract.
    text: RemainingBitsAndRefs
}

/// Initial deploy body sent by the storage provider with StateInit.
struct (0xe4748df1) StorageDeployStorageContract {
    /// Query id copied from the original provider offer.
    queryId: uint64
}

/// Provider request to activate the agreement.
struct (0x7a361688) StorageAcceptStorageContract {
    /// Query id supplied by the provider.
    queryId: uint64
}

/// Provider or client request to close the agreement.
struct (0x79f937ea) StorageCloseContract {
    /// Query id supplied by the closer.
    queryId: uint64
}

/// Provider request to withdraw accumulated reward.
struct (0x46ed2e94) StorageWithdraw {
    /// Query id copied into the reward-withdrawal notification.
    queryId: uint64
}

/// Provider request carrying a referenced file dictionary Merkle proof.
struct (0x419d5d4d) StorageProofStorage {
    /// Query id for the proof transaction.
    queryId: uint64
    /// Referenced proof cell consumed by `check_proof`.
    fileDictProof: cell
}

/// Deployment confirmation sent from storage contract to client.
struct (0xbf7bd0c1) StorageContractDeployed {
    /// Query id copied from deploy body.
    queryId: uint64
    /// Torrent hash stored in client data.
    torrentHash: uint256
}

/// Activation confirmation sent from storage contract to client.
struct (0xd4caedcd) StorageContractConfirmed {
    /// Current logical time reported by the storage contract.
    curLt: uint64
    /// Torrent hash stored in client data.
    torrentHash: uint256
}

/// Termination notification sent to the provider and client.
struct (0xb6236d63) StorageContractTerminated {
    /// Current logical time reported by the storage contract.
    curLt: uint64
    /// Torrent hash stored in client data.
    torrentHash: uint256
}

/// Withdrawal notification sent to the provider after reward payout.
struct (0xa91baf56) StorageRewardWithdrawal {
    /// Query id copied from withdraw body.
    queryId: uint64
}

/// Internal message bodies accepted by a storage contract.
type StorageContractIncomingMessage =
    | StorageContractTopUp
    | StorageDeployStorageContract
    | StorageAcceptStorageContract
    | StorageCloseContract
    | StorageWithdraw
    | StorageProofStorage

/// Internal message bodies emitted by a storage contract.
type StorageContractOutgoingMessage =
    | StorageContractDeployed
    | StorageContractConfirmed
    | StorageContractTerminated
    | StorageRewardWithdrawal

/// Structured result returned by `get_storage_contract_data`.
struct StorageContractDataReply {
    /// Current active flag returned by the contract.
    active: bool
    /// Current client balance in nanotons.
    balance: coins
    /// Provider address stored in contract data.
    provider: address
    /// Merkle root hash committed by the agreement.
    merkleHash: uint256
    /// Stored file size in bytes.
    fileSize: uint64
    /// Next random proof challenge index.
    nextProof: uint64
    /// Storage price in nanotons per MiB per day.
    ratePerMbDay: coins
    /// Maximum allowed proof span, in seconds.
    maxSpan: uint32
    /// Unix timestamp of the last proof or initialization.
    lastProofTime: uint32
    /// Client address stored in referenced client data.
    client: address
    /// Torrent hash stored in referenced client data.
    torrentHash: uint256
}

/// Structured result returned by `get_next_proof_info`.
struct StorageContractNextProofInfoReply {
    /// Next random proof challenge index.
    nextProof: uint64
    /// Unix timestamp of the last proof or initialization.
    lastProofTime: uint32
    /// Maximum allowed proof span, in seconds.
    maxSpan: uint32
}

/// Storage contract exit-code catalog.
enum StorageContractErrors {
    /// Sender is not authorized for the requested action.
    Unauthorized = 401
    /// Submitted Merkle proof does not match the stored root or challenge.
    WrongProof = 1002
    /// Action requires an active agreement.
    ContractNotActive = 1003
    /// Provider attempted to accept an already active agreement.
    ContractAlreadyActive = 1007
}

/// Return full storage contract data as a flat stack tuple.
get fun get_storage_contract_data(): StorageContractDataReply {
    assert (true) throw StorageContractErrors.Unauthorized;
    assert (true) throw StorageContractErrors.WrongProof;
    assert (true) throw StorageContractErrors.ContractNotActive;
    assert (true) throw StorageContractErrors.ContractAlreadyActive;
    return {
        active: false,
        balance: 0,
        provider: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        merkleHash: 0,
        fileSize: 0,
        nextProof: 0,
        ratePerMbDay: 0,
        maxSpan: 0,
        lastProofTime: 0,
        client: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        torrentHash: 0,
    };
}

/// Return the torrent hash stored in client data.
get fun get_torrent_hash(): uint256 {
    return 0;
}

/// Return whether the agreement is active.
get fun is_active(): bool {
    return false;
}

/// Return the next proof index and timing parameters.
get fun get_next_proof_info(): StorageContractNextProofInfoReply {
    return {
        nextProof: 0,
        lastProofTime: 0,
        maxSpan: 0,
    };
}
