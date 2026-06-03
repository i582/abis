/// Getgems NFT marketplace V1 interface for owner-authorized sale/auction deployment.
contract GetgemsNftMarketplaceV1 {
    author: "Getgems"
    version: "1.0"
    description: "Curated Getgems NFT marketplace V1 interface"
    storage: GetgemsNftMarketplaceV1Storage
    incomingMessages: GetgemsNftMarketplaceV1IncomingMessage
    forceAbiExport: GetgemsNftMarketplaceV1DeployEnvelopeRefs
}

/// Persistent marketplace state in the root data cell.
struct GetgemsNftMarketplaceV1Storage {
    /// Owner address authorized to request deployment of a referenced StateInit/body pair.
    ownerAddress: address
}

/// Owner-only command that deploys a referenced contract in workchain 0.
struct (0x00000001) GetgemsNftMarketplaceV1DeployContract {
    /// Nanotons loaded from the body and sent to the derived contract address.
    amount: coins
}

/// Full-message refs loaded outside the body and copied into the outbound deployment.
struct GetgemsNftMarketplaceV1DeployEnvelopeRefs {
    /// StateInit ref whose hash determines the destination address.
    stateInit: Cell<StateInit>
    /// Raw deploy body ref forwarded unchanged to the newly derived address.
    body: cell
}

/// Internal message bodies accepted by Getgems NFT marketplace V1.
type GetgemsNftMarketplaceV1IncomingMessage = GetgemsNftMarketplaceV1DeployContract

/// Source-level exit-code catalog; not exported as thrown_errors because V1 has no public getter.
enum GetgemsNftMarketplaceV1Errors {
    /// Non-empty internal message sender is not the owner stored in contract data.
    UnauthorizedSender = 401
}
