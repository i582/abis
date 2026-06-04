/// STON.fi DEX v2 referral-fee vault for one referrer/token pair.
contract StonfiVaultV2 {
    author: "STON.fi"
    version: "2.0"
    description: "Curated interface for the STON.fi DEX v2 Vault that accumulates referral fees and withdraws collected tokens through the Router"
    storage: StonfiVaultV2Storage
    incomingMessages: StonfiVaultV2IncomingMessage
    outgoingMessages: StonfiVaultV2OutgoingMessage
}

/// Persistent Vault state: referrer owner, Router jetton wallet, Router, and collected token amount.
struct StonfiVaultV2Storage {
    /// Owner/referrer of this Vault; used together with tokenAddress to derive the deterministic Vault address.
    ownerAddress: address
    /// Router's jetton wallet address for the token whose referral fees are collected in this Vault.
    tokenAddress: address
    /// Router address allowed to deposit referral fees and used as the withdrawal callback destination.
    routerAddress: address
    /// Amount of collected token fees currently tracked by the Vault, stored with `store_coins`.
    depositedAmount: coins
}

/// Router-originated message that increases the referrer fee tracker and returns TON excesses.
struct (0x0490f09b) StonfiDepositRefFeeV2 {
    /// Query id propagated from the upstream Pool/Router flow.
    queryId: uint64
    /// Amount of tokens to add to depositedAmount.
    jettonAmount: coins
    /// Address that receives TON excesses after the Vault reserves its storage balance.
    excessesAddress: address
}

/// User-facing request to send all collected tokens to the Vault owner through the Router.
struct (0x354bcdf4) StonfiWithdrawFeeV2 {
    /// Query id copied into the outgoing vault_pay_to callback.
    queryId: uint64
}

/// Vault-to-Router callback requesting transfer of withdrawn tokens to the Vault owner.
struct (0x2100c922) StonfiVaultPayToV2 {
    /// Correlation id from the withdrawal request.
    queryId: uint64
    /// Full collected token amount to transfer to toAddress.
    amountOut: coins
    /// Router's jetton wallet address for the withdrawn token.
    tokenAddress: address
    /// Vault owner/referrer that receives the withdrawn tokens.
    toAddress: address
}

/// Internal message bodies accepted by STON.fi Vault v2.
type StonfiVaultV2IncomingMessage =
    | StonfiDepositRefFeeV2
    | StonfiWithdrawFeeV2

/// Internal message bodies emitted by STON.fi Vault v2.
type StonfiVaultV2OutgoingMessage = StonfiVaultPayToV2

/// Current Vault state returned by `get_vault_data`.
struct GetVaultDataReply {
    /// Owner/referrer of this Vault.
    ownerAddress: address
    /// Router's jetton wallet address for the token whose fees are tracked by this Vault.
    tokenAddress: address
    /// Router address stored in persistent data.
    routerAddress: address
    /// Amount of collected tokens currently deposited, returned as a TVM stack integer.
    depositedAmount: int
}

/// Return the Vault owner, Router jetton wallet, Router address, and collected token amount.
get fun get_vault_data(): GetVaultDataReply {
    return {
        ownerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        tokenAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        routerAddress: address("0:0000000000000000000000000000000000000000000000000000000000000000"),
        depositedAmount: 0,
    };
}
