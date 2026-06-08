/// Stakee STAKEED Jetton minter with pool-admin minting, burn accounting, TEP-89 discovery, and DAO voting hooks.
contract StakeedMinter {
    author: "Stakee"
    version: "1.0"
    description: "Stakee STAKEED Jetton minter for pool-admin minting, burn accounting, discovery, DAO voting hooks, storage, and getters."
    storage: StakeedMinterStorage
    incomingMessages: StakeedMinterIncomingMessage
    outgoingMessages: StakeedMinterOutgoingMessage
    thrownErrors: StakeedMinterErrors
}

/// Persistent minter state stored in the account data cell.
struct StakeedMinterStorage {
    /// Total issued STAKEED jettons encoded as TL-B `Coins`.
    totalSupply: coins
    /// Pool/admin address authorized to mint, change admin/content, and upgrade code.
    adminAddress: address
    /// Referenced Jetton metadata content cell returned by `get_jetton_data`.
    jettonContent: cell
    /// Sequential DAO voting id used when deriving voting contract addresses.
    votingId: uint64
    /// Referenced DAO voting code cell used for voting state init derivation.
    votingCode: cell
}

/// Pool-admin mint request accepted by the STAKEED minter.
struct (0x1674b0a0) StakeedMinterMint {
    /// Query id copied into the wallet `internal_transfer` mint payload.
    queryId: uint64
    /// Owner address whose deterministic STAKEED wallet receives the minted jettons.
    toAddress: address
    /// Jetton amount minted to the destination wallet, in base units.
    jettonAmount: coins
    /// Nanotons forwarded from the wallet to the owner notification.
    forwardTonAmount: coins
    /// Nanotons attached to the wallet deployment/internal-transfer message; zero means carry remaining value.
    totalTonAmount: coins
}

/// Burn notification sent by a deterministic STAKEED wallet to decrease total supply.
struct (0x7bdd97de) StakeedMinterBurnNotification {
    /// Query id copied from the wallet burn request and minter response.
    queryId: uint64
    /// Burned STAKEED amount in base units.
    jettonAmount: coins
    /// Owner address whose deterministic wallet burned the jettons.
    fromAddress: address
    /// Optional response address copied into the admin notification or excesses response.
    responseAddress: address?
    /// Optional raw custom payload encoded as `Maybe ^Cell` and inlined into `jettons_burned` when present.
    customPayload: cell?
}

/// TEP-89 wallet discovery request accepted by the minter.
struct (0x2c76b973) StakeedMinterProvideWalletAddress {
    /// Caller-selected query id copied into the discovery response.
    queryId: uint64
    /// Owner address whose deterministic STAKEED wallet address is requested.
    ownerAddress: address
    /// True when the response must include a referenced copy of `ownerAddress`.
    includeAddress: bool
}

/// Admin request that replaces the stored admin address.
struct (0x4840664f) StakeedMinterChangeAdmin {
    /// Admin-selected query id carried by the change request.
    queryId: uint64
    /// New admin address stored in minter state.
    newAdminAddress: address
}

/// Admin request that replaces the stored metadata content cell.
struct (0x5773d1f5) StakeedMinterChangeContent {
    /// Admin-selected query id carried by the content change request.
    queryId: uint64
    /// Referenced replacement Jetton metadata content cell.
    jettonContent: cell
}

/// Admin request that optionally updates minter code and voting code.
struct (0x34aea60d) StakeedMinterUpgradeCode {
    /// Admin-selected query id carried by the upgrade request.
    queryId: uint64
    /// Optional replacement minter code encoded as `Maybe ^Cell`.
    minterCode: cell?
    /// Optional replacement DAO voting code encoded as `Maybe ^Cell`.
    votingCode: cell?
}

/// Request to create a DAO voting contract through the minter.
struct (0x1c7f9a1a) StakeedMinterCreateVoting {
    /// Query id copied into voting and voting-results initialization messages.
    queryId: uint64
    /// Expiration timestamp for voting type 0, or unused zero for poll-style voting type 1.
    expirationDate: uint48
    /// Referenced proposal cell; for voting type 1 it starts with duration:uint48 and a voting-body ref.
    proposal: cell
    /// Voting mode; value `1` is the poll-style mode.
    votingType: uint64
}

/// Notification from a derived voting contract that voting initialization completed.
struct (0x8e2abb23) StakeedMinterVotingInitiated {
    /// Query id copied from the original create-voting request.
    queryId: uint64
    /// Sequential voting id authenticated against the deterministic voting address.
    votingId: uint64
    /// Voting expiration timestamp stored as uint48.
    expirationDate: uint48
    /// Initiator address that receives the `voting_created` response.
    initiator: address
}

/// Vote-result execution request sent by a derived voting contract.
struct (0x4f0f7510) StakeedMinterExecuteVoteResult {
    /// Query id copied from the voting contract request.
    queryId: uint64
    /// Sequential voting id authenticated against the deterministic voting address.
    votingId: uint64
    /// Voting expiration timestamp; execution is rejected before this time.
    expirationDate: uint48
    /// Voting mode where `0` executes an arbitrary payload and `1` forwards tally results.
    votingType: uint64
    /// Votes in favor, encoded as TL-B `Coins`.
    votedFor: coins
    /// Votes against, encoded as TL-B `Coins`.
    votedAgainst: coins
    /// Optional result payload; type 1 expects the original poll proposal cell.
    payload: cell?
}

/// Voting contract request asking the minter to confirm a voter wallet.
struct (0x0222fdcb) StakeedMinterRequestConfirmVoting {
    /// Query id copied into the wallet `confirm_voting` request.
    queryId: uint64
    /// Sequential voting id authenticated against the deterministic voting address.
    votingId: uint64
    /// Voter owner address whose STAKEED wallet receives confirmation.
    voter: address
}

/// Minter-to-wallet mint transfer body emitted after an accepted mint request.
struct (0x178d4519) StakeedMinterJettonInternalTransfer {
    /// Query id copied from the minter mint request.
    queryId: uint64
    /// Minted jetton amount credited to the destination wallet.
    amount: coins
    /// Source owner address; STAKEED mint messages encode `addr_none`.
    fromAddress: address?
    /// Response address copied from the mint destination owner.
    responseAddress: address?
    /// Nanotons forwarded by the wallet to the owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Admin notification emitted when a wallet burn decreases total supply.
struct (0x319b0cdc) StakeedMinterJettonsBurned {
    /// Query id copied from the burn notification.
    queryId: uint64
    /// Burned STAKEED amount in base units.
    jettonAmount: coins
    /// Owner address reported by the burning wallet.
    fromAddress: address
    /// Response address reported by the burning wallet.
    responseAddress: address?
    /// Raw custom-payload tail inlined after `responseAddress`; empty when the burn carried no custom payload.
    customPayloadTail: RemainingBitsAndRefs
}

/// TEP-74 excesses response emitted when admin is unset and a response address is present.
struct (0xd53276db) StakeedMinterExcesses {
    /// Query id copied from the burn notification.
    queryId: uint64
}

/// TEP-89 discovery response emitted to the requester.
struct (0xd1735400) StakeedMinterTakeWalletAddress {
    /// Query id copied from `provide_wallet_address`.
    queryId: uint64
    /// Deterministic wallet address, or `addr_none` when the owner address cannot be resolved.
    walletAddress: address?
    /// Optional referenced owner address when the request asked to include it.
    ownerAddress: Cell<address>?
}

/// Voting initialization body emitted to a derived DAO voting contract.
struct (0x182d8ddd) StakeedMinterInitVoting {
    /// Query id copied from the create-voting request.
    queryId: uint64
    /// Absolute voting expiration timestamp.
    expirationDate: uint48
    /// Voting mode copied from the create-voting request.
    votingType: uint64
    /// Referenced proposal cell copied verbatim into the voting contract.
    proposal: cell
    /// Original create-voting message sender.
    initiator: address
}

/// Voting-results initialization body emitted before a poll-style voting contract is started.
struct (0x66afdef2) StakeedMinterInitVotingResults {
    /// Query id copied from the create-voting request.
    queryId: uint64
    /// Sequential voting id used by the results contract.
    votingId: uint64
}

/// Response emitted to the create-voting initiator after the voting contract acknowledges initialization.
struct (0xc39f0be6) StakeedMinterVotingCreated {
    /// Query id copied from the voting initiated message.
    queryId: uint64
    /// Deterministic address of the created voting contract.
    votingAddress: address
}

/// Poll result body emitted to the voting-results contract.
struct (0x57fe3672) StakeedMinterSendVoteResult {
    /// Query id copied from the execute-vote-result request.
    queryId: uint64
    /// Sequential voting id whose tally is being forwarded.
    votingId: uint64
    /// Votes in favor, encoded as TL-B `Coins`.
    votedFor: coins
    /// Votes against, encoded as TL-B `Coins`.
    votedAgainst: coins
}

/// Voter-wallet confirmation request emitted after a voting contract asks for voter confirmation.
struct (0x039a374e) StakeedMinterConfirmVoting {
    /// Query id copied from `request_confirm_voting`.
    queryId: uint64
}

/// Internal message bodies accepted by the STAKEED minter.
type StakeedMinterIncomingMessage =
    | StakeedMinterMint
    | StakeedMinterBurnNotification
    | StakeedMinterProvideWalletAddress
    | StakeedMinterChangeAdmin
    | StakeedMinterChangeContent
    | StakeedMinterUpgradeCode
    | StakeedMinterCreateVoting
    | StakeedMinterVotingInitiated
    | StakeedMinterExecuteVoteResult
    | StakeedMinterRequestConfirmVoting

/// Statically known internal message bodies emitted by the STAKEED minter.
type StakeedMinterOutgoingMessage =
    | StakeedMinterJettonInternalTransfer
    | StakeedMinterJettonsBurned
    | StakeedMinterExcesses
    | StakeedMinterTakeWalletAddress
    | StakeedMinterInitVoting
    | StakeedMinterInitVotingResults
    | StakeedMinterVotingCreated
    | StakeedMinterSendVoteResult
    | StakeedMinterConfirmVoting

/// Structured result returned by `get_jetton_data`.
struct GetStakeedMinterJettonDataReply {
    /// Total issued STAKEED returned as a TVM stack integer.
    totalSupply: int
    /// Mintability flag returned by `get_jetton_data`.
    mintable: bool
    /// Current pool/admin address.
    adminAddress: address
    /// Referenced Jetton metadata content cell.
    jettonContent: cell
    /// Embedded STAKEED wallet code cell used to derive wallet addresses.
    jettonWalletCode: cell
}

/// STAKEED minter exit-code catalog.
enum StakeedMinterErrors {
    /// Sender is not the stored admin for mint requests.
    UnauthorizedMintRequest = 73
    /// Burn notification did not come from the deterministic wallet for the reported owner.
    UnauthorizedBurnRequest = 74
    /// `provide_wallet_address` value cannot cover the discovery response budget.
    DiscoveryFeeNotMatched = 75
    /// Sender is not the stored admin for `change_admin`.
    UnauthorizedChangeAdminRequest = 76
    /// Sender is not the stored admin for `change_content`.
    UnauthorizedChangeContentRequest = 77
    /// Voting callback sender is not the deterministic voting contract.
    UnauthorizedVoteExecution = 78
    /// Sender is not the stored admin for code upgrades.
    UnauthorizedCodeUpgradeRequest = 79
    /// Create-voting request uses a voting mode forbidden by poll-style parameters.
    ForbiddenVotingType = 82
    /// Mint message value does not cover wallet forward amount and chain fee budget.
    MintFeeNotMatched = 83
    /// Execute-vote-result arrived before the recorded expiration timestamp.
    VotingNotFinished = 246
    /// Voting creation date or duration is already finished.
    VotingAlreadyFinished = 249
    /// Voting creation date or duration exceeds the maximum voting duration.
    ExpirationDateTooHigh = 3856
    /// Incoming internal message opcode is not supported by the minter dispatcher.
    UnknownOperation = 65535
}

/// Return total supply, mintability, admin address, content cell, and wallet code cell.
get fun get_jetton_data(): GetStakeedMinterJettonDataReply {
    throw 0;
}

/// Return the deterministic STAKEED wallet address for `ownerAddress`.
get fun get_wallet_address(ownerAddress: address): address {
    throw 0;
}

/// Return the deterministic DAO voting address for a sequential voting id.
get fun get_voting_address(votingId: uint64): address {
    throw 0;
}

/// Return the stored DAO voting code cell.
get fun get_voting_code(): cell {
    throw 0;
}

/// Return the deterministic voting-results contract address for a poll body and duration.
get fun get_voting_results_address(votingBody: cell, duration: uint48): address {
    throw 0;
}
