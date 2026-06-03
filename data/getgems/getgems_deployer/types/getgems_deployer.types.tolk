/// Getgems NFT sale deployer interface for the current deployed BoC.
contract GetgemsDeployer {
    author: "Getgems"
    version: "1.0"
    description: "Curated Getgems sale deployer interface for NFT ownership callbacks and sale deployment"
    storage: GetgemsDeployerStorage
    incomingMessages: GetgemsDeployerIncomingMessage
    outgoingMessages: GetgemsDeployerOutgoingMessage
}

/// Persistent deployer data used to authorize raw proxy sends.
struct GetgemsDeployerStorage {
    /// Owner address allowed to send the emergency raw-message proxy command.
    ownerAddress: address
}

/// NFT ownership callback carrying a Getgems sale deployment payload.
struct (0x05138d91) GetgemsDeployerOwnershipAssignedDoSale {
    /// Query id copied into the outgoing NFT transfer message.
    queryId: uint64
    /// Previous NFT owner used as the response destination in the outgoing transfer.
    previousOwnerAddress: address
    /// Nested Getgems do-sale payload; compiled code requires this exact sub-op prefix.
    doSale: GetgemsDeployerDoSalePayload
}

/// Getgems deployer payload embedded after the NFT ownership callback fields.
struct (0x00fe0ede) GetgemsDeployerDoSalePayload {
    /// Referenced sale StateInit cell; its hash becomes the deployed sale address.
    saleStateInit: cell
    /// Referenced deploy body forwarded unchanged to the new sale account.
    saleDeployBody: cell
}

/// Funding-only deployment command accepted as a no-op.
struct (0x00000001) GetgemsDeployerAcceptDeploy {
}

/// Owner-only raw-message proxy command.
struct (0x0000022b) GetgemsDeployerProxyMessage {
    /// Referenced raw send action: send mode followed by raw message cell.
    action: Cell<GetgemsDeployerProxyAction>
}

/// Raw send action supplied by the deployer owner.
struct GetgemsDeployerProxyAction {
    /// Mode passed directly to `send_raw_message`.
    mode: uint8
    /// Raw outbound message cell sent unchanged by the proxy branch.
    message: cell
}

/// NFT transfer body emitted back to the NFT item after deploying the sale.
struct (0x5fcc3d14) GetgemsDeployerNftTransfer {
    /// Query id copied from the ownership callback.
    queryId: uint64
    /// Newly deployed sale contract address computed from `saleStateInit`.
    newOwnerAddress: address
    /// Previous NFT owner used as the response destination.
    responseAddress: address
    /// Always absent in the compiled deployer BoC.
    customPayload: cell?
    /// Always zero; no nanotons are forwarded in the NFT ownership notification.
    forwardTonAmount: coins
    /// Raw TEP-62 `Either Cell ^Cell` forward payload tail; compiled code emits the empty left-cell tag.
    forwardPayload: RemainingBitsAndRefs
}

/// Internal message bodies accepted by the current Getgems deployer BoC.
type GetgemsDeployerIncomingMessage =
    | GetgemsDeployerOwnershipAssignedDoSale
    | GetgemsDeployerAcceptDeploy
    | GetgemsDeployerProxyMessage

/// Structured outgoing message body emitted by the current Getgems deployer BoC.
type GetgemsDeployerOutgoingMessage =
    | GetgemsDeployerNftTransfer

/// Source-level exit-code catalog; not exported as thrown_errors because this contract has no public getter.
enum GetgemsDeployerErrors {
    /// Proxy command sender is not the owner stored in contract data.
    UnauthorizedProxySender = 403
    /// Ownership callback did not contain the required `do_sale` sub-op.
    InvalidDoSaleSubOperation = 404
    /// Non-empty body used an unsupported top-level opcode.
    UnknownOperation = 65535
}
