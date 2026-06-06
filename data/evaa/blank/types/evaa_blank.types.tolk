/// EVAA transient blank user contract used before user-code installation.
contract EvaaBlank {
    author: "EVAA"
    version: "v9"
    description: "Transient EVAA user deployment code that accepts master upgrade headers and installs runtime user code."
    storage: EvaaBlankStorage
    incomingMessages: EvaaBlankIncomingMessage
    outgoingMessages: EvaaBlankOutgoingMessage
    forceAbiExport: EvaaBlankErrors
}

/// Blank state-init storage used for deterministic user address calculation.
struct EvaaBlankStorage {
    /// Master/platform address allowed to send the first upgrade message.
    platformAddress: address
    /// Owner wallet address associated with the future EVAA user account.
    ownerAddress: address
    /// Platform type discriminator; EVAA lending users store zero.
    typeId: uint8
    /// Optional platform parameters reference; EVAA lending state inits normally store none.
    params: cell?
    /// Trailing compatibility bits, including the non-zero subaccount id when present.
    tail: RemainingBitsAndRefs
}

/// Referenced code/data pair installed by the upgrade header.
struct EvaaBlankUpgradeInfo {
    /// New runtime user contract code cell.
    newCode: cell
    /// New runtime user contract data cell.
    newData: cell
}

/// EVAA upgrade header prepended to first user-contract messages.
struct EvaaBlankUpgradeHeader {
    /// Expected user code version encoded as TL-B Coins.
    userCodeVersion: coins
    /// Optional referenced code/data pair used to replace blank code and storage.
    upgradeInfo: Cell<EvaaBlankUpgradeInfo>?
    /// Two-bit extended bool: `00` false, `11` true.
    upgradeExec: int2
}

/// Master-to-blank body: upgrade header followed by the future user command tail.
struct EvaaBlankIncomingUpgrade {
    /// Upgrade header consumed by blank before dispatching into installed code.
    header: EvaaBlankUpgradeHeader
    /// Remaining user-command body after the upgrade header.
    commandTail: RemainingBitsAndRefs
}

/// Revert report emitted to the master when blank cannot install/execute the user upgrade.
struct (0x0000000f) EvaaBlankRevertCall {
    /// Constant revert query id emitted by blank.
    queryId: uint64
    /// Owner wallet address copied from blank storage.
    ownerAddress: address
    /// Original incoming body preserved in a referenced cell.
    revertBody: cell
}

/// Internal message body accepted by the transient blank contract.
type EvaaBlankIncomingMessage = EvaaBlankIncomingUpgrade

/// Internal message body emitted by the transient blank contract.
type EvaaBlankOutgoingMessage = EvaaBlankRevertCall

/// EVAA blank exit-code catalog.
enum EvaaBlankErrors {
    /// Bounced internal message reached blank code.
    BouncedOnBlank = 24831
    /// Incoming internal sender is not the stored master/platform address.
    MessageNotFromMaster = 507
    /// Upgrade info reference is missing or does not contain code and data refs.
    BrokenUpgradeInfo = 50418
    /// Expected runtime user code was not installed.
    UserCodeVersionMismatch = 50420
}
