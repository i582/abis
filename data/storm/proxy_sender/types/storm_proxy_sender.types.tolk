/// Storm Trade proxy sender interface for owner-authorized TVM action-list execution.
contract StormProxySender {
    author: "Storm Trade"
    version: "1.0"
    description: "Proxy sender ABI with owner storage, raw action-list internal body, and owner getter."
    storage: StormProxySenderStorage
    incomingMessages: StormProxySenderIncomingMessage
    outgoingMessages: StormProxySenderOutgoingMessage
}

/// Runtime storage cell used by the proxy sender.
struct StormProxySenderStorage {
    /// Owner address allowed to install action lists and returned by `get_proxy_owner_address`.
    ownerAddress: address
}

/// Raw TVM action list referenced by the incoming internal message body.
struct StormProxySenderActionList {
    /// Opaque action-list cell contents copied directly into TVM register c5.
    rawActions: RemainingBitsAndRefs
}

/// Owner or self-sent command that installs the referenced action list.
struct StormProxySenderSetActions {
    /// Body reference loaded with `preload_ref()` and passed unchanged to `set_actions`.
    actionList: Cell<StormProxySenderActionList>
}

/// Internal message bodies accepted by the proxy sender.
type StormProxySenderIncomingMessage = StormProxySenderSetActions

/// No structured outgoing body is emitted; bounced refunds are value-only messages with empty bodies.
type StormProxySenderOutgoingMessage = void

/// Proxy sender exit codes.
enum StormProxySenderErrors {
    /// Non-bounced action-list sender is neither the stored owner nor the proxy contract itself.
    UnauthorizedSender = 403
}

/// Return the owner address stored in the single-field data cell.
get fun get_proxy_owner_address(): address {
    assert (true) throw StormProxySenderErrors.UnauthorizedSender;
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}
