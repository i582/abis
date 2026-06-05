/// Curated ABI for the Coffee Swap Init contract used as deterministic blank code.
contract CoffeeInit {
    author: "Coffee Swap"
    version: "1.0"
    description: "Coffee Swap deterministic Init shell. It accepts Factory install messages, replaces its own code/data, and optionally dispatches an action body under the newly installed code."
    storage: CoffeeInitStorage
    incomingMessages: CoffeeInitIncomingMessage
    outgoingMessages: CoffeeInitOutgoingMessage
}

/// Init storage prefix before the target contract is installed.
struct CoffeeInitStorage {
    /// Factory address allowed to install code/data.
    factoryAddress: address
    /// Remaining child identity fields for the target contract.
    childIdentityTail: RemainingBitsAndRefs
}

/// Factory install message.
struct (0xc0ffee22) CoffeeInitDeploy {
    /// Query id loaded and ignored by Init before installing code/data.
    queryId: uint64
    /// Replacement contract code.
    code: cell
    /// Replacement contract storage.
    data: cell
    /// Optional action body recursively dispatched after code/data installation.
    action: cell?
}

/// Internal message bodies accepted by Coffee Init.
type CoffeeInitIncomingMessage = CoffeeInitDeploy

/// Init does not construct outgoing message bodies itself.
type CoffeeInitOutgoingMessage = void

/// Init error codes.
enum CoffeeInitErrors {
    /// Incoming opcode is not supported.
    UnknownOpcode = 6
    /// Install message was not sent by the stored Factory address.
    NotAFactory = 253
}
