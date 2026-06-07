/// TON cron interface with scheduler trigger body, cron getter shape, and runtime storage layout.
contract Cron {
    author: "TON"
    version: "1.0"
    description: "Curated TON cron interface for scheduler trigger decoding, cron getter metadata, and runtime storage"
    storage: CronStorage
    incomingExternal: CronIncomingExternalMessage
}

/// Runtime account data root for cron-enabled accounts.
struct CronStorage {
    /// Small runtime state tag.
    state: uint8
    /// 256-bit runtime control value.
    controlValue: uint256
    /// First root address field.
    rootAddress0: address
    /// Second root address field.
    rootAddress1: address
    /// Root-level TON amount.
    rootAmount: coins
    /// Referenced runtime parameters cell parsed by helper methods.
    runtime: Cell<CronRuntimeParameters>
    /// Raw auxiliary reference used by the runtime.
    auxiliary: cell
    /// Raw scheduler VM or implementation reference used by helper/getter paths.
    schedulerRuntime: cell
    /// Optional raw scheduler state dictionary tail.
    extraState: cell?
}

/// Referenced runtime parameters shared by cron scheduling paths.
struct CronRuntimeParameters {
    /// First runtime address field.
    runtimeAddress0: address
    /// Second runtime address field.
    runtimeAddress1: address
    /// Third runtime address field.
    runtimeAddress2: address
    /// Small unsigned runtime parameter stored after the three addresses.
    runtimeUint16: uint16
    /// Runtime TON amount stored after `runtimeUint16`.
    runtimeAmount: coins
    /// One-bit runtime flag.
    runtimeFlag: bool
    /// Referenced cron schedule-like state.
    schedule: Cell<CronScheduleState>
}

/// Schedule-like state nested inside runtime parameters.
struct CronScheduleState {
    /// Address carried in the schedule cell.
    scheduleAddress0: address
    /// Optional 256-bit value controlled by an inline Maybe bit.
    optionalValue: uint256?
    /// Schedule TON amount.
    scheduleAmount: coins
    /// 64-bit schedule value.
    scheduleUint64: uint64
    /// Final schedule address field.
    scheduleAddress1: address
}

/// External trigger body accepted by cron-enabled contracts.
struct (0x2114702d) CronTrigger {
    /// Reward destination for the trigger caller.
    rewardAddress: address
    /// Caller-selected anti-replay or randomization salt.
    salt: uint32
}

/// External inbound message bodies accepted by the cron interface.
type CronIncomingExternalMessage = CronTrigger

/// Structured result returned by `get_cron_info`.
struct GetCronInfoReply {
    /// Next planned cron call Unix time.
    nextCallTime: uint32
    /// Reward paid to the trigger caller in nanotons.
    reward: coins
    /// Contract balance minus reserved amounts, as signed 64-bit value.
    balanceMinusAmounts: int64
    /// Repeat interval in seconds.
    repeatEvery: uint32
}

/// Return cron scheduling metadata.
get fun get_cron_info(): GetCronInfoReply {
    return {
        nextCallTime: 0,
        reward: 0,
        balanceMinusAmounts: 0,
        repeatEvery: 0,
    };
}
