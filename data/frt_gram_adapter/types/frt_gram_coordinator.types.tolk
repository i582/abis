/// Coordinates indexed requests and completion callbacks within the route chain.
contract FrtGramAdapterCoordinator {
    author: "ForTON"
    description: "Coordinates indexed requests and forwards route execution to the next contract in the chain."
    storage: FrtGramAdapterCoordinatorStorage
    incomingMessages: FrtGramAdapterCoordinatorIncomingMessage
    outgoingMessages: FrtGramAdapterCoordinatorOutgoingMessage
}

/// Persistent coordinator state with two fixed addresses, an optional override, flags, and registries.
struct FrtGramAdapterCoordinatorStorage {
    /// First fixed address used by the coordinator.
    primaryAddress: address
    /// Second fixed address used as the fallback when no override is set.
    secondaryAddress: address
    /// Stored amount in nanograms.
    balance: coins
    /// Primary one-bit state flag.
    enabled: bool
    /// Optional address that overrides the secondary address for one derived getter.
    callbackAddress: address?
    /// Secondary one-bit state flag.
    secondaryEnabled: bool
    /// First optional registry cell.
    registry0: cell?
    /// Second optional registry cell; it contains 16-bit groups of 32-bit keys.
    registry1: cell?
    /// Third optional registry cell containing nested addresses.
    registry2: cell?
}

/// Request selecting an indexed operation.
struct (0x9a1f0c09) FrtGramCoordinatorRouteRequest {
    /// 16-bit operation-group selector.
    routeIndex: uint16
    /// 32-bit request identifier.
    sequence: uint32
    /// 8-bit operation selector.
    action: uint8
}

/// Forwarded request with value, two addresses, and an extensible inline tail.
struct (0x9a1f0c0a) FrtGramCoordinatorDispatch {
    /// 16-bit operation-group selector.
    routeIndex: uint16
    /// 32-bit request identifier.
    sequence: uint32
    /// 8-bit operation selector.
    action: uint8
    /// Destination encoded in the forwarded request.
    destination: address
    /// Forwarded amount in nanograms.
    amount: coins
    /// Second address encoded in the forwarded request.
    responseAddress: address
    /// One-bit request flag.
    callbackEnabled: bool
    /// Remaining inline bits and references after the fixed header.
    payload: RemainingBitsAndRefs
}

/// Completion callback carrying a status bit and amount.
struct (0x9a1f0c0d) FrtGramCoordinatorCallback {
    /// Completion status.
    success: bool
    /// Reported amount in nanograms.
    amount: coins
}

/// Curated internal messages accepted by the coordinator.
type FrtGramAdapterCoordinatorIncomingMessage =
    | FrtGramCoordinatorRouteRequest
    | FrtGramCoordinatorCallback

/// Curated internal messages emitted by the coordinator.
type FrtGramAdapterCoordinatorOutgoingMessage = FrtGramCoordinatorDispatch

/// Return both fixed addresses and the stored amount.
get fun info(): (address, address, coins) {
    throw 0;
}

/// Return the optional destination override, including `addr_none` when absent.
get fun _destination(): address? {
    throw 0;
}

/// Return the ordered 32-bit keys stored under a 16-bit group selector.
get fun get_method_75874_eadb(routeIndex: int): tuple {
    throw 0;
}

/// Return four optional addresses from the nested registry record.
get fun get_method_90216_eiiu(): (any_address, any_address, any_address, any_address) {
    throw 0;
}

/// Return the primary state flag.
get fun get_method_90728_elpq(): bool {
    throw 0;
}

/// Return the optional override address, or the second fixed address when absent.
get fun get_method_96945_dewd(): address {
    throw 0;
}

/// Return the secondary state flag.
get fun get_method_101207_aqdu(): bool {
    throw 0;
}

/// Test whether a 16-bit group selector exists in the grouped-key registry.
get fun get_method_103900_bgor(routeIndex: int): bool {
    throw 0;
}

/// Return the number of 32-bit keys stored under a 16-bit group selector.
get fun get_method_104385_cqlp(routeIndex: int): int {
    throw 0;
}

/// Return the contract balance above the fixed 0.03 GRAM reserve.
get fun get_method_111560_eomx(): coins {
    throw 0;
}

/// Return two integer values derived from the stored registry state.
get fun get_method_125168_bjwk(): (int, int) {
    throw 0;
}
