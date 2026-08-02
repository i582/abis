/// Executes a routed Jetton exchange through a STON.fi pool.
contract FrtGramAdapterExecutor {
    author: "ForTON"
    description: "Queries a STON.fi pool, sends a Jetton transfer, and returns the execution result."
    storage: FrtGramAdapterExecutorStorage
    incomingMessages: FrtGramAdapterExecutorIncomingMessage
    outgoingMessages: FrtGramAdapterExecutorOutgoingMessage
}

/// Persistent executor state.
struct FrtGramAdapterExecutorStorage {
    /// Address returned by the standard owner getter.
    ownerAddress: address
    /// Second stored address.
    secondaryAddress: address
    /// Optional stored callback address.
    callbackAddress: address?
    /// Stored 16-bit parameter.
    parameter: uint16
    /// Stored one-bit flag.
    enabled: bool
    /// Stored 32-bit value.
    stateValue: uint32
    /// First optional nested registry.
    registry0: cell?
    /// Second optional nested registry.
    registry1: cell?
    /// Third optional nested registry.
    registry2: cell?
}

/// Execution request delivered through a referenced payload cell.
struct (0x9a1f1009) FrtGramExecutorExecute {
    /// Referenced execution payload.
    payload: cell
}

/// Pool-data response accepted by the executor after the STON.fi request.
struct (0x26df39fc) FrtGramExecutorPoolDataResponse {
    /// Pool query identifier.
    queryId: uint64
    /// Pool response fields after the query identifier.
    payload: RemainingBitsAndRefs
}

/// Standard Jetton transfer emitted by the executor.
struct (0x0f8a7ea5) FrtGramExecutorJettonTransfer {
    /// Query identifier.
    queryId: uint64
    /// Jetton amount in base units.
    amount: coins
    /// Destination owner address.
    destination: address
    /// Address receiving excess TON.
    responseDestination: address
    /// Optional custom payload reference.
    customPayload: cell?
    /// TON amount forwarded with the transfer notification.
    forwardTonAmount: coins
    /// Forwarded payload tail.
    forwardPayload: RemainingBitsAndRefs
}

/// STON.fi pool-data request emitted by the executor.
struct (0x26df39fc) FrtGramExecutorPoolDataRequest {
    /// Pool query identifier.
    queryId: uint64
}

/// Execution result sent back to the dispatcher.
struct (0x9a1f0d08) FrtGramExecutorDispatcherResult {
    /// TON amount reported by execution.
    amount: coins
    /// Destination that receives the result callback.
    responseDestination: address
    /// One-bit execution status.
    success: bool
    /// Second TON amount reported by execution.
    secondaryAmount: coins
}

/// External event emitted after an execution request is accepted.
struct (0x4185ff6a) FrtGramExecutorExecutionEvent {
    /// Event data after the opcode.
    payload: RemainingBitsAndRefs
}

/// Curated internal messages accepted by the executor.
type FrtGramAdapterExecutorIncomingMessage =
    | FrtGramExecutorExecute
    | FrtGramExecutorPoolDataResponse

/// Curated messages emitted by the executor.
type FrtGramAdapterExecutorOutgoingMessage =
    | FrtGramExecutorPoolDataRequest
    | FrtGramExecutorJettonTransfer
    | FrtGramExecutorDispatcherResult
    | FrtGramExecutorExecutionEvent

/// Return the effective manager address.
get fun manager(): address {
    throw 0;
}

/// Return the first and second stored addresses.
get fun info(): (address, address) {
    throw 0;
}

/// Return the stored one-bit flag.
get fun get_method_74950_aovt(): bool {
    throw 0;
}

/// Return three optional addresses from a nested record.
get fun get_method_75972_gnsk(): (any_address, any_address, any_address) {
    throw 0;
}

/// Return an optional address derived from nested state.
get fun get_method_82705_bnfr(): any_address {
    throw 0;
}

/// Return the first stored address.
get fun owner(): address {
    throw 0;
}

/// Return the stored 32-bit value.
get fun get_method_85369_alcs(): uint32 {
    throw 0;
}

/// Return the optional Jetton wallet address from nested state.
get fun jettonWallet(): any_address {
    throw 0;
}

/// Return whether the nested record is present.
get fun get_method_90728_elpq(): bool {
    throw 0;
}

/// Return a 32-bit value from the nested record.
get fun get_method_92996_daee(): uint32 {
    throw 0;
}

/// Return the optional callback address.
get fun get_method_97003_acyx(): any_address {
    throw 0;
}

/// Return an address derived from nested state.
get fun get_method_102735_bgiv(): any_address {
    throw 0;
}

/// Return the second stored address.
get fun get_method_113118_nlra(): address {
    throw 0;
}

/// Return another address derived from nested state.
get fun get_method_119758_adzb(): any_address {
    throw 0;
}

/// Return whether a nested entry exists.
get fun get_method_124835_betu(): bool {
    throw 0;
}

/// Return the stored 16-bit parameter.
get fun get_method_126826_bcbn(): uint16 {
    throw 0;
}

/// Return a TON amount from the nested record.
get fun get_method_130008_aqds(): coins {
    throw 0;
}
