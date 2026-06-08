import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakeed_wallet.types"

const EXPECTED_QUERY_ID = 6083770387617170864
const EXPECTED_SENDER = "0:E9D14D56877D737B069183BF9495C2BF4E522D8A46B5715E2521E57D96EC9A39"

get fun `test stakeed wallet decodes real internal transfer body`() {
    val transfer = StakeedWalletInternalTransfer.fromCell(parseCellFromBase64("te6cckEBAgEAZgABqReNRRlUbeTvMPZFsEO5rKAIAdOimq0O+ub2DSMHfykrhX6cpFsUjWrivEpDyvst2TRzADp0U1Wh31zewaRg7+UlcK/TlItika1cV4lIeV9luyaORAcBABgAAAAANWEyYjg4NTFalttG"));

    expect(transfer.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(transfer.amount).toEqual(1000000000);
    expect(transfer.fromAddress).toEqual(address(EXPECTED_SENDER));
    expect(transfer.responseAddress).toEqual(address(EXPECTED_SENDER));
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(transfer.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(transfer.forwardPayload.remainingRefsCount()).toEqual(1);
}

get fun `test stakeed wallet decodes real transfer notification and excesses bodies`() {
    val notification = StakeedWalletTransferNotification.fromCell(parseCellFromBase64("te6cckEBAgEAQwABZHNi0JxUbeTvMPZFsEO5rKAIAdOimq0O+ub2DSMHfykrhX6cpFsUjWrivEpDyvst2TRzAQAYAAAAADVhMmI4ODUxY+iCCg=="));
    val excesses = StakeedWalletExcesses.fromCell(parseCellFromBase64("te6cckEBAQEADgAAGNUydttUbeTvMPZFsOW86I8="));

    expect(notification.queryId).toEqual(EXPECTED_QUERY_ID);
    expect(notification.amount).toEqual(1000000000);
    expect(notification.senderAddress).toEqual(address(EXPECTED_SENDER));
    expect(notification.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(notification.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(excesses.queryId).toEqual(EXPECTED_QUERY_ID);
}
