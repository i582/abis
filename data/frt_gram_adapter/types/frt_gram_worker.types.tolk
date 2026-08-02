/// Processes one step of a routed exchange and returns its result.
contract FrtGramAdapterWorker {
    author: "ForTON"
    description: "Processes a bounded worker step and stores indexed addresses, flags, and TON amounts."
    storage: FrtGramAdapterWorkerStorage
    incomingMessages: FrtGramAdapterWorkerIncomingMessage
    outgoingMessages: FrtGramAdapterWorkerOutgoingMessage
}

/// Persistent worker state and its indexed lookup tables.
struct FrtGramAdapterWorkerStorage {
    /// First 16-bit selector.
    selector0: uint16
    /// Second 16-bit selector.
    selector1: uint16
    /// First stored address.
    primaryAddress: address
    /// Second stored address.
    secondaryAddress: address
    /// First stored 32-bit value.
    stateValue: uint32
    /// Upper bound used for indexed lookups.
    limit: uint32
    /// Optional pair of stored addresses.
    addressPair: Cell<FrtGramAdapterWorkerAddressPair>?
    /// Optional bundle of indexed lookup tables.
    lookupTables: Cell<FrtGramAdapterWorkerLookupTables>?
}

/// Optional pair of addresses stored by the worker.
struct FrtGramAdapterWorkerAddressPair {
    /// First optional address.
    first: address?
    /// Second optional address.
    second: address?
}

/// Lookup tables stored in the worker's referenced state record.
struct FrtGramAdapterWorkerLookupTables {
    /// Addresses keyed by a 32-bit index.
    addresses: map<uint32, address>
    /// Eight-bit values keyed by a 32-bit index.
    flags: map<uint32, uint8>
    /// TON amounts keyed by a 32-bit index.
    amounts: map<uint32, coins>
}

/// Worker step request received from the orchestrator.
struct (0x9a1f0f0e) FrtGramWorkerStepRequest {
    /// 32-bit request identifier.
    sequence: uint32
    /// TON amount passed to the worker.
    amount: coins
    /// Worker destination address.
    destination: address
    /// One-bit request flag.
    enabled: bool
}

/// Worker result emitted toward the orchestrator.
struct (0x9a1f0f0f) FrtGramWorkerStepResult {
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

/// Curated internal messages accepted by the worker.
type FrtGramAdapterWorkerIncomingMessage = FrtGramWorkerStepRequest

/// Curated internal messages emitted by the worker.
type FrtGramAdapterWorkerOutgoingMessage = FrtGramWorkerStepResult

/// Return the first stored 32-bit value.
get fun get_method_67522_ffrz(): uint32 {
    throw 0;
}

/// Return both selectors and both stored addresses.
get fun info(): (uint16, uint16, address, address) {
    throw 0;
}

/// Return the address stored for an index.
get fun get_method_78997_blse(index: int): any_address {
    throw 0;
}

/// Return the worker limit field.
get fun get_method_83655_chdd(): uint32 {
    throw 0;
}

/// Return the eight-bit value stored for an index.
get fun get_method_101138_cdtm(index: int): uint8 {
    throw 0;
}

/// Return the first optional address from the address pair.
get fun get_method_109070_adqd(): any_address {
    throw 0;
}

/// Return the TON amount stored for an index.
get fun get_method_111858_bnct(index: int): coins {
    throw 0;
}

/// Return the second optional address from the address pair.
get fun get_method_130594_ehro(): any_address {
    throw 0;
}
