/// STON.fi pTON v2.1 wallet from ston-fi/pton-contracts.
contract PtonWalletV2 {
    author: "STON.fi"
    version: "2.1"
    description: "Curated pTON v2.1 wallet ABI for tokenizing TON, detokenizing through Jetton transfer, chaining pTON transfers, and standard Jetton wallet getters"
    storage: PtonWalletV2Storage
    incomingMessages: PtonWalletV2IncomingMessage
    outgoingMessages: PtonWalletV2OutgoingMessage
    thrownErrors: PtonWalletV2Errors
}

/// Persistent pTON wallet state stored in the root data cell.
struct PtonWalletV2Storage {
    /// Amount of tokenized TON tracked by this wallet.
    balance: coins
    /// Owner authorized to detokenize pTON through Jetton `transfer` and `reset_gas`.
    ownerAddress: address
    /// pTON minter/master address authorized to deploy this wallet.
    minterAddress: address
}

/// User or pTON-wallet request to tokenize TON and notify this wallet owner.
struct (0x01f3835d) PtonWalletV2TonTransfer {
    /// Query id copied into downstream notification or refund flows.
    queryId: uint64
    /// Amount of TON to tokenize.
    tonAmount: coins
    /// Standard address receiving `ton_refund` if tokenization fails.
    refundAddress: address
    /// Raw TEP-161 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// Minter-originated deployment message that lets the new wallet return excess TON.
struct (0x6540cf85) PtonWalletV2InternalDeploy {
    /// Query id copied from the upstream deploy request.
    queryId: uint64
    /// Address receiving deployment excesses.
    excessesAddress: address
}

/// Owner-originated TEP-74 transfer request used by pTON to detokenize or chain pTON.
struct (0x0f8a7ea5) PtonWalletV2Transfer {
    /// Caller-selected query id copied into the outgoing `ton_transfer`.
    queryId: uint64
    /// Amount of tokenized TON to debit.
    amount: coins
    /// Destination address that receives TON or another pTON `ton_transfer`.
    destination: address
    /// Optional response address; if present and different from destination, excesses are sent there.
    responseDestination: address?
    /// Optional referenced custom payload; source skips it.
    customPayload: cell?
    /// Additional TON sent with the non-bounce destination transfer.
    forwardTonAmount: coins
    /// Raw TEP-74 `Either Cell ^Cell` forward payload tail forwarded into the pTON `ton_transfer`.
    forwardPayload: RemainingBitsAndRefs
}

/// Owner-originated request to leave exactly tokenized TON balance plus storage reserve on the wallet.
struct (0x29d22935) PtonWalletV2ResetGas {
    /// Query id carried for traceability.
    queryId: uint64
}

/// Refund emitted when `ton_transfer` validation fails.
struct (0xae25d79e) PtonWalletV2TonRefund {
    /// Query id copied from the failed `ton_transfer`.
    queryId: uint64
}

/// TEP-74 transfer notification sent to the pTON wallet owner after successful tokenization.
struct (0x7362d09c) PtonWalletV2TransferNotification {
    /// Query id copied from `ton_transfer`.
    queryId: uint64
    /// Tokenized TON amount.
    amount: coins
    /// Sender of the `ton_transfer` request.
    sender: address
    /// Raw TEP-161 `Either Cell ^Cell` forward payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// TEP-74 excesses response used after deploy, transfer, or reset-gas flows.
struct (0xd53276db) PtonWalletV2Excesses {
    /// Query id copied from the request that produced the excess.
    queryId: uint64
}

/// Internal message bodies accepted by the pTON wallet.
type PtonWalletV2IncomingMessage =
    | PtonWalletV2TonTransfer
    | PtonWalletV2InternalDeploy
    | PtonWalletV2Transfer
    | PtonWalletV2ResetGas

/// Internal message bodies emitted by the pTON wallet.
type PtonWalletV2OutgoingMessage =
    | PtonWalletV2TransferNotification
    | PtonWalletV2TonRefund
    | PtonWalletV2TonTransfer
    | PtonWalletV2Excesses

/// Structured result returned by `get_wallet_data`.
struct PtonWalletV2WalletDataReply {
    /// Tokenized TON balance returned as a TVM stack integer.
    balance: int
    /// pTON wallet owner.
    ownerAddress: address
    /// pTON minter/master address.
    jettonMasterAddress: address
    /// Current pTON wallet code cell.
    jettonWalletCode: cell
}

/// pTON wallet exit-code catalog from ston-fi/pton-contracts.
enum PtonWalletV2Errors {
    /// Incoming value is not enough for the requested transfer and gas reserve.
    InsufficientGas = 83
    /// Refund address in `ton_transfer` is not a standard address.
    InvalidAddress = 84
    /// Sender is outside workchain 0.
    WrongWorkchain = 85
    /// `ton_transfer` amount is zero.
    LowAmount = 87
    /// Owner transfer would make tokenized TON balance negative.
    LowBalance = 88
    /// Parsed body has an invalid or missing forward payload tail.
    InvalidBody = 90
    /// Incoming opcode is unsupported for the sender role.
    WrongOperation = 65535
}

/// Return wallet balance, owner, minter, and wallet code.
get fun get_wallet_data(): PtonWalletV2WalletDataReply {
    throw 0;
}
