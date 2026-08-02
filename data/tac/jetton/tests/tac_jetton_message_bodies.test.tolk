import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tac_jetton.types"

get fun `test tac jetton decodes real mint and internal transfer`() {
    val txHash = "M/LvXsalF6LaCIOhl4zOTpC7+e2HGW6gQ1BKOMAopVM=";
    val txLt = "67285703000010";
    val mintBody = parseCellFromBase64(
        "te6cckECEAEAAbcAAaTXucBuYSW5IwQkhQaAED3qn/8kikfNqIlxT1TPAnbQhxkt7Q8XrJiRRtuv/RICCQAge9U//kkUj5tREuKeqZ4E7aEOMlvaHi9ZMSKNt1/6JAQFAQEDAMACAgEgAwQBQ7/wgutmO1egAZL0pqxGcojfLf7dudob7ij2UhyL69IfHsAFAgEgBgcAlgBodHRwczovL21ldGEudGFjLmJ1aWxkL2Z0L2ltYWdlLzB4NDE4M0JkMjUzRGMxOTE4QTA0QmQ4YThkRDU0NkJhQUQ1ODg5ODEwOQIBIAgJAgEgDA0BQb9FRqb/4bec/dhrrT24dDE9zeL7BeanSqfzVS2WF8edEwoBQb9u1PlCp4SM4ssGa3ehEoxqH/jEP0OKLc4kYSup/6uLAwsAEgBSZTcgVVNEVAAQAFJlN1VTRFQBQb9SCN70b1odT53OZqswn0qFEwXxZvke952SPvWONPmiCQ4BQb9dAfpePAaQHEUEbGst3Opa92T+oO7XKhDUBPIxLOskfQ8AVgAweDQxODNCZDI1M0RjMTkxOEEwNEJkOGE4ZEQ1NDZCYUFENTg4OTgxMDkABgAxOJgvF3U=",
    );
    val transferBody = parseCellFromBase64(
        "te6cckEBAQEAVAAAoxeNRRlhJbkjBCSFBhBIAKw5VImP0uqooeBYT8XmBUlRnBG/lKlekAChNpJdWWOnACB71T/+SRSPm1ES4p6pngTtoQ4yW9oeL1kxIo23X/okBAWAVyXP",
    );
    val mint = TacJettonMint.fromCell(mintBody);
    val transfer = TacJettonInternalTransfer.fromCell(transferBody);

    expect(mint.queryId).toEqual(7000204755861800198);
    expect(mint.jettonAmount).toEqual(4);
    expect(mint.newJettonContent).toBeNotNull();
    expect(transfer.queryId).toEqual(mint.queryId);
    expect(transfer.jettonAmount).toEqual(mint.jettonAmount);
    expect(transfer.senderAddress).toEqual(
        address("0:561CAA44C7E9755450F02C27E2F302A4A8CE08DFCA54AF4800509B492EACB1D3"),
    );
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(mint.toCell().hash()).toEqual(mintBody.hash());
    expect(transfer.toCell().hash()).toEqual(transferBody.hash());
    println("TAC_JETTON_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test tac jetton decodes real burn and tvm message to evm`() {
    val txHash = "1eeulaahF/XYulILb5p0ibT2l/R6M1dQGSfJRVU7hB0=";
    val txLt = "67329907000005";
    val burnBody = parseCellFromBase64(
        "te6cckECBwEAAjMAAa173ZfeAAAAAGmfJGB2iXfKqLkoKAGvVIkwEPhY5Ge3Pn+1fTazEWKKKS6eRD6m0eWYQIMCBQAIKVpjvJwVK5nzjpXSBJkZCxMFfiCH1QJSbKYWLMJ7i/ABAgEOAgMAF50+xgGIRA6gkzk5zAH+eyJldm1DYWxsIjp7InRhcmdldCI6IjB4MDAxZTI5NDc5QjNERmJhQTBjMzcxRWFBNUUyM0UxNTdlMTg4ODcxZCIsIm1ldGhvZE5hbWUiOiJyZWRlZW0oYnl0ZXMsYnl0ZXMpIiwiYXJndW1lbnRzIjoiQUFBQUFBQUFBQUFBQQQB/kFBQVFZTzlKVDNCa1lvRXZZcU4xVWE2clZpSmdRa0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQWFKZDhxb3VTZ2dBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEiLCJnYXNMaW1pdCIFAf46NzI2MzE3fSwic2hhcmRzS2V5IjoiMTc3MjAzNjY2MiIsInNoYXJkQ291bnQiOjEsImV2bVZhbGlkRXhlY3V0b3JzIjpbIjB4NDU1ZDE4ODgyYjUyMjdGMTUzRDI4MDJmRTQwMUQ2QzAwQWE1YTVCOCJdLCJ0dm1WYWxpZEV4BgB8ZWN1dG9ycyI6WyJFUUI5WW83a1k3aGxzVkI2YWVpOFprU3BpSTJPUENfa2tiaDVLQW9VcktXMDRaeFciXX3Z++7v",
    );
    val tvmMessageBody = parseCellFromBase64(
        "te6cckECBgEAAjMAArZsWCBZAAAAAGmfJGCwr6dNDADXqkSYCHwscjPbnz/avptZiLFFFJdPIh9TaPLMIEGBAoAa9UiTAQ+FjkZ7c+f7V9NrMRYoopLp5EPqbR5ZhAgwIE7RLvlVFyUFAQIAF50+xgGIRA6gkzk5zAH+eyJldm1DYWxsIjp7InRhcmdldCI6IjB4MDAxZTI5NDc5QjNERmJhQTBjMzcxRWFBNUUyM0UxNTdlMTg4ODcxZCIsIm1ldGhvZE5hbWUiOiJyZWRlZW0oYnl0ZXMsYnl0ZXMpIiwiYXJndW1lbnRzIjoiQUFBQUFBQUFBQUFBQQMB/kFBQVFZTzlKVDNCa1lvRXZZcU4xVWE2clZpSmdRa0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQWFKZDhxb3VTZ2dBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUEiLCJnYXNMaW1pdCIEAf46NzI2MzE3fSwic2hhcmRzS2V5IjoiMTc3MjAzNjY2MiIsInNoYXJkQ291bnQiOjEsImV2bVZhbGlkRXhlY3V0b3JzIjpbIjB4NDU1ZDE4ODgyYjUyMjdGMTUzRDI4MDJmRTQwMUQ2QzAwQWE1YTVCOCJdLCJ0dm1WYWxpZEV4BQB8ZWN1dG9ycyI6WyJFUUI5WW83a1k3aGxzVkI2YWVpOFprU3BpSTJPUENfa2tiaDVLQW9VcktXMDRaeFciXX1oSu0V",
    );
    val burn = TacJettonBurnNotification.fromCell(burnBody);
    val tvmMessage = TacJettonTvmMessageToEvm.fromCell(tvmMessageBody);
    val crosschain = burn.crosschainPayload!.load();

    expect(burn.queryId).toEqual(1772037216);
    expect(burn.jettonAmount).toEqual(29439959270920834);
    expect(burn.crosschainPayload).toBeNotNull();
    expect(tvmMessage.queryId).toEqual(burn.queryId);
    expect(tvmMessage.operation).toEqual(0xb0afa74d);
    expect(tvmMessage.jettonAmount).toEqual(burn.jettonAmount);
    expect(tvmMessage.ownerAddress).toEqual(burn.ownerAddress);
    expect(tvmMessage.responseAddress).toEqual(burn.ownerAddress);
    expect(tvmMessage.crosschainTonAmount).toEqual(crosschain.crosschainTonAmount);
    expect(tvmMessage.evmData).toBeNotNull();
    expect(burn.toCell().hash()).toEqual(burnBody.hash());
    expect(tvmMessage.toCell().hash()).toEqual(tvmMessageBody.hash());
    println("TAC_JETTON_BURN_TX={} LT={}", txHash, txLt);
}
