import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/jvault_staking_wallet.types"

const STAKE_OWNER = "0:681352BACD2398CAFF0B825C9414F5D5652281742C8D3F87EB090E2514BF9C94"
const LOCK_PERIOD = 2592000

get fun `test decodes live wallet stake credit and pool update request`() {
    val txHash = "+pIJDkzF0PUCv1ftveNSzUbf1bctfTGwu5OZ1FTiyNc=";
    val txLt = "94206181000010";
    val receiveBody = parseCellFromBase64(
        "te6cckEBAQEALAAAU9aKSsEAAAAAAAAAAA////////////////////8D6ECPDRgDAkYTnKgABAiqiaQ=",
    );
    val receive = JVaultStakingWalletReceiveJettons.fromCell(receiveBody);
    expect(receive.queryId).toEqual(0);
    expect(receive.minDeposit).toEqual(0);
    expect(receive.unstakeCommission).toEqual(1000);
    expect(receive.unstakeFee).toEqual(150000000);
    expect(receive.whitelist.isEmpty()).toBeTrue();
    expect(receive.receivedJettons).toEqual(5000000000000);
    expect(receive.forwardedTail.remainingBitsCount()).toEqual(0);
    expect(receive.forwardedTail.remainingRefsCount()).toEqual(0);
    expect(receive.toCell().hash()).toEqual(receiveBody.hash());

    val requestBody = parseCellFromBase64(
        "te6cckEBAgEAkwABk/XFuqMAAAAAAAAAAIANAmpXWaRzGV/hcEuSgp66rKRQLoWRp/D9YSHEopfzkoAE8aAOC1VJwNVgAAAAAAAAAAAAAASMJzlQAIBAAQCHoXABHNDC01MHD4U+3FIHktw6QISBkXgGpjQkFoOhkgVpelQAAAAAAAAAAAAAAAAAAAAAdJ9+1SlHB3XqYFi6llzzLCBPJCVQ",
    );
    val request = JVaultStakingWalletRequestUpdateRewards.fromCell(requestBody);
    expect(request.queryId).toEqual(receive.queryId);
    expect(request.stakeOwnerAddress).toEqual(address(STAKE_OWNER));
    expect(request.lockPeriod).toEqual(LOCK_PERIOD);
    expect(request.tvlChange).toEqual(receive.receivedJettons);
    expect(request.userRewards.isEmpty()).toBeFalse();
    expect(request.forwardedTail.remainingBitsCount()).toEqual(0);
    expect(request.forwardedTail.remainingRefsCount()).toEqual(0);
    expect(request.toCell().hash()).toEqual(requestBody.hash());

    println("JVAULT_STAKING_WALLET_RECEIVE_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live wallet reward response and excess`() {
    val txHash = "vCwJ1ddgofdZtFAdW/Aw6Tp9WaCc5QVekVFwDp+TK/U=";
    val txLt = "94206181000015";
    val updateBody = parseCellFromBase64(
        "te6cckEBAgEAewABW66TB84AAAAAAAAAAMAGgTUrrNI5jK/wuCXJQU9dVlIoF0LI0/h+sJDiUUv5yUgBAI+hcAEc0MLTUwcPhT7cUgeS3DpAhIGReAamNCQWg6GSBWl6VAAAAAAAAAAAAAAAAAAAAAB0n4FCIevFqZTfhwMMU7eFAuxcuyDaG5oo",
    );
    val update = JVaultStakingWalletUpdateRewards.fromCell(updateBody);
    expect(update.queryId).toEqual(0);
    expect(update.rewards.isEmpty()).toBeFalse();
    expect(update.responseAddress).toEqual(address(STAKE_OWNER));
    expect(update.toCell().hash()).toEqual(updateBody.hash());

    val excessBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=",
    );
    val excess = JVaultStakingWalletExcesses.fromCell(excessBody);
    expect(excess.queryId).toEqual(update.queryId);
    expect(excess.toCell().hash()).toEqual(excessBody.hash());

    println("JVAULT_STAKING_WALLET_UPDATE_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live wallet reward claim request and pool message`() {
    val txHash = "j7jESebMoZh2r70oD6trrtcZ5GJc/VvsuxK9YZ1cYyY=";
    val txLt = "94206051000026";
    val claimBody = parseCellFromBase64(
        "te6cckEBAgEANQABGXjZ8QkAAAAAAAAAAMABAEWhcAEc0MLTUwcPhT7cUgeS3DpAhIGReAamNCQWg6GSBWl6VXWzI6M=",
    );
    val claim = JVaultStakingWalletClaimRewards.fromCell(claimBody);
    expect(claim.queryId).toEqual(0);
    expect(claim.jettonsToClaim.isEmpty()).toBeFalse();
    expect(claim.toCell().hash()).toEqual(claimBody.hash());

    val sendBody = parseCellFromBase64(
        "te6cckEBAwEArQACc0S8H+MAAAAAAAAAAIANAmpXWaRzGV/hcEuSgp66rKRQLoWRp/D9YSHEopfzkoAE8aAOC1VJwNVgAcABAgCPoXABHNDC01MHD4U+3FIHktw6QISBkXgGpjQkFoOhkgVpelQAAAAAAAAAAAAAAAAAAAAAc8CEY7/WwSdhGnkh2FlyDQREv7ngAEWhcAEc0MLTUwcPhT7cUgeS3DpAhIGReAamNCQWg6GSBWl6VT9b4RQ=",
    );
    val send = JVaultStakingWalletSendClaimedRewards.fromCell(sendBody);
    expect(send.queryId).toEqual(claim.queryId);
    expect(send.stakeOwnerAddress).toEqual(address(STAKE_OWNER));
    expect(send.lockPeriod).toEqual(LOCK_PERIOD);
    expect(send.userRewards.isEmpty()).toBeFalse();
    expect(send.jettonsToClaim.isEmpty()).toBeFalse();
    expect(send.toCell().hash()).toEqual(sendBody.hash());

    println("JVAULT_STAKING_WALLET_CLAIM_TX={} LT={}", txHash, txLt);
}

get fun `test decodes live wallet delayed unstake request and cancellation`() {
    val unstakeTxHash = "N9A9gkLuSd9omKy56utPbySBuwhAOGjdysBlZpcAjIo=";
    val unstakeBody = parseCellFromBase64(
        "te6cckEBAQEAFQAAJQFo1LcAAAAAAAAAAGAV0+95gAg6Fbkt",
    );
    val unstake = JVaultStakingWalletUnstakeRequest.fromCell(unstakeBody);
    expect(unstake.queryId).toEqual(0);
    expect(unstake.amount).toEqual(1500000000000);
    expect(unstake.toCell().hash()).toEqual(unstakeBody.hash());

    val cancellationTxHash = "rj32FyuX5O7wZcoTinUFGK303NlTXESuHOUIxa4l214=";
    val cancellationBody = parseCellFromBase64(
        "te6cckEBAgEAGAABGaSRDxrBQRn2NERHCcABAAugaiu04kBLMR78",
    );
    val cancellation = JVaultStakingWalletCancelUnstakeRequests.fromCell(cancellationBody);
    expect(cancellation.queryId).toEqual(13925440068035823369);
    expect(cancellation.requests.isEmpty()).toBeFalse();
    expect(cancellation.toCell().hash()).toEqual(cancellationBody.hash());

    val updateBody = parseCellFromBase64(
        "te6cckEBAgEAlwABk/XFuqPBQRn2NERHCYANAmpXWaRzGV/hcEuSgp66rKRQLoWRp/D9YSHEopfzkoAE8aAOCzDohwrgAAAAAAAAAAAAAAFdPveYAIBAAQCPoXABHNDC01MHD4U+3FIHktw6QISBkXgGpjQkFoOhkgVpelQAAAAAAAAAAAAAAAAAAAAAcFkrnlKs5L7XqxwW/OK7yRkrv/YgmKeVGg==",
    );
    val update = JVaultStakingWalletRequestUpdateRewards.fromCell(updateBody);
    expect(update.queryId).toEqual(cancellation.queryId);
    expect(update.tvlChange).toBeGreater(0);
    expect(update.toCell().hash()).toEqual(updateBody.hash());

    println(
        "JVAULT_STAKING_WALLET_UNSTAKE_TX={} CANCEL_TX={}",
        unstakeTxHash,
        cancellationTxHash,
    );
}
