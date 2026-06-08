import "@acton/fmt"
import "@acton/testing/expect"
import "../types/stakee_pool.types"

const EXPECTED_USER = "0:046BD5C4306FCAD98DBE66E0D6EF04D627CBE423CA78048AE10E796BBB5D6EF5"
const EXPECTED_DEPOSIT_DESTINATION = "0:24871B76A2A5529A79DBD5553482F31F94510FF08A050DB2F7DE0D237D897F49"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test stakee pool decodes real deposit and withdrawal bodies`() {
    val deposit = StakeePoolDeposit.fromCell(parseCellFromBase64("te6cckEBAQEADgAAGEfVQ5EAAAAAAAAnEcKvVbM="));
    val withdraw = StakeePoolWithdraw.fromCell(parseCellFromBase64("te6cckEBAQEAVgAApzGbDNwAAAAAAAAAAEu4uu+YAAjXq4hg35WzG3zNwa3eCaxPl8hHlPAJFcIc8td2ut3rAAEa9XEMG/K2Y2+ZuDW7wTWJ8vkI8p4BIrhDnlru11u9SMd5vW0="));

    expect(deposit.queryId).toEqual(10001);
    expectNoTail(deposit.tail);
    expect(withdraw.queryId).toEqual(0);
    expect(withdraw.jettonAmount).toEqual(3146493689);
    expect(withdraw.fromAddress).toEqual(address(EXPECTED_USER));
    expect(withdraw.responseAddress).toEqual(address(EXPECTED_USER));
    expect(withdraw.waitTillRoundEnd).toBeFalse();
    expect(withdraw.fillOrKill).toBeFalse();
}

get fun `test stakee pool decodes real outgoing withdrawal and payout mint bodies`() {
    val withdrawal = StakeePoolWithdrawal.fromCell(parseCellFromBase64("te6cckEBAQEADgAAGAp3U1wAAAAAAAAAALkbG1U="));
    val mint = StakeePayoutMint.fromCell(parseCellFromBase64("te6cckEBAQEAOgAAbxZ0sKAAAAAAAAAnEYAEkONu1FSqU087eqqmkF5j8ooh/hFAobZe+8Gkb7Ev6SoEXLYqlIC+vCAB/gpPRA=="));

    expect(withdrawal.queryId).toEqual(0);
    expect(mint.queryId).toEqual(10001);
    expect(mint.destination).toEqual(address(EXPECTED_DEPOSIT_DESTINATION));
    expect(mint.amount).toEqual(9367655754);
    expect(mint.notificationTon).toEqual(100000000);
    expect(mint.forwardTon).toEqual(0);
}
