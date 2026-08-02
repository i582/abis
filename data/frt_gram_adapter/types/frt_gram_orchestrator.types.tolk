/// Creates worker steps and returns their results to the dispatcher.
contract FrtGramAdapterOrchestrator {
    author: "ForTON"
    description: "Coordinates the worker stage of a routed Jetton exchange."
    storage: FrtGramAdapterOrchestratorStorage
    incomingMessages: FrtGramAdapterOrchestratorIncomingMessage
    outgoingMessages: FrtGramAdapterOrchestratorOutgoingMessage
}

/// Persistent orchestration state.
struct FrtGramAdapterOrchestratorStorage {
    /// Address authorized to control the orchestrator.
    ownerAddress: address
    /// Primary stored TON amount.
    primaryAmount: coins
    /// First 16-bit state value.
    parameter0: uint16
    /// First 32-bit state value.
    stateValue0: uint32
    /// Second 16-bit state value.
    parameter1: uint16
    /// Optional stored address.
    optionalAddress: address?
    /// Secondary stored TON amount.
    secondaryAmount: coins
    /// Second 32-bit state value.
    stateValue1: uint32
    /// Third 32-bit state value.
    stateValue2: uint32
    /// Stored one-bit flag.
    enabled: bool
    /// Optional nested state record.
    nestedState: cell?
}

/// Work request sent from the dispatcher to the orchestrator.
struct (0x9a1f0f0c) FrtGramOrchestratorWorkRequest {
    /// 32-bit request identifier.
    sequence: uint32
    /// Worker step selector.
    step: uint8
    /// Worker destination address.
    destination: address
    /// One-bit request flag.
    enabled: bool
}

/// Worker dispatch emitted by the orchestrator.
struct (0x9a1f0f0e) FrtGramOrchestratorWorkerDispatch {
    /// 32-bit request identifier passed to the worker.
    sequence: uint32
    /// TON amount passed to the worker.
    amount: coins
    /// Worker destination address.
    destination: address
    /// One-bit request flag.
    enabled: bool
}

/// Worker result sent back to the orchestrator.
struct (0x9a1f0f0f) FrtGramOrchestratorWorkerResult {
    /// 16-bit result value.
    routeIndex: uint16
    /// 32-bit request identifier.
    sequence: uint32
    /// TON amount reported by the worker.
    amount: coins
    /// First result address.
    workerAddress: address
    /// Second result address.
    destination: address
    /// One-bit result flag.
    enabled: bool
}

/// Continuation sent from the orchestrator to the dispatcher.
struct (0x9a1f0f1b) FrtGramOrchestratorContinuation {
    /// TON amount assigned to the next continuation.
    amount: coins
    /// 16-bit continuation value.
    routeIndex: uint16
    /// Additional reserve forwarded with the continuation.
    reserve: coins
    /// Dispatcher destination.
    destination: address
    /// Message-specific data after the fixed header.
    payload: RemainingBitsAndRefs
}

/// Curated internal messages accepted by the orchestrator.
type FrtGramAdapterOrchestratorIncomingMessage =
    | FrtGramOrchestratorWorkRequest
    | FrtGramOrchestratorWorkerResult

/// Curated internal messages emitted by the orchestrator.
type FrtGramAdapterOrchestratorOutgoingMessage =
    | FrtGramOrchestratorWorkerDispatch
    | FrtGramOrchestratorContinuation

/// Return the control address, primary TON amount, and first 16-bit value.
get fun info(): (address, coins, uint16) {
    throw 0;
}

/// Return a TON amount from the optional nested state.
get fun get_method_71958_cjwb(): coins {
    throw 0;
}

/// Calculate two integer results for the supplied values.
get fun get_method_72575_facz(first: int, second: int): (int, int) {
    throw 0;
}

/// Return the second stored 16-bit value.
get fun get_method_74730_abqk(): int {
    throw 0;
}

/// Return the third stored 32-bit value.
get fun get_method_81021_tcle(): int {
    throw 0;
}

/// Return the optional stored address.
get fun get_method_81580_ceas(): any_address {
    throw 0;
}

/// Return an optional address from the nested state.
get fun get_method_85238_akxq(): any_address {
    throw 0;
}

/// Return the first stored 32-bit value.
get fun get_method_89176_crro(): uint32 {
    throw 0;
}

/// Return another optional address from the nested state.
get fun get_method_92278_fehg(): any_address {
    throw 0;
}

/// Compare two input values against the contract's stored limits.
get fun get_method_92936_fmrj(first: int, second: int): bool {
    throw 0;
}

/// Return the secondary stored TON amount.
get fun get_method_95225_eczj(): coins {
    throw 0;
}

/// Return the balance remaining after the contract's fixed reserves.
get fun get_method_97527_gclf(): int {
    throw 0;
}

/// Return the stored start time.
get fun startTime(): uint32 {
    throw 0;
}

/// Scale the second input by a power-of-two value derived from the first.
get fun get_method_110374_bouh(first: int, second: int): int {
    throw 0;
}

/// Return the stored one-bit flag.
get fun get_method_112100_ayxm(): bool {
    throw 0;
}

/// Return the constant value 50.
get fun get_method_115600_fohv(): int {
    throw 0;
}

/// Calculate a contract-defined integer result for one input.
get fun get_method_118967_amxz(value: int): int {
    throw 0;
}

/// Return the first input together with a contract-derived count.
get fun get_method_123727_cqih(first: int, second: int): (int, int) {
    throw 0;
}
