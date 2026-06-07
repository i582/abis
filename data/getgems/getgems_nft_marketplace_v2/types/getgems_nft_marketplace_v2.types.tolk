/// Getgems NFT marketplace V2 interface: Wallet V3 R2 signing plus signed internal sale deployment.
contract GetgemsNftMarketplaceV2 {
    author: "Getgems"
    version: "2.0"
    description: "Curated Getgems NFT marketplace V2 interface for wallet-style sends and signed sale deployment"
    storage: GetgemsNftMarketplaceV2Storage
    incomingMessages: GetgemsNftMarketplaceV2IncomingMessage
    incomingExternal: GetgemsNftMarketplaceV2IncomingExternalMessage
    forceAbiExport: GetgemsNftMarketplaceV2ExternalSendAction | GetgemsNftMarketplaceV2DeployOutgoingEnvelope
    thrownErrors: GetgemsNftMarketplaceV2Errors
}

/// Persistent Wallet V3 R2-compatible marketplace state.
struct GetgemsNftMarketplaceV2Storage {
    /// Replay-protection sequence number incremented after each accepted external request.
    seqno: uint32
    /// Wallet id, called `subwallet` in the upstream FunC source.
    subwalletId: uint32
    /// Stored Ed25519 public key used to verify external requests and signed sale deployments.
    publicKey: uint256
}

/// Internal command that deploys a sale contract after verifying the embedded signature.
struct (0x00000001) GetgemsNftMarketplaceV2DeploySignedSale {
    /// Ed25519 signature over the remaining slice containing the two refs below.
    signature: bits512
    /// Sale StateInit cell; its hash determines the destination address in workchain 0.
    stateInit: Cell<StateInit>
    /// Raw deploy body forwarded unchanged to the newly derived sale address.
    body: cell
}

/// External-in request authenticated by Ed25519 signature over the body after the signature.
struct GetgemsNftMarketplaceV2SignedExternal {
    /// Ed25519 signature over subwalletId, validUntil, seqno, and the trailing message stream.
    signature: bits512
    /// Wallet id expected to match storage.subwalletId.
    subwalletId: uint32
    /// Unix timestamp after which the request is expired.
    validUntil: uint32
    /// Request sequence number expected to match storage.seqno.
    seqno: uint32
    /// Raw trailing stream of repeated `mode:uint8` plus `^MessageRelaxed` pairs.
    messages: RemainingBitsAndRefs
}

/// One raw action in the signed external trailing stream.
struct GetgemsNftMarketplaceV2ExternalSendAction {
    /// Raw mode passed directly to `send_raw_message`.
    mode: uint8
    /// Raw referenced outbound message cell sent unchanged.
    message: cell
}

/// Proven outbound envelope shape created by the internal sale-deployment command.
struct GetgemsNftMarketplaceV2DeployOutgoingEnvelope {
    /// Sale StateInit ref copied from the signed internal command.
    stateInit: Cell<StateInit>
    /// Raw deploy body ref copied from the signed internal command.
    body: cell
}

/// Internal message bodies accepted by Getgems NFT marketplace V2.
type GetgemsNftMarketplaceV2IncomingMessage = GetgemsNftMarketplaceV2DeploySignedSale

/// External-in message body accepted by Getgems NFT marketplace V2.
type GetgemsNftMarketplaceV2IncomingExternalMessage = GetgemsNftMarketplaceV2SignedExternal

/// Source-level exit-code catalog from explicit `throw_*` branches.
enum GetgemsNftMarketplaceV2Errors {
    /// Request seqno does not match storage.seqno.
    InvalidSeqno = 33
    /// Request wallet id does not match storage.subwalletId.
    InvalidSubwalletId = 34
    /// Request expired or Ed25519 signature verification failed.
    ExpiredOrInvalidSignature = 35
}

/// Return the stored Ed25519 public key as a TVM integer.
get fun get_public_key(): int {
    throw 0;
}

/// Return the current replay-protection sequence number.
get fun seqno(): uint32 {
    throw 0;
}
