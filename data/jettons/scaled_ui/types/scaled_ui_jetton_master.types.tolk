/// TEP-526 Jetton master extension for UI-scaled displayed balances.
contract ScaledUiJettonMaster {
    author: "Maxim Gromov"
    version: "TEP-526"
    description: "Scaled UI Jetton master interface"
    outgoingMessages: ScaledUiJettonMasterOutgoingMessage
}

/// External-out event emitted when the display multiplier changes.
struct (0xac392598) ScaledUiDisplayMultiplierChanged {
    /// Non-zero numerator used to convert on-chain balances to displayed balances.
    numerator: varuint32
    /// Non-zero denominator used to convert on-chain balances to displayed balances.
    denominator: varuint32
    /// Optional snake-string reason for the multiplier change.
    comment: string?
}

/// External-out message bodies required by the scaled UI Jetton interface.
type ScaledUiJettonMasterOutgoingMessage = ScaledUiDisplayMultiplierChanged

/// Structured result returned by `get_display_multiplier`.
struct GetScaledUiDisplayMultiplierReply {
    /// Current display multiplier numerator returned as a stack integer.
    numerator: int
    /// Current display multiplier denominator returned as a stack integer.
    denominator: int
}

/// Return the display multiplier used to scale Jetton balances in UI.
get fun get_display_multiplier(): GetScaledUiDisplayMultiplierReply {
    throw 0;
}
