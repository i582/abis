import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/jvault_pool.types"

const STAKE_OWNER = "0:681352BACD2398CAFF0B825C9414F5D5652281742C8D3F87EB090E2514BF9C94"
const LOCK_PERIOD = 2592000

fun loadReferencedPayload(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();
    val result = payload.loadRef();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    return result;
}

get fun `test decodes live jvault pool stake notification and wallet initialization`() {
    val txHash = "YgEhcb2I4VDeEOrUDzM9cQ91lum1rhwj4+96hd51FRE=";
    val txLt = "94206181000007";
    val notificationBody = parseCellFromBase64(
        "te6cckEBAgEAQQABaHNi0JwAAAAAAAAAAGBIwnOVAAgA0CaldZpHMZX+FwS5KCnrqspFAuhZGn8P1hIcSil/OSkBABDjoGmJACeNAI5LL4A=",
    );
    val notification = JVaultPoolTransferNotification.fromCell(notificationBody);
    var forwardPayload = notification.forwardPayload;
    val stakePayloadCell = loadReferencedPayload(mutate forwardPayload);
    val stakePayload = JVaultPoolStakeJettonsPayload.fromCell(stakePayloadCell);

    expect(notification.queryId).toEqual(0);
    expect(notification.amount).toEqual(5000000000000);
    expect(notification.sender).toEqual(address(STAKE_OWNER));
    expect(stakePayload.lockPeriod).toEqual(LOCK_PERIOD);
    expect(stakePayload.referrerTail.remainingBitsCount()).toEqual(0);
    expect(stakePayload.referrerTail.remainingRefsCount()).toEqual(0);
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());

    val inviteeBody = parseCellFromBase64(
        "te6cckEBAQEAEwAAITg0EeoAAAAAAAAAAAAAADMgo4wxsw==",
    );
    val invitee = JVaultPoolInviteeSetData.fromCell(inviteeBody);
    expect(invitee.queryId).toEqual(0);
    expect(invitee.poolId).toEqual(51);
    expect(invitee.referrerAddress).toBeNull();
    expect(invitee.referrerWalletCode).toBeNull();
    expect(invitee.toCell().hash()).toEqual(inviteeBody.hash());

    val stakingWalletBody = parseCellFromBase64(
        "te6cckEBAQEALAAAU9aKSsEAAAAAAAAAAA////////////////////8D6ECPDRgDAkYTnKgABAiqiaQ=",
    );
    val stakingWallet = JVaultPoolReceiveJettons.fromCell(stakingWalletBody);
    expect(stakingWallet.queryId).toEqual(0);
    expect(stakingWallet.minDeposit).toEqual(0);
    expect(stakingWallet.unstakeCommission).toEqual(1000);
    expect(stakingWallet.unstakeFee).toEqual(150000000);
    expect(stakingWallet.whitelist.isEmpty()).toBeTrue();
    expect(stakingWallet.stakedAmount).toEqual(notification.amount);
    expect(stakingWallet.depositCommission).toEqual(0);
    expect(stakingWallet.toCell().hash()).toEqual(stakingWalletBody.hash());

    println("JVAULT_POOL_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live jvault pool reward update and referral messages`() {
    val txHash = "BGWdtUX7bGUwAAVp7Y2MVv0XWluYaWrLJwn8OnQGkn0=";
    val txLt = "94206181000012";
    val requestBody = parseCellFromBase64(
        "te6cckEBAgEAkwABk/XFuqMAAAAAAAAAAIANAmpXWaRzGV/hcEuSgp66rKRQLoWRp/D9YSHEopfzkoAE8aAOC1VJwNVgAAAAAAAAAAAAAASMJzlQAIBAAQCHoXABHNDC01MHD4U+3FIHktw6QISBkXgGpjQkFoOhkgVpelQAAAAAAAAAAAAAAAAAAAAAdJ9+1SlHB3XqYFi6llzzLCBPJCVQ",
    );
    val request = JVaultPoolRequestUpdateRewards.fromCell(requestBody);
    expect(request.queryId).toEqual(0);
    expect(request.stakeOwnerAddress).toEqual(address(STAKE_OWNER));
    expect(request.lockPeriod).toEqual(LOCK_PERIOD);
    expect(request.userJettonBalance).toBeGreater(0);
    expect(request.userRewards.isEmpty()).toBeFalse();
    expect(request.forwardedTail.remainingBitsCount()).toEqual(0);
    expect(request.forwardedTail.remainingRefsCount()).toEqual(0);
    expect(request.toCell().hash()).toEqual(requestBody.hash());

    val referralBody = parseCellFromBase64(
        "te6cckEBAQEAIgAAP1XDW0AAAAAAAAAAAAAAADMAAAAAAAAAAAACRhOcqABA+9Hc5Q==",
    );
    val referral = JVaultPoolInviteeRequestUpdateReferrer.fromCell(referralBody);
    expect(referral.queryId).toEqual(0);
    expect(referral.poolId).toEqual(51);
    expect(referral.balanceChange).toBeGreater(0);
    expect(referral.toCell().hash()).toEqual(referralBody.hash());

    val updateBody = parseCellFromBase64(
        "te6cckEBAgEAewABW66TB84AAAAAAAAAAMAGgTUrrNI5jK/wuCXJQU9dVlIoF0LI0/h+sJDiUUv5yUgBAI+hcAEc0MLTUwcPhT7cUgeS3DpAhIGReAamNCQWg6GSBWl6VAAAAAAAAAAAAAAAAAAAAAB0n4FCIevFqZTfhwMMU7eFAuxcuyDaG5oo",
    );
    val update = JVaultPoolUpdateRewards.fromCell(updateBody);
    expect(update.queryId).toEqual(0);
    expect(update.userRewards.isEmpty()).toBeFalse();
    expect(update.stakeOwnerAddress).toEqual(address(STAKE_OWNER));
    expect(update.toCell().hash()).toEqual(updateBody.hash());

    println("JVAULT_POOL_UPDATE_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live jvault pool reward claim and jetton transfer`() {
    val txHash = "qBfeXSufOGT48D+98gGBj4Fjci9QiJiePGkU401UsoA=";
    val txLt = "94206051000028";
    val claimBody = parseCellFromBase64(
        "te6cckEBAwEArQACc0S8H+MAAAAAAAAAAIANAmpXWaRzGV/hcEuSgp66rKRQLoWRp/D9YSHEopfzkoAE8aAOC1VJwNVgAcABAgCPoXABHNDC01MHD4U+3FIHktw6QISBkXgGpjQkFoOhkgVpelQAAAAAAAAAAAAAAAAAAAAAc8CEY7/WwSdhGnkh2FlyDQREv7ngAEWhcAEc0MLTUwcPhT7cUgeS3DpAhIGReAamNCQWg6GSBWl6VT9b4RQ=",
    );
    val claim = JVaultPoolSendClaimedRewards.fromCell(claimBody);
    expect(claim.queryId).toEqual(0);
    expect(claim.stakeOwnerAddress).toEqual(address(STAKE_OWNER));
    expect(claim.lockPeriod).toEqual(LOCK_PERIOD);
    expect(claim.userRewards.isEmpty()).toBeFalse();
    expect(claim.jettonsToClaim.isEmpty()).toBeFalse();
    expect(claim.toCell().hash()).toEqual(claimBody.hash());

    val transferBody = parseCellFromBase64(
        "te6cckEBAgEAdQABrg+KfqUAAAAAAAAAAGBDL0Ob0ngA0CaldZpHMZX+FwS5KCnrqspFAuhZGn8P1hIcSil/OSkAGgTUrrNI5jK/wuCXJQU9dVlIoF0LI0/h+sJDiUUv5yUCAwEAMgAAAABDbGFpbSBzdGFraW5nIHJld2FyZHO1h35f",
    );
    val transfer = JVaultPoolJettonTransfer.fromCell(transferBody);
    expect(transfer.queryId).toEqual(0);
    expect(transfer.amount).toEqual(4616892300583);
    expect(transfer.destination).toEqual(address(STAKE_OWNER));
    expect(transfer.responseDestination).toBeNotNull();
    expect(transfer.responseDestination!).toEqual(address(STAKE_OWNER));
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(transfer.forwardPayload).toBeNotNull();
    expect(transfer.toCell().hash()).toEqual(transferBody.hash());

    println("JVAULT_POOL_CLAIM_TX={} LT={}", txHash, txLt);
}
