/// Mintless Jetton v1.0 wallet with Merkle-proof claim through transfer custom payload.
contract MintlessJettonWallet {
    author: "TON Core"
    version: "1.0"
    description: "Curated interface for ton-blockchain/mintless-jetton-contract v1.0 wallet"
    storage: MintlessJettonWalletStorage
    incomingMessages: MintlessJettonWalletIncomingMessage
    outgoingMessages: MintlessJettonWalletOutgoingMessage
}

/// Persistent mintless wallet state stored in the root data cell.
struct MintlessJettonWalletStorage {
    /// Four-bit claim status: 0 means airdrop not claimed, 1 means the wallet already claimed.
    status: uint4
    /// Jetton balance encoded as TL-B `Coins` in storage.
    balance: coins
    /// Owner address authorized for outgoing transfers, burns, and claim-triggering transfers.
    ownerAddress: address
    /// Jetton minter/master address authenticated for mint-originated internal transfers.
    jettonMasterAddress: address
    /// Merkle root copied from the minter and used to validate claim proofs.
    merkleRoot: uint256
    /// Ten-bit salt selected by the minter's wallet-state-init search.
    salt: uint10
}

/// Custom transfer payload that claims a mintless airdrop before sending jettons.
struct (0x0df602d6) MintlessAirdropClaim {
    /// Exotic Merkle proof cell whose inner dictionary maps owner address to amount and time window.
    proof: cell
}

/// Owner-originated TEP-74 transfer request accepted by the mintless wallet.
struct (0x0f8a7ea5) MintlessJettonWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// Jetton amount to debit from this wallet after any claim credit, in base units.
    amount: coins
    /// Destination owner address whose deterministic salted wallet receives the transfer.
    destination: address
    /// Optional response address for an `Excesses` refund.
    responseDestination: address?
    /// Optional referenced mintless claim payload; any present payload with another opcode is rejected.
    customPayload: Cell<MintlessAirdropClaim>?
    /// Nanotons forwarded to the destination owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Wallet-to-wallet or minter-to-wallet TEP-74 internal transfer body.
struct (0x178d4519) MintlessJettonWalletInternalTransfer {
    /// Query id copied from the source transfer or mint payload.
    queryId: uint64
    /// Jetton amount credited to the recipient wallet, in base units.
    amount: coins
    /// Source owner address reported by the sending wallet or mint payload.
    from: address?
    /// Optional response address for an `Excesses` refund after processing.
    responseAddress: address?
    /// Nanotons forwarded to the owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated TEP-74 burn request accepted by the mintless wallet.
struct (0x595f07bc) MintlessJettonWalletBurn {
    /// Caller-selected query id copied into the burn notification.
    queryId: uint64
    /// Jetton amount to burn from this wallet, in base units.
    amount: coins
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
    /// Optional referenced custom payload skipped by source burn logic.
    customPayload: cell?
}

/// Funding-only message accepted by the wallet without changing state.
struct (0xd372158c) MintlessJettonWalletTopUp {
    /// Caller-selected query id carried only for traceability.
    queryId: uint64
}

/// Burn notification emitted to the minter after a successful owner burn.
struct (0x7bdd97de) MintlessJettonWalletBurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned jetton amount in base units.
    amount: coins
    /// Wallet owner address reported to the minter.
    sender: address
    /// Optional response address for the minter's `Excesses` refund.
    responseDestination: address?
}

/// Owner notification emitted when an incoming transfer carries forward TON.
struct (0x7362d09c) MintlessJettonWalletTransferNotification {
    /// Query id copied from the internal transfer.
    queryId: uint64
    /// Received jetton amount in base units.
    amount: coins
    /// Source owner address reported by the internal transfer.
    sender: address?
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excesses response emitted to a transfer response address when value remains after processing.
struct (0xd53276db) MintlessJettonWalletExcesses {
    /// Query id copied from the request that produced the refund.
    queryId: uint64
}

/// Internal message bodies accepted by the mintless v1.0 wallet.
type MintlessJettonWalletIncomingMessage =
    | MintlessJettonWalletTransfer
    | MintlessJettonWalletInternalTransfer
    | MintlessJettonWalletBurn
    | MintlessJettonWalletTopUp

/// Internal message bodies emitted by the mintless v1.0 wallet.
type MintlessJettonWalletOutgoingMessage =
    | MintlessJettonWalletInternalTransfer
    | MintlessJettonWalletBurnNotification
    | MintlessJettonWalletTransferNotification
    | MintlessJettonWalletExcesses

/// Structured result returned by `get_wallet_data`.
struct GetMintlessJettonWalletDataReply {
    /// Jetton balance returned as a TVM stack integer.
    balance: int
    /// Wallet owner address.
    ownerAddress: address
    /// Jetton minter/master address.
    jettonMasterAddress: address
    /// Current wallet code cell; live deployments expose an exotic library reference cell.
    jettonWalletCode: cell
}

/// Mintless v1.0 wallet exit-code catalog from official FunC source.
enum MintlessJettonWalletErrors {
    /// Transfer or burn would make the stored jetton balance negative.
    InsufficientJettonBalance = 47
    /// Transfer, burn, or claim funding is below the required gas/forward-fee budget.
    NotEnoughGas = 48
    /// Forward payload layout is invalid for a validated transfer.
    InvalidMessage = 49
    /// Claim payload is present after this wallet has already claimed.
    AirdropAlreadyClaimed = 54
    /// Claim proof time window has not started yet.
    AirdropNotReady = 55
    /// Claim proof time window has already expired.
    AirdropFinished = 56
    /// Present transfer custom payload does not use `merkle_airdrop_claim`.
    UnknownCustomPayload = 57
    /// Sender is not the stored owner for transfer or burn requests.
    UnauthorizedOwner = 73
    /// Internal transfer sender is not the minter or deterministic salted peer wallet.
    InvalidSender = 74
    /// Destination owner address is outside the configured base workchain.
    WrongWorkchain = 333
    /// Claim proof cell is not exotic.
    NotExoticMerkleProof = 103
    /// Claim proof exotic cell is not a Merkle proof cell.
    NotMerkleProof = 104
    /// Claim proof hash does not match the stored Merkle root.
    WrongMerkleRoot = 105
    /// Claim proof dictionary has no entry for the wallet owner address.
    AirdropNotFound = 109
    /// Incoming internal message opcode is unsupported, or bounced body opcode is not recognized.
    UnsupportedOperation = 65535
}

/// Return wallet balance, owner address, minter address, and wallet code cell.
get fun get_wallet_data(): GetMintlessJettonWalletDataReply {
    // ABI-export scaffolding: constant assertions make every error variant visible in thrown_errors.
    assert (true) throw MintlessJettonWalletErrors.InsufficientJettonBalance;
    assert (true) throw MintlessJettonWalletErrors.NotEnoughGas;
    assert (true) throw MintlessJettonWalletErrors.InvalidMessage;
    assert (true) throw MintlessJettonWalletErrors.AirdropAlreadyClaimed;
    assert (true) throw MintlessJettonWalletErrors.AirdropNotReady;
    assert (true) throw MintlessJettonWalletErrors.AirdropFinished;
    assert (true) throw MintlessJettonWalletErrors.UnknownCustomPayload;
    assert (true) throw MintlessJettonWalletErrors.UnauthorizedOwner;
    assert (true) throw MintlessJettonWalletErrors.InvalidSender;
    assert (true) throw MintlessJettonWalletErrors.WrongWorkchain;
    assert (true) throw MintlessJettonWalletErrors.NotExoticMerkleProof;
    assert (true) throw MintlessJettonWalletErrors.NotMerkleProof;
    assert (true) throw MintlessJettonWalletErrors.WrongMerkleRoot;
    assert (true) throw MintlessJettonWalletErrors.AirdropNotFound;
    assert (true) throw MintlessJettonWalletErrors.UnsupportedOperation;
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return the stored four-bit claim status.
get fun get_status(): uint4 {
    return 0;
}

/// Return true when the wallet has already claimed its mintless airdrop.
get fun is_claimed(): bool {
    return false;
}
