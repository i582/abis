/// Tonstakers tsTON wallet interface for TEP-74 Jetton wallet flows, DAO voting messages, extended storage, getters, and exit codes.
contract TsTonWallet {
    author: "Tonstakers"
    version: "1.0"
    description: "Tonstakers tsTON Jetton wallet for transfers, burns, excess handling, DAO voting lock flows, storage, and getters."
    storage: TsTonWalletStorage
    incomingMessages: TsTonWalletIncomingMessage
    outgoingMessages: TsTonWalletOutgoingMessage
    forceAbiExport: TsTonWalletBouncedKnownBody
}

/// Runtime tsTON wallet state stored in the root data cell.
struct TsTonWalletStorage {
    /// Stored spendable tsTON balance encoded as TL-B `Coins`.
    balance: coins
    /// Wallet owner authorized to transfer, burn, withdraw accidental assets, and start DAO voting.
    ownerAddress: address
    /// tsTON Jetton master/minter address authenticated for minter-originated wallet callbacks.
    jettonMasterAddress: address
    /// Referenced wallet code cell used to derive and authenticate peer tsTON wallets.
    jettonWalletCode: cell
    /// tsTON amount locked for DAO vote weight until `lockExpiration`.
    locked: coins
    /// Lock expiration timestamp stored as uint48.
    lockExpiration: uint48
}

/// Owner-originated standard Jetton transfer request accepted by the wallet.
struct (0x0f8a7ea5) TsTonWalletTransfer {
    /// Caller-selected query id copied into the outgoing internal transfer.
    queryId: uint64
    /// tsTON amount debited from this wallet.
    amount: coins
    /// Destination owner whose deterministic tsTON wallet receives the transfer.
    destination: address
    /// Optional excess-refund address; `addr_none` suppresses the recipient-wallet excess response.
    responseDestination: address?
    /// Optional standard Jetton custom payload parsed and ignored by the live wallet.
    customPayload: cell?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail copied to the peer wallet.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton internal transfer accepted from the minter or an authenticated peer wallet and emitted to peer wallets.
struct (0x178d4519) TsTonWalletInternalTransfer {
    /// Query id copied from the originating transfer or mint request.
    queryId: uint64
    /// tsTON amount credited to the recipient wallet.
    amount: coins
    /// Source owner address reported by the minter or peer wallet.
    fromAddress: address
    /// Optional excess-refund address used after recipient processing.
    responseAddress: address?
    /// Nanotons forwarded to the recipient owner notification.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail copied to the owner notification.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated standard Jetton burn request accepted by the wallet.
struct (0x595f07bc) TsTonWalletBurn {
    /// Caller-selected query id copied into the outgoing burn notification.
    queryId: uint64
    /// tsTON amount burned from this wallet.
    amount: coins
    /// Optional response destination forwarded to the tsTON minter.
    responseDestination: address?
    /// Optional standard Jetton custom payload forwarded to the burn notification.
    customPayload: cell?
}

/// Owner-only request that reserves storage gas and emits a standard excess response to the owner.
struct (0x6d8e5e3c) TsTonWalletWithdrawTons {
    /// Query id copied into the outgoing `excesses` body.
    queryId: uint64
}

/// Owner-only request that tells an accidental child Jetton wallet to transfer tokens back to the tsTON owner.
struct (0x768a50b2) TsTonWalletWithdrawJettons {
    /// Query id copied into the child-wallet standard transfer request.
    queryId: uint64
    /// Child Jetton wallet address receiving the outgoing transfer request.
    childWallet: address
    /// Child Jetton amount requested for withdrawal.
    amount: coins
    /// Optional child-wallet custom payload forwarded without tsTON wallet parsing.
    customPayload: cell?
}

/// Owner-originated DAO vote request that locks the current spendable balance as voting weight.
struct (0x69fb306c) TsTonWalletVote {
    /// Query id copied into the outgoing vote-keeper request.
    queryId: uint64
    /// Voting contract address used to derive the deterministic vote-keeper address.
    votingAddress: address
    /// Vote expiration timestamp stored as uint48.
    expirationDate: uint48
    /// Vote choice copied into the outgoing vote-keeper request.
    vote: bool
    /// Whether the vote keeper should request a user-facing confirmation message.
    needConfirmation: bool
}

/// Owner-originated request that asks the minter to create a DAO voting proposal through this wallet.
struct (0x318eff17) TsTonWalletCreateVotingThroughWallet {
    /// Query id copied into the outgoing minter `create_voting` request.
    queryId: uint64
    /// Voting type parsed from the incoming body.
    votingType: uint64
    /// Voting expiration timestamp stored as uint48.
    expirationDate: uint48
    /// Referenced proposal cell forwarded to the minter.
    proposal: cell
}

/// Minter-originated request that asks the wallet to notify the owner about a confirmed vote.
struct (0x039a374e) TsTonWalletConfirmVoting {
    /// Query id copied into the outgoing owner confirmation.
    queryId: uint64
}

/// Minter-originated callback that reports a created voting contract to the wallet owner.
struct (0xc39f0be6) TsTonWalletVotingCreated {
    /// Query id copied into the outgoing voting-confirmation message.
    queryId: uint64
    /// Newly created voting contract address forwarded to the owner.
    votingAddress: address
}

/// Standard Jetton burn notification emitted to the tsTON minter after a successful burn.
struct (0x7bdd97de) TsTonWalletBurnNotification {
    /// Query id copied from the original burn request.
    queryId: uint64
    /// Burned tsTON amount.
    amount: coins
    /// Stored wallet owner address whose tsTON was burned.
    senderAddress: address
    /// Optional response destination copied from the burn request.
    responseDestination: address?
    /// Optional custom payload copied from the burn request.
    customPayload: cell?
}

/// Standard Jetton transfer notification emitted to the owner when an internal transfer forwards TON.
struct (0x7362d09c) TsTonWalletTransferNotification {
    /// Query id copied from the accepted internal transfer.
    queryId: uint64
    /// tsTON amount credited by the accepted internal transfer.
    amount: coins
    /// Source owner address reported by the accepted internal transfer.
    senderAddress: address
    /// Raw TEP-74 `Either Cell ^Cell` forward-payload tail copied from the internal transfer.
    forwardPayload: RemainingBitsAndRefs
}

/// Standard Jetton excess-value response emitted after internal transfer or owner withdraw-ton processing.
struct (0xd53276db) TsTonWalletExcesses {
    /// Query id copied from the request that produced the excess response.
    queryId: uint64
}

/// Vote-keeper request emitted after the owner locks wallet balance for a DAO vote.
struct (0x2bd63704) TsTonWalletRequestVote {
    /// Query id copied from the owner vote request.
    queryId: uint64
    /// Stored wallet owner whose balance is used as voting weight.
    voter: address
    /// Vote expiration timestamp copied from the owner request.
    expirationDate: uint48
    /// Locked tsTON weight sent to the vote keeper.
    weight: coins
    /// Vote choice copied from the owner request.
    vote: bool
    /// Whether the vote keeper should request a user-facing confirmation message.
    needConfirmation: bool
}

/// Minter request emitted when the owner creates a voting proposal through this wallet.
struct (0x1c7f9a1a) TsTonWalletCreateVoting {
    /// Query id copied from the owner create-voting-through-wallet request.
    queryId: uint64
    /// Voting expiration timestamp forwarded to the minter.
    expirationDate: uint48
    /// Referenced proposal cell forwarded to the minter.
    proposal: cell
    /// Voting type stored after the proposal ref.
    votingType: uint64
}

/// Owner notification emitted after the minter asks the wallet to confirm a vote.
struct (0x5fe9b8ca) TsTonWalletVoteConfirmation {
    /// Query id copied from the minter confirmation request.
    queryId: uint64
}

/// Owner notification emitted after the minter reports that a voting contract was created.
struct (0x2ccba006) TsTonWalletVotingConfirmation {
    /// Query id copied from the minter voting-created callback.
    queryId: uint64
    /// Created voting contract address copied from the minter callback.
    votingAddress: address
}

/// Bounced body prefix accepted before restoring balance for internal-transfer and burn-notification bounces.
struct (0xffffffff) TsTonWalletBouncedKnownBody {
    /// Original bounced opcode accepted for balance restoration.
    originalOpcode: uint32
    /// Query id from the bounced body.
    queryId: uint64
    /// tsTON amount restored to the wallet balance.
    amount: coins
    /// Remaining bounced body bits/refs are ignored after the amount.
    tail: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the tsTON wallet.
type TsTonWalletIncomingMessage =
    | TsTonWalletTransfer
    | TsTonWalletInternalTransfer
    | TsTonWalletBurn
    | TsTonWalletWithdrawTons
    | TsTonWalletWithdrawJettons
    | TsTonWalletVote
    | TsTonWalletCreateVotingThroughWallet
    | TsTonWalletConfirmVoting
    | TsTonWalletVotingCreated

/// Internal message bodies emitted by the tsTON wallet.
type TsTonWalletOutgoingMessage =
    | TsTonWalletInternalTransfer
    | TsTonWalletBurnNotification
    | TsTonWalletTransferNotification
    | TsTonWalletExcesses
    | TsTonWalletTransfer
    | TsTonWalletRequestVote
    | TsTonWalletCreateVoting
    | TsTonWalletVoteConfirmation
    | TsTonWalletVotingConfirmation

/// Structured result returned by the standard `get_wallet_data` getter.
struct TsTonWalletDataReply {
    /// Spendable tsTON balance returned as a TVM stack integer after expired locks are released.
    balance: int
    /// Stored wallet owner address.
    ownerAddress: address
    /// Stored tsTON Jetton master/minter address.
    jettonMasterAddress: address
    /// Referenced wallet code cell.
    jettonWalletCode: cell
}

/// Structured result returned by `get_dao_wallet_data`.
struct TsTonDaoWalletDataReply {
    /// Spendable tsTON balance returned after expired locks are released.
    balance: int
    /// Stored wallet owner address.
    ownerAddress: address
    /// Stored tsTON Jetton master/minter address.
    jettonMasterAddress: address
    /// Referenced wallet code cell.
    jettonWalletCode: cell
    /// Current locked tsTON amount after expired locks are released.
    locked: int
    /// Current lock expiration timestamp after expired locks are released.
    lockExpiration: uint48
}

/// tsTON wallet exit-code catalog.
enum TsTonWalletErrors {
    /// Destination owner address is not in the base workchain.
    WrongWorkchain = 333
    /// Sender is not the stored wallet owner for owner-only operations.
    UnauthorizedOwner = 705
    /// Transfer or burn would make the spendable tsTON balance negative.
    InsufficientJettonBalance = 706
    /// Internal transfer sender is neither the minter nor the authenticated peer wallet.
    InvalidInternalTransferSender = 707
    /// Transfer body is missing the required forward-payload selector bit.
    MissingForwardPayload = 708
    /// Transfer attached value is below the required funding threshold.
    TransferFundingTooLow = 709
    /// Sender is not authorized for DAO voting callbacks or owner voting requests.
    UnauthorizedVoting = 710
    /// Burn request attached value is below the minimum.
    BurnFundingTooLow = 711
    /// Voting expiration is not in the future.
    VotingAlreadyFinished = 249
    /// Voting expiration exceeds the maximum voting duration.
    ExpirationDateTooHigh = 3856
    /// Bounced body original opcode is not accepted for balance restoration.
    UnsupportedBouncedOperation = 65520
    /// Incoming internal message opcode is not supported.
    UnsupportedOperation = 65535
}

/// Return wallet balance, owner, minter/master, and wallet code cell.
get fun get_wallet_data(): TsTonWalletDataReply {
    assert (true) throw TsTonWalletErrors.WrongWorkchain;
    assert (true) throw TsTonWalletErrors.UnauthorizedOwner;
    assert (true) throw TsTonWalletErrors.InsufficientJettonBalance;
    assert (true) throw TsTonWalletErrors.InvalidInternalTransferSender;
    assert (true) throw TsTonWalletErrors.MissingForwardPayload;
    assert (true) throw TsTonWalletErrors.TransferFundingTooLow;
    assert (true) throw TsTonWalletErrors.UnauthorizedVoting;
    assert (true) throw TsTonWalletErrors.BurnFundingTooLow;
    assert (true) throw TsTonWalletErrors.VotingAlreadyFinished;
    assert (true) throw TsTonWalletErrors.ExpirationDateTooHigh;
    assert (true) throw TsTonWalletErrors.UnsupportedBouncedOperation;
    assert (true) throw TsTonWalletErrors.UnsupportedOperation;
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
    };
}

/// Return wallet balance, owner, minter/master, wallet code, locked balance, and lock expiration.
get fun get_dao_wallet_data(): TsTonDaoWalletDataReply {
    return {
        balance: 0,
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonMasterAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        jettonWalletCode: createEmptyCell(),
        locked: 0,
        lockExpiration: 0,
    };
}

/// Return the deterministic vote-keeper address for this wallet and a voting contract.
get fun get_vote_keeper_address(votingAddress: address): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
