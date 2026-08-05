/// Dispatches route requests and returns execution results to the coordinator.
contract FrtGramAdapterDispatcher {
    author: "ForTON"
    description: "Dispatches route requests between the coordinator, orchestrator, and executor."
    storage: FrtGramAdapterDispatcherStorage
    incomingMessages: FrtGramAdapterDispatcherIncomingMessage
    outgoingMessages: FrtGramAdapterDispatcherOutgoingMessage
}

/// Persistent dispatcher state and its three route registries.
struct FrtGramAdapterDispatcherStorage {
    /// Address authorized to control the dispatcher.
    ownerAddress: address
    /// Stored 32-bit state value.
    stateValue: uint32
    /// Optional address used by dispatcher callbacks.
    callbackAddress: address?
    /// Route records keyed by a 128-bit identifier.
    routeRecords: map<uint128, FrtGramDispatcherRouteRecord>
    /// 32-bit values keyed by a 128-bit identifier.
    routeValues: map<uint128, uint32>
    /// Addresses keyed by a 128-bit identifier.
    routeAddresses: map<uint128, address>
}

/// Fixed-width record stored in the primary route registry.
struct FrtGramDispatcherRouteRecord {
    /// Stored 16-bit route parameter.
    parameter: uint16
    /// Whether this route record is enabled.
    enabled: bool
    /// Address associated with the route record.
    destination: address
}

/// Route dispatch received from the coordinator.
struct (0x9a1f0c0a) FrtGramDispatcherRouteRequest {
    /// 16-bit route index.
    routeIndex: uint16
    /// 32-bit route sequence.
    sequence: uint32
    /// Action selector.
    action: uint8
    /// Next route destination.
    destination: address
    /// GRAM amount carried into the route.
    amount: coins
    /// Callback or excess destination.
    responseAddress: address
    /// One-bit callback mode.
    callbackEnabled: bool
    /// Message-specific data after the fixed header.
    payload: RemainingBitsAndRefs
}

/// Route continuation received from the orchestrator.
struct (0x9a1f0f1b) FrtGramDispatcherContinuation {
    /// GRAM amount assigned to the continuation.
    amount: coins
    /// Stored 16-bit route value.
    routeIndex: uint16
    /// Additional GRAM amount reserved for the continuation.
    reserve: coins
    /// Continuation destination address.
    destination: address
    /// Message-specific data after the fixed header.
    payload: RemainingBitsAndRefs
}

/// Execution result returned by the executor.
struct (0x9a1f0d08) FrtGramDispatcherExecutionResult {
    /// GRAM amount reported by the executor.
    amount: coins
    /// Destination that receives the subsequent callback.
    responseDestination: address
    /// Whether execution succeeded.
    success: bool
    /// Second GRAM amount reported by execution.
    secondaryAmount: coins
}

/// Completion callback sent back to the coordinator.
struct (0x9a1f0c0d) FrtGramDispatcherCoordinatorCallback {
    /// Whether the dispatched route completed successfully.
    success: bool
    /// GRAM amount returned by the route.
    amount: coins
}

/// Curated internal messages accepted by the dispatcher.
type FrtGramAdapterDispatcherIncomingMessage =
    | FrtGramDispatcherRouteRequest
    | FrtGramDispatcherContinuation
    | FrtGramDispatcherExecutionResult

/// Curated internal messages emitted by the dispatcher.
type FrtGramAdapterDispatcherOutgoingMessage = FrtGramDispatcherCoordinatorCallback

/// Return the stored 32-bit state value.
get fun get_method_67267_egto(): uint32 {
    throw 0;
}

/// Return the primary route registry.
get fun get_method_70452_bobg(): cell {
    throw 0;
}

/// Return the fixed 0.05 GRAM amount used by the dispatcher.
get fun storageReserve(): int {
    throw 0;
}

/// Return the dispatcher control address.
get fun owner(): address {
    throw 0;
}

/// Return the 16-bit value from a primary route record.
get fun get_method_84363_afgd(index: int): int {
    throw 0;
}

/// Return the 32-bit value associated with a route identifier.
get fun get_method_86502_cjhv(index: int): uint32 {
    throw 0;
}

/// Return the primary route registry.
get fun get_method_92684_bkln(): cell {
    throw 0;
}

/// Return the enabled flag from a primary route record.
get fun get_method_92754_obut(index: int): bool {
    throw 0;
}

/// Return the optional dispatcher callback address.
get fun get_method_97003_acyx(): any_address {
    throw 0;
}

/// Return whether the primary registry contains an identifier.
get fun get_method_99809_bzgn(index: int): bool {
    throw 0;
}

/// Return the address from a primary route record.
get fun get_method_102648_bghe(index: int): any_address {
    throw 0;
}

/// Return the address associated with an identifier in the address registry.
get fun get_method_117829_aeqs(index: int): any_address {
    throw 0;
}

/// Return the address registry.
get fun get_method_123424_eqxi(): cell {
    throw 0;
}
