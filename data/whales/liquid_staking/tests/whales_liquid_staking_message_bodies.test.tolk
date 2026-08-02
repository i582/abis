import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/whales_liquid_staking.types"

get fun `test Whales decodes a real deposit and wsTON mint`() {
    val txHash = "kAv9+4BOEMEY5MaxcGhvAtO5h93XJYozz7IvZLnwxt0=";
    val txLt = "94010779000001";
    val depositBody = parseCellFromBase64(
        "te6cckEBAQEANQAAZXvNH+8AAAAAAAAAAEhQilJYAQcIHtowEAamQNHul1YnpK2nBK5idX9uAXD5iITq0JMQEPCFGtQ=",
    );
    val transferBody = parseCellFromBase64(
        "te6cckEBAQEAVgAApxeNRRkAAAAAAAAAAEdMqnh4AOiVGNwwePNUatuh/7Z5AQryzopYMytFI8McD9mlX2FjACDhA9tGAgDUyBo90urE9JW04JXMTq/twC4fMRCdWhJiAqNf1FI=",
    );
    val deposit = WhalesLiquidStakingDeposit.fromCell(depositBody);
    val transfer = WhalesLiquidStakingInternalTransfer.fromCell(transferBody);

    expect(deposit.queryId).toEqual(0);
    expect(deposit.amount).toEqual(2231936293);
    expect(deposit.forwardTonAmount).toEqual(0);
    expect(transfer.queryId).toEqual(deposit.queryId);
    expect(transfer.jettonAmount > 0).toBeTrue();
    expect(transfer.responseAddress).toEqual(deposit.responseAddress);
    expect(transfer.forwardTonAmount).toEqual(deposit.forwardTonAmount);
    expect(deposit.toCell().hash()).toEqual(depositBody.hash());
    expect(transfer.toCell().hash()).toEqual(transferBody.hash());
    println(
        "WHALES_DEPOSIT_TX={} LT={} TON={} WSTON={}",
        txHash,
        txLt,
        deposit.amount,
        transfer.jettonAmount,
    );
}

get fun `test Whales decodes a real withdrawal and wsTON burn`() {
    val txHash = "z6Q8YL+iEJOQAd+6MdyfNoB5XlsJegXwG/KfVZ9SiL8=";
    val txLt = "94107067000003";
    val withdrawBody = parseCellFromBase64(
        "te6cckEBAQEANQAAZdqAPv0AAAAAAAAAAFA9oTpL2AAAWW0VDcXXbRBF/aKXQ2F78OA9u3qQUIegeWjXUZAQtZ3z3jY=",
    );
    val burnBody = parseCellFromBase64(
        "te6cckEBAQEANQAAZVlfB7wAAAAAAAAAAFA9oTpL2AAAWW0VDcXXbRBF/aKXQ2F78OA9u3qQUIegeWjXUZAQtV3+COI=",
    );
    val withdraw = WhalesLiquidStakingWithdraw.fromCell(withdrawBody);
    val burn = WhalesLiquidStakingJettonBurn.fromCell(burnBody);

    expect(withdraw.queryId).toEqual(0);
    expect(withdraw.jettonAmount).toEqual(16543622333);
    expect(burn.queryId).toEqual(withdraw.queryId);
    expect(burn.jettonAmount).toEqual(withdraw.jettonAmount);
    expect(burn.responseAddress).toEqual(withdraw.responseAddress);
    expect(withdraw.toCell().hash()).toEqual(withdrawBody.hash());
    expect(burn.toCell().hash()).toEqual(burnBody.hash());
    println("WHALES_WITHDRAW_TX={} LT={} WSTON={}", txHash, txLt, burn.jettonAmount);
}

get fun `test Whales decodes real collection and wallet debt bodies`() {
    val txHash = "0rVX4bgrC42jqcSIF0s7mzoqWG4te5g51ZV43uWfNus=";
    val txLt = "94163537000032";
    val collectBody = parseCellFromBase64(
        "te6cckEBAQEAMAAAW0oQ4CIAAAAAAAAAAIARKs31c50v8CzHi+U1hDim6DzD304aeLN2A+KIGIEqA5DyG4Ks",
    );
    val debtBody = parseCellFromBase64(
        "te6cckEBAQEAEgAAIJAGIQwAAAAAAAAAAAAAA5Tegz9t",
    );
    val collect = WhalesLiquidStakingCollect.fromCell(collectBody);
    val debt = WhalesLiquidStakingProvideDebt.fromCell(debtBody);

    expect(debt.queryId).toEqual(collect.queryId);
    expect(debt.roundId).toEqual(916);
    expect(collect.toCell().hash()).toEqual(collectBody.hash());
    expect(debt.toCell().hash()).toEqual(debtBody.hash());
    println("WHALES_COLLECT_TX={} LT={} ROUND={}", txHash, txLt, debt.roundId);
}

get fun `test Whales decodes a real burn notification and debt response`() {
    val txHash = "5lPtbQvIKU4pGwGoyxIytF8P2gCLUtozFfLUr6r1zVw=";
    val txLt = "94107067000007";
    val notificationBody = parseCellFromBase64(
        "te6cckEBAQEAVwAAqXvdl94AAAAAAAAAAFA9oTpL2AAAWW0VDcXXbRBF/aKXQ2F78OA9u3qQUIegeWjXUZAQtQAACy2iobi67aIIv7RS6GwvfhwHt29SChD0Dy0a6jICFqDRn2rh",
    );
    val responseBody = parseCellFromBase64(
        "te6cckEBAQEAOQAAbSM05GcAAAAAAAAAAAAAA5dQRjE9/KgAAFltFQ3F120QRf2il0Nhe/DgPbt6kFCHoHlo11GQELWTdv0o",
    );
    val notification = WhalesLiquidStakingBurnNotification.fromCell(notificationBody);
    val response = WhalesLiquidStakingBurnResponse.fromCell(responseBody);

    expect(notification.queryId).toEqual(0);
    expect(notification.jettonAmount).toEqual(16543622333);
    expect(notification.ownerAddress).toEqual(notification.responseAddress);
    expect(response.queryId).toEqual(notification.queryId);
    expect(response.roundId).toEqual(919);
    expect(response.withdrawalAmount).toEqual(18842116042);
    expect(response.responseAddress).toEqual(notification.responseAddress);
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());
    expect(response.toCell().hash()).toEqual(responseBody.hash());
    println(
        "WHALES_BURN_TX={} LT={} WSTON={} TON={}",
        txHash,
        txLt,
        notification.jettonAmount,
        response.withdrawalAmount,
    );
}

get fun `test Whales decodes a real wallet payout and completion receipt`() {
    val txHash = "s0sIaYwdUFUdLTmveKwkMilyVSylL2mB7nIJddRpgpQ=";
    val txLt = "94163537000036";
    val payoutBody = parseCellFromBase64(
        "te6cckEBAQEAOQAAbZeX8PsAAAAAAAAAAFLsGB/OwAAAOUgBEqzfVznS/wLMeL5TWEOKboPMPfThp4s3YD4ogYgSoDkdeERI",
    );
    val receiptBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGCPUIeEAAAAAAAAAAI7V0q4=",
    );
    val payout = WhalesLiquidStakingWalletWithdrawal.fromCell(payoutBody);
    val receipt = WhalesLiquidStakingWithdrawalCompleted.fromCell(receiptBody);

    expect(payout.queryId).toEqual(0);
    expect(payout.roundId).toEqual(916);
    expect(payout.amount).toEqual(200815017196);
    expect(receipt.queryId).toEqual(payout.queryId);
    expect(payout.toCell().hash()).toEqual(payoutBody.hash());
    expect(receipt.toCell().hash()).toEqual(receiptBody.hash());
    println("WHALES_PAYOUT_TX={} LT={} TON={}", txHash, txLt, payout.amount);
}

get fun `test Whales decodes real wallet discovery bodies`() {
    val txHash = "8vDwNpmCJosYzeAS04vWzjAwM72IwmA5CnJBd2SeINM=";
    val txLt = "65162185000006";
    val requestBody = parseCellFromBase64(
        "te6cckEBAQEAMAAAWyx2uXMqYRw/A6nu64AAgo6Ic1RobCpcqzVcL2cliXXXRs3UILVpj4jSTS11/ci+nAD0",
    );
    val responseBody = parseCellFromBase64(
        "te6cckEBAQEAMAAAW9FzVAAqYRw/A6nu64ARgr6+cyrvZBviNLidYOP6BedcCsksvKAOep0jd/NnvojyJxKW",
    );
    val request = WhalesLiquidStakingProvideWalletAddress.fromCell(requestBody);
    val response = WhalesLiquidStakingTakeWalletAddress.fromCell(responseBody);

    expect(request.includeOwnerAddress).toBeFalse();
    expect(response.queryId).toEqual(request.queryId);
    expect(response.walletAddress).toBeNotNull();
    expect(response.ownerAddress).toBeNull();
    expect(request.toCell().hash()).toEqual(requestBody.hash());
    expect(response.toCell().hash()).toEqual(responseBody.hash());
    println("WHALES_WALLET_TX={} LT={}", txHash, txLt);
}

get fun `test Whales decodes real controller and Elector stake bodies`() {
    val txHash = "h6y75n8QpNINQ06AQKj8HcxjpPVqVc2DOJhEevH8VLo=";
    val txLt = "94085778000015";
    val controllerBody = parseCellFromBase64(
        "te6cckEBAgEApAABvaIGXywAAAGfwUbW/Cw1A4HC8GqeZ0EW2cIRwxthYIGx2B8po3gYBk7TnBhP9r/SnM7oJU7ZYDU3p4QAAYAAI/cSPoFnCOK+JVP8tKUw3moIbhRH/H01odBwSN+dNrBAAQCAF2umaAPrBs9Y6CK7cZdGboc3XklwABLpOF3VfqXX14Y8ZvWoC62MlkQt+AtIP8JzOa0QZRieC6/Ndjs6W0xKAs69rhk=",
    );
    val electorBody = parseCellFromBase64(
        "te6cckEBAgEAmQABqE5zdEsAAAGfwUbW/C2zhCOGNsLBA2OwPlNG8DAMnac4MJ/tf6U5ndBKnbLAam9PCAADAABH7iR9As4RxXxKp/lpSmG81BDcKI/4+mtDoOCRvzptYAEAgBdrpmgD6wbPWOgiu3GXRm6HN15JcAAS6Thd1X6l19eGPGb1qAutjJZELfgLSD/CczmtEGUYnguvzXY7OltMSgJrlrzV",
    );
    val controller = WhalesLiquidStakingStakeSend.fromCell(controllerBody);
    val elector = WhalesLiquidStakingElectorNewStake.fromCell(electorBody);

    expect(controller.queryId).toEqual(elector.queryId);
    expect(controller.stake).toEqual(991625626832514);
    expect(controller.validatorPubkey).toEqual(elector.validatorPubkey);
    expect(controller.stakeAt).toEqual(elector.stakeAt);
    expect(controller.maxFactor).toEqual(elector.maxFactor);
    expect(controller.adnlAddress).toEqual(elector.adnlAddress);
    expect(controller.signature.hash()).toEqual(elector.signature.hash());
    expect(controller.toCell().hash()).toEqual(controllerBody.hash());
    expect(elector.toCell().hash()).toEqual(electorBody.hash());
    println("WHALES_STAKE_TX={} LT={} TON={}", txHash, txLt, controller.stake);
}

get fun `test Whales decodes real recover and unowned-withdraw flows`() {
    val recoverBody = parseCellFromBase64(
        "te6cckEBAQEAEgAAH2VNUY4AAAGfwN1jqTAYagT6CuIe",
    );
    val recoverRequestBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGEdldCQAAAAAAAAAAEUmpq4=",
    );
    val unownedBody = parseCellFromBase64(
        "te6cckEBAQEAEgAAHyUdapgAAAGfuXdYUDAYaghmXQMX",
    );
    val unownedResponseBody = parseCellFromBase64(
        "te6cckEBAQEADgAAGB0XFb8AAAGfuXdYULZzCRE=",
    );
    val recover = WhalesLiquidStakingStakeRecover.fromCell(recoverBody);
    val recoverRequest = WhalesLiquidStakingElectorRecoverStakeRequest.fromCell(
        recoverRequestBody,
    );
    val unowned = WhalesLiquidStakingWithdrawUnowned.fromCell(unownedBody);
    val unownedResponse = WhalesLiquidStakingWithdrawUnownedResponse.fromCell(
        unownedResponseBody,
    );

    expect(recover.queryId).toEqual(1785647162281);
    expect(recoverRequest.queryId).toEqual(0);
    expect(unowned.queryId).toEqual(unownedResponse.queryId);
    expect(recover.toCell().hash()).toEqual(recoverBody.hash());
    expect(recoverRequest.toCell().hash()).toEqual(recoverRequestBody.hash());
    expect(unowned.toCell().hash()).toEqual(unownedBody.hash());
    expect(unownedResponse.toCell().hash()).toEqual(unownedResponseBody.hash());
}
