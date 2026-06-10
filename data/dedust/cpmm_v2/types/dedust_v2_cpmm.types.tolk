/// DeDust V2 CPMM pool interface reconstructed from the verified library-backed pool code at `EQD026kOv4j6-56O6y8kbaaFZdQhVkh4RbEGrQND7XJMlgLf`.
contract DedustV2Cpmm {
    author: "DeDust"
    version: "2.0"
    description: "Curated ABI for the deployed DeDust v2 CPMM pool family with get_pool_data, get_position_address, proven storage shape, and live message bodies."
    storage: DedustV2CpmmStorage
    incomingMessages: DedustV2CpmmIncomingMessage
    outgoingMessages: DedustV2CpmmOutgoingMessage
    thrownErrors: DedustV2CpmmErrors
}

/// Inline two-bit mode tag stored after the root dictionary.
struct (0b00) DedustV2CpmmModeIdle {}

/// Two-bit mode tag variant with an embedded address.
struct (0b01) DedustV2CpmmModeWithAddress {
    /// Embedded internal address carried by the mode tag.
    address: address
}

/// Inline two-bit mode tag used by the live representative pool.
struct (0b10) DedustV2CpmmModeSettled {}

/// Root mode tag reconstructed from `set_data(...)` sites in the verified decompile.
type DedustV2CpmmMode =
    | DedustV2CpmmModeIdle
    | DedustV2CpmmModeWithAddress
    | DedustV2CpmmModeSettled

/// Root persistent CPMM storage loaded directly from the saved mainnet data cell.
struct DedustV2CpmmStorage {
    /// First referenced state cell with the owner address and wallet registry dictionaries returned through `get_pool_data`.
    walletRegistryState: cell
    /// Second referenced state cell with protocol-fee and LP-fee accumulators.
    feeState: cell
    /// Third referenced state cell with asset addresses, fee settings, and auxiliary collections.
    assetState: cell
    /// Root dictionary cell persisted alongside the three referenced state cells.
    rootDictionary: cell?
    /// Inline pool mode tag.
    mode: DedustV2CpmmMode
    /// Deposit gate flag returned by `get_pool_data`.
    depositActive: bool
    /// Swap gate flag returned by `get_pool_data`.
    swapActive: bool
    /// Current LP liquidity amount.
    liquidity: coins
    /// Current reserve of asset X.
    reserveX: coins
    /// Current reserve of asset Y.
    reserveY: coins
}

/// Structured stack reply returned by the deployed `get_pool_data` getter.
struct DedustV2CpmmPoolDataReply {
    /// Pool status enum returned as a signed 8-bit value.
    status: int8
    /// Deposit gate flag.
    depositActive: bool
    /// Swap gate flag.
    swapActive: bool
    /// Asset X address; the live TON/LFG example returns `addr_none` for native TON.
    assetX: address?
    /// Asset Y address.
    assetY: address
    /// Registry cell keyed by asset addresses.
    walletsByAssets: cell
    /// Registry cell keyed by wallet addresses.
    assetsByWallets: cell
    /// Raw resolution tuple returned by the live getter.
    walletsResolutions: tuple
    /// Pool base fee in basis points.
    baseFeeBps: int32
    /// Current reserve of asset X.
    reserveX: int
    /// Current reserve of asset Y.
    reserveY: int
    /// Current LP liquidity amount.
    liquidity: int
    /// Protocol fee balance for asset X.
    protocolFeeX: int
    /// Protocol fee balance for asset Y.
    protocolFeeY: int
    /// Creator fee balance for asset X.
    createdFeeX: int
    /// Creator fee balance for asset Y.
    createdFeeY: int
    /// Accumulated LP fee-per-token for asset X.
    xLpFeePerToken: int
    /// Accumulated LP fee-per-token for asset Y.
    yLpFeePerToken: int
    /// Raw rewards tuple returned by the live getter.
    rewards: tuple
}

/// Incoming native-payment swap body accepted by the verified CPMM pool.
struct (0xa5a7cbf8) DedustV2CpmmPayNative {
    /// Query id copied through the swap flow.
    queryId: uint64
    /// Native TON amount routed into the pool.
    amount: coins
    /// Referenced route-step cell.
    routeStep: cell
    /// Referenced swap-parameters cell.
    swapParams: cell
}

/// Observed incoming body parsed by the `0xde8402ce` dispatch branch.
struct (0xde8402ce) DedustV2CpmmOpcodeDe8402ce {
    /// Query id carried by the body.
    queryId: uint64
    /// Remaining opaque payload after the query id.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0xd1735400` dispatch branch.
struct (0xd1735400) DedustV2CpmmOpcodeD1735400 {
    /// Query id carried by the body.
    queryId: uint64
    /// Leading address argument.
    address0: address
    /// Remaining opaque payload after the address.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0x7362d09c` dispatch branch.
struct (0x7362d09c) DedustV2CpmmOpcode7362d09c {
    /// Query id carried by the body.
    queryId: uint64
    /// First coins argument.
    amount: coins
    /// Leading address argument.
    address0: address
    /// One-bit selector for the remaining payload encoding.
    hasRefTail: bool
    /// Remaining opaque payload after the selector.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0x25251ee0` dispatch branch.
struct (0x25251ee0) DedustV2CpmmOpcode25251ee0 {
    /// Query id carried by the body.
    queryId: uint64
    /// Referenced proof or context cell.
    ref0: cell
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Trailing address argument.
    address0: address
}

/// Observed incoming body parsed by the `0x0d29d6f2` dispatch branch.
struct (0x0d29d6f2) DedustV2CpmmOpcode0d29d6f2 {
    /// Query id carried by the body.
    queryId: uint64
    /// Referenced proof or context cell.
    ref0: cell
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Trailing address argument.
    address0: address
}

/// Observed incoming body parsed by the `0x5652f1df` dispatch branch.
struct (0x5652f1df) DedustV2CpmmOpcode5652f1df {
    /// Query id carried by the body.
    queryId: uint64
    /// Trailing address argument.
    address0: address
}

/// Observed incoming body parsed by the `0x29ff1bcf` dispatch branch.
struct (0x29ff1bcf) DedustV2CpmmOpcode29ff1bcf {
    /// Query id carried by the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
}

/// Observed incoming body parsed by the `0x419a17b3` dispatch branch.
struct (0x419a17b3) DedustV2CpmmOpcode419a17b3 {
    /// Query id carried by the body.
    queryId: uint64
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
}

/// Observed incoming body parsed by the `0xbe3e3179` dispatch branch.
struct (0xbe3e3179) DedustV2CpmmOpcodeBe3e3179 {
    /// Query id carried by the body.
    queryId: uint64
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
}

/// Observed incoming body parsed by the `0x20b5ef89` dispatch branch.
struct (0x20b5ef89) DedustV2CpmmOpcode20b5ef89 {
    /// Query id carried by the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// One-bit selector.
    flag0: bool
    /// Remaining opaque payload after the selector.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0xf6f6a3aa` dispatch branch.
struct (0xf6f6a3aa) DedustV2CpmmOpcodeF6f6a3aa {
    /// Query id carried by the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// Leading address argument.
    address0: address
    /// Fourth coins argument.
    amount3: coins
    /// Fifth coins argument.
    amount4: coins
    /// Remaining opaque payload after the fixed prefix.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0x00d8d8b9` dispatch branch.
struct (0x00d8d8b9) DedustV2CpmmOpcode00d8d8b9 {
    /// Query id carried by the body.
    queryId: uint64
    /// First one-bit flag.
    flag0: bool
    /// Second one-bit flag.
    flag1: bool
    /// Third one-bit flag.
    flag2: bool
    /// Remaining opaque payload after the fixed prefix.
    payload: RemainingBitsAndRefs
}

/// Observed incoming body parsed by the `0x909fdb65` dispatch branch.
struct (0x909fdb65) DedustV2CpmmOpcode909fdb65 {
    /// Query id carried by the body.
    queryId: uint64
    /// Two-bit mode field.
    mode: uint2
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
}

/// Observed incoming body parsed by the `0x9e17fbbe` dispatch branch.
struct (0x9e17fbbe) DedustV2CpmmOpcode9e17fbbe {
    /// Query id carried by the body.
    queryId: uint64
    /// Coins argument.
    amount0: coins
    /// Two-bit mode field.
    mode: uint2
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
}

/// Observed incoming body parsed by the `0xf287e089` dispatch branch.
struct (0xf287e089) DedustV2CpmmOpcodeF287e089 {
    /// Query id carried by the body.
    queryId: uint64
    /// Referenced opaque payload cell.
    payload: cell
}

/// Outgoing discovery or registration callback emitted by the verified CPMM pool.
struct (0x2c76b973) DedustV2CpmmOpcode2c76b973 {
    /// Query id copied into the callback.
    queryId: uint64
    /// Pool address emitted by the callback.
    poolAddress: address
    /// One-bit tail flag emitted by the callback.
    flag0: uint1
}

/// Standard excess message emitted by the verified CPMM pool.
struct (0xd53276db) DedustV2CpmmExcess {
    /// Query id copied into the refund.
    queryId: uint64
}

/// Error callback emitted by the verified CPMM pool.
struct (0xce185bd7) DedustV2CpmmErrorCallback {
    /// Query id copied into the callback.
    queryId: uint64
    /// Signed 32-bit error code.
    errorCode: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Short callback emitted by the verified CPMM pool.
struct (0x3216ca09) DedustV2CpmmCallback3216ca09 {
    /// Query id copied into the callback.
    queryId: uint64
    /// Coins value attached to the callback body.
    amount0: coins
    /// Signed 32-bit status or error code.
    code: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Referenced payload used by `0xbc1531a9`.
struct DedustV2CpmmOpcodeBc1531a9Details {
    /// Leading address copied into the details cell.
    address0: address
    /// Coins argument copied into the details cell.
    amount0: coins
    /// Optional referenced cell copied into the details cell.
    payload0: cell?
    /// One-bit flag copied into the details cell.
    flag0: uint1
    /// Trailing address copied into the details cell.
    address1: address
}

/// Outgoing body emitted by the `0xbc1531a9` send site.
struct (0xbc1531a9) DedustV2CpmmOpcodeBc1531a9 {
    /// Query id copied into the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// First varuint32 value.
    value0: varuint32
    /// Second varuint32 value.
    value1: varuint32
    /// Optional referenced payload.
    payload0: cell?
    /// One-bit flag.
    flag0: uint1
    /// Referenced details cell.
    details: Cell<DedustV2CpmmOpcodeBc1531a9Details>
}

/// Outgoing body emitted by the `0x855afcbd` send site.
struct (0x855afcbd) DedustV2CpmmOpcode855afcbd {
    /// Query id copied into the body.
    queryId: uint64
    /// First coins argument.
    amount0: coins
    /// Unsigned 16-bit parameter.
    value0: uint16
    /// Second coins argument.
    amount1: coins
    /// Optional referenced payload.
    payload0: cell?
    /// Trailing address argument.
    address0: address
    /// First varuint32 value.
    value1: varuint32
    /// Second varuint32 value.
    value2: varuint32
    /// Optional referenced payload.
    payload1: cell?
}

/// Outgoing body emitted by the `0x25f19752` send site.
struct (0x25f19752) DedustV2CpmmOpcode25f19752 {
    /// Query id copied into the body.
    queryId: uint64
    /// Trailing address argument.
    address0: address
    /// First varuint32 value.
    value0: varuint32
    /// Second varuint32 value.
    value1: varuint32
}

/// Outgoing body emitted by the `0x870a9579` send site.
struct (0x870a9579) DedustV2CpmmOpcode870a9579 {
    /// Query id copied into the body.
    queryId: uint64
    /// Remaining opaque payload after the query id.
    payload: RemainingBitsAndRefs
}

/// Outgoing body emitted by the `0x2e0cccba` send site.
struct (0x2e0cccba) DedustV2CpmmOpcode2e0cccba {
    /// Query id copied into the body.
    queryId: uint64
    /// Two-bit mode value.
    mode: uint2
    /// First unsigned 40-bit value.
    value0: uint40
    /// Coins argument.
    amount0: coins
    /// Varuint32 value.
    value1: varuint32
    /// Second unsigned 40-bit value.
    value2: uint40
    /// Trailing address or fallback slice.
    address0: address
}

/// Short error envelope emitted by several fallback branches.
struct (0xe8db4696) DedustV2CpmmOpcodeE8db4696 {
    /// Signed 32-bit status or error code.
    code: int32
    /// Optional referenced payload.
    payload: cell?
}

/// Outgoing swap event emitted by the verified CPMM pool.
struct (0x78e79ba4) DedustV2CpmmSwapEvent {
    /// One-bit event flag emitted by the pool.
    flag: bool
    /// First event amount.
    amount0: coins
    /// Second event amount.
    amount1: coins
    /// First event address.
    address0: address
    /// Second event address.
    address1: address
    /// First referenced event-detail cell.
    details0: cell
    /// Second referenced event-detail cell.
    details1: cell
}

/// Outgoing body emitted by the verified CPMM pool.
struct (0x35df2e12) DedustV2CpmmOpcode35df2e12 {
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
    /// Referenced payload cell.
    payload0: cell
}

/// Outgoing body emitted by the verified CPMM pool.
struct (0xc0d77b54) DedustV2CpmmOpcodeC0d77b54 {
    /// First coins argument.
    amount0: coins
    /// Second coins argument.
    amount1: coins
    /// Third coins argument.
    amount2: coins
    /// First address argument.
    address0: address
    /// Second address argument.
    address1: address
    /// Referenced payload cell.
    payload0: cell
}

type DedustV2CpmmIncomingMessage =
    | DedustV2CpmmOpcodeDe8402ce
    | DedustV2CpmmOpcodeD1735400
    | DedustV2CpmmPayNative
    | DedustV2CpmmOpcode7362d09c
    | DedustV2CpmmOpcode25251ee0
    | DedustV2CpmmOpcode0d29d6f2
    | DedustV2CpmmOpcode5652f1df
    | DedustV2CpmmOpcode29ff1bcf
    | DedustV2CpmmOpcode419a17b3
    | DedustV2CpmmOpcodeBe3e3179
    | DedustV2CpmmOpcode20b5ef89
    | DedustV2CpmmOpcodeF6f6a3aa
    | DedustV2CpmmOpcode00d8d8b9
    | DedustV2CpmmOpcode909fdb65
    | DedustV2CpmmOpcode9e17fbbe
    | DedustV2CpmmOpcodeF287e089

type DedustV2CpmmOutgoingMessage =
    | DedustV2CpmmOpcode2c76b973
    | DedustV2CpmmExcess
    | DedustV2CpmmErrorCallback
    | DedustV2CpmmCallback3216ca09
    | DedustV2CpmmOpcodeE8db4696
    | DedustV2CpmmOpcode855afcbd
    | DedustV2CpmmOpcode25f19752
    | DedustV2CpmmOpcodeBc1531a9
    | DedustV2CpmmOpcode870a9579
    | DedustV2CpmmOpcode2e0cccba
    | DedustV2CpmmSwapEvent
    | DedustV2CpmmOpcode35df2e12
    | DedustV2CpmmOpcodeC0d77b54

/// High-confidence static exit codes proven by the verified decompile.
enum DedustV2CpmmErrors {
    /// Attached value does not cover the compute and forwarding budget required by the branch.
    InsufficientValue = 25,
    /// The derived child address does not match the expected sender.
    InvalidDerivedChild = 23,
    /// The sender must be in workchain 0.
    InvalidSenderWorkchain = 32,
    /// The requested wallet or position entry is absent from the live dictionary.
    EntryNotFound = 40,
    /// Iteration over the position dictionary reached the end without a match.
    PositionNotFound = 42,
    /// Tagged-union or opcode layout check failed.
    InvalidTag = 63,
    /// Fallback rejection for unsupported operation codes.
    UnsupportedOperation = 65535,
}

get fun get_position_address(ownerAddress: address): address {
    throw 0;
}

get fun get_pool_data(): DedustV2CpmmPoolDataReply {
    throw 0;
}
