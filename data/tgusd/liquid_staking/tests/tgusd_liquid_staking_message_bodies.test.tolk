import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tgusd_liquid_staking.types"

get fun `test tgUSD decodes a real supplied reward notification`() {
    val txHash = "p5S9OA8oagwDnJBjW0WShJSXtw/O1mpQawm5DQd6/qc=";
    val txLt = "93206903000019";
    val body = parseCellFromBase64(
        "te6cckEBAwEAqAABZHNi0JwAAAAAAAAAAEDk4cAIARPYCWJ0hHS1nIMPhPfC7LaK/nnWsYsCbKfGwa9/evyhAQGXX+FcgEDk4cAIAfnN14Snb0tDU9iUOLhfpoBPLN1OagMDPnjitcgXmfr/AA7KcGx7Jy4rMg7orvAlEyo1BwAHJ2Wd3p7C8MYbGCX74AIAQxgBYidTKWoElCzjPtInJlHW6ysthxRL6yBRYo39m4bEO/0pl8ww",
    );
    val notification = TgUsdTransferNotification.fromCell(body);
    expect(notification.queryId).toEqual(0);
    expect(notification.jettonAmount).toEqual(240000000);
    expect(notification.forwardPayload).toBeNotNull();
    val forward = notification.forwardPayload!.load();
    match (forward) {
        TgUsdStakeForwardPayload => {
            expect(false).toBeTrue();
        }
        TgUsdDeallocateStakedForwardPayload => {
            expect(false).toBeTrue();
        }
        TgUsdSupplyRewardForwardPayload => {
            expect(forward.collateralAmount).toEqual(notification.jettonAmount);
            expect(forward.source.getWorkchain()).toEqual(0);
            expect(forward.custodialWallet.getWorkchain()).toEqual(0);
        }
    }
    expect(notification.toCell().hash()).toEqual(body.hash());
    println("TGUSD_REWARD_TX={} LT={}", txHash, txLt);
}

get fun `test tgUSD decodes a real stake mint and event`() {
    val txHash = "Y19yXu14g6nNmnkslXaJZoSaUwPLykBgAkN1t4vnqE4=";
    val txLt = "79197177000013";
    val notificationBody = parseCellFromBase64(
        "te6cckEBAgEAOgABYHNi0JwAAAAAAAAAACAhGAAkCV1St3CJbYovxVZ+9Paj2DOzO4rhmi/BBS73bYSesQEACdTD/cAgEsjqvg==",
    );
    val mintBody = parseCellFromBase64(
        "te6cckEBAwEAoAABY2QrfQcAAAAAAAAAAIACQJXVK3cIltii/FVn709qPYM7M7iuGaL8EFLvdthJ6wgM9iRDAQGlF41FGQAAAAAAAAAAIB0IAdiOJ17GUJwEX2Y4KRuxsg7keAoOrTRiU9RI3YUM2vGPAASBK6pW7hEtsUX4qs/entR7BnZncVwzRfggpd7tsJPWBAcCACZNaW50OiBzdGdVU0QgdG9rZW5zcHlKow==",
    );
    val eventBody = parseCellFromBase64(
        "te6cckEBAgEAYgABl6LHE/EgHQICEYACQJXVK3cIltii/FVn709qPYM7M7iuGaL8EFLvdthJ6xAASBK6pW7hEtsUX4qs/entR7BnZncVwzRfggpd7tsJPWIBACFSTYjUKBUp+gnGRlLWjVPYeImco+o=",
    );
    val notification = TgUsdTransferNotification.fromCell(notificationBody);
    val mint = TgUsdJettonMint.fromCell(mintBody);
    val internalTransfer = mint.internalTransfer.load();
    val event = TgUsdStakedEvent.fromCell(eventBody);
    val totals = event.totals.load();

    expect(notification.queryId).toEqual(0);
    expect(notification.jettonAmount).toEqual(529);
    expect(notification.forwardPayload).toBeNotNull();
    val stakePayload = notification.forwardPayload!.load();
    match (stakePayload) {
        TgUsdStakeForwardPayload => {
            expect(stakePayload.recipient).toBeNull();
        }
        TgUsdDeallocateStakedForwardPayload => {
            expect(false).toBeTrue();
        }
        TgUsdSupplyRewardForwardPayload => {
            expect(false).toBeTrue();
        }
    }
    expect(mint.queryId).toEqual(notification.queryId);
    expect(mint.walletTonAmount).toEqual(108728865);
    expect(internalTransfer.queryId).toEqual(notification.queryId);
    expect(internalTransfer.jettonAmount).toEqual(464);
    expect(internalTransfer.jettonAmount).toEqual(event.mintedShares);
    expect(event.stakedAmount).toEqual(notification.jettonAmount);
    expect(event.staker).toEqual(notification.jettonSender);
    expect(event.recipient).toEqual(mint.recipient);
    expect(totals.totalShares >= event.mintedShares).toBeTrue();
    expect(totals.totalStaked >= event.stakedAmount).toBeTrue();
    expect(notification.toCell().hash()).toEqual(notificationBody.hash());
    expect(mint.toCell().hash()).toEqual(mintBody.hash());
    expect(event.toCell().hash()).toEqual(eventBody.hash());
    println("TGUSD_STAKE_TX={} LT={} MINTED_SHARES={}", txHash, txLt, event.mintedShares);
}

get fun `test tgUSD decodes a real unstake request install and event`() {
    val txHash = "OYSGldgE/COjoAyKNdX1YdbxJWtH+lNOvVesYIPqdp4=";
    val txLt = "85398857000030";
    val burnInfoBody = parseCellFromBase64(
        "te6cckEBAgEAPAABZoUwbIwAAAAAAAAACIAO38dowl8Rfup153Dg9oevdaDTCksuTh/EotByUXjkQuoD+EdKyQEACFFlZwTihj5t",
    );
    val installBody = parseCellFromBase64(
        "te6cckECCgEAAzEAAhngd4TlAAAAAAAAAAhAAQIBFP8A9KQT9LzyyAsDAJmAHYjidexlCcBF9mOCkbsbIO5HgKDq00YlPUSN2FDNrxjwAdv47RhL4i/dTrzuHB7Q9e60GmFJZcnD+JRaDkovHIhdQJERWbUakKeUggKq0zMixwCSXwPg0NMDAXKpCZJfA+BwAfpA+kAx+gAx9AH6ADH6AAP4OjLtRND6QAH4YfpAAfhi+gAB+GPTHwH4ZPoAAfhl0QPTH9M/IoIQTKg9yLrjDwQFAfwy+EL4QSZZUiLHBZJbf5THBcMA4vLkCQH6QDD4I/hEvpI0f5f4QRXHBcMA4vhFIZL4Q5Fw4qAgwgDy5BYDcIEbogH4Nvgs+C+goAGnAyGgcIFMmgH4NqD4LPgvoKBwgUi5Afg2oAFSUr7y5AMUofhC+EIWIdcLAcAAkTGRMOIGAvYxIYIQH8qkSbrjAmwiIYIQ4HeE5bqOVTH4QRLHBfLkBtQx1AHQAfQEMQH6QDH6QDH6ANMf+gAx0TL4I/hEvpr4RfhDoPhlcPhj3gH4ZPhDAaD4Y8j4Qc8W+ELPFvhD+gL4RAHLH/hF+gLJ7VTgAYIQJQjWarrjAoQP8vAHCAC2Q1ASyIIQ+j7BjgHLHxTLP1jPFgH6AgHPFsmAEPhBWhRwBMjLBVADzxYB+gIBcVjLaszJAfsIMJZw+GRw+GPecPhlyPhBzxb4Qs8W+EP6AvhEAcsf+EX6AsntVAHwMfhBFMcF8uQGAvoAMAJwgRZtAfg2+Cz4L6CgZqABUiK+8uQDoYAQ+EKNExZb3VyIGFzc2V0cyBhcmUgc2VjdXJlLiBQbGVhc2UgY29udGFjdCBUb3JjaCBGaW5hbmNlIHN1cHBvcnQgZm9yIGFzc2lzdGFuY2UugCQCc+EESxwXy5Ab0BPQEINFZMiFus5F/lSBus8MA4vLkDiFukTGOEfgqUiAB+QAB+QC98uQPAfsE4iBukTCOEO1EUhAB+QAB+QC98uQP7VTiAILIcAHLHwHPFslBMHAEyMsFUAPPFgH6AgFxWMtqzMkB+wgw+EUBoPhlyPhBzxb4Qs8W+EP6AvhEAcsf+EX6AsntVMoFhto=",
    );
    val eventBody = parseCellFromBase64(
        "te6cckEBAQEARwAAibfEohdQH8I6VkUCREVm1IAO38dowl8Rfup153Dg9oevdaDTCksuTh/EotByUXjkQu1IU8pKN9fRA/6j/WSsRmoQyNOG42cEaCk=",
    );
    val burnInfo = TgUsdExtraBurnInfo.fromCell(burnInfoBody);
    val install = TgUsdInstall.fromCell(installBody);
    val event = TgUsdUnstakedEvent.fromCell(eventBody);
    expect(burnInfo.queryId).toEqual(8);
    expect(burnInfo.jettonAmount).toEqual(8525161828);
    expect(burnInfo.customPayload).toBeNotNull();
    val request = burnInfo.customPayload!.load();
    match (request) {
        TgUsdRequestUnstakeForwardPayload => {}
    }
    expect(install.queryId).toEqual(burnInfo.queryId);
    expect(event.burnedShares).toEqual(burnInfo.jettonAmount);
    expect(event.unstaker).toEqual(burnInfo.unstaker);
    expect(event.unstakedAmount).toEqual(9735333588);
    expect(event.cooldownEnd).toEqual(1782750802);
    expect(burnInfo.toCell().hash()).toEqual(burnInfoBody.hash());
    expect(install.toCell().hash()).toEqual(installBody.hash());
    expect(event.toCell().hash()).toEqual(eventBody.hash());
    println(
        "TGUSD_UNSTAKE_TX={} LT={} SHARES={} AMOUNT={} COOLDOWN_END={}",
        txHash,
        txLt,
        event.burnedShares,
        event.unstakedAmount,
        event.cooldownEnd,
    );
}

get fun `test tgUSD decodes a real withdrawal transfer and event`() {
    val txHash = "gI9KTKT2g2iqTpWYnVnKLLmoASs4VuRB9joZQAugd7o=";
    val txLt = "86919217000005";
    val withdrawBody = parseCellFromBase64(
        "te6cckEBAQEAVwAAqfo+wY4AAAAAAAAACIAO38dowl8Rfup153Dg9oevdaDTCksuTh/EotByUXjkQuoEiIrNqQAdv47RhL4i/dTrzuHB7Q9e60GmFJZcnD+JRaDkovHIheA6br80",
    );
    val transferBody = parseCellFromBase64(
        "te6cckEBAgEAdwABrA+KfqUAAAAAAAAACFAkRFZtSADt/HaMJfEX7qdedw4PaHr3Wg0wpLLk4fxKLQclF45ELwAdv47RhL4i/dTrzuHB7Q9e60GmFJZcnD+JRaDkovHIhcIDAQA4VHJhbnNmZXI6IHRnVVNEIHRvIHJlY2lwaWVudCwX6ZM=",
    );
    val eventBody = parseCellFromBase64(
        "te6cckEBAQEAWgAAr7QDKcogA7fx2jCXxF+6nXncOD2h691oNMKSy5OH8Si0HJReORC6gSIis2pAB2/jtGEviL91OvO4cHtD17rQaYUllycP4lFoOSi8ciF1I1ajj25QNrfi07jfVUq/",
    );
    val withdraw = TgUsdWithdrawInternal.fromCell(withdrawBody);
    val transfer = TgUsdJettonTransfer.fromCell(transferBody);
    val event = TgUsdWithdrawProcessedEvent.fromCell(eventBody);
    expect(withdraw.queryId).toEqual(8);
    expect(withdraw.unstakedAmount).toEqual(9735333588);
    expect(transfer.queryId).toEqual(withdraw.queryId);
    expect(transfer.jettonAmount).toEqual(withdraw.unstakedAmount);
    expect(transfer.destination).toEqual(withdraw.recipient);
    expect(transfer.responseDestination).toEqual(withdraw.unstaker);
    expect(transfer.forwardTonAmount).toEqual(1);
    expect(event.status).toEqual(0);
    expect(event.unstaker).toEqual(withdraw.unstaker);
    expect(event.unstakedAmount).toEqual(withdraw.unstakedAmount);
    expect(event.recipient).toEqual(withdraw.recipient);
    expect(withdraw.toCell().hash()).toEqual(withdrawBody.hash());
    expect(transfer.toCell().hash()).toEqual(transferBody.hash());
    expect(event.toCell().hash()).toEqual(eventBody.hash());
    println("TGUSD_WITHDRAW_TX={} LT={} AMOUNT={}", txHash, txLt, withdraw.unstakedAmount);
}

get fun `test tgUSD decodes real wallet discovery and event`() {
    val txHash = "9PhbFlrGRUkv/DbNLabW1PO3KppL5QOC/VICPHsqf8k=";
    val txLt = "56662032000003";
    val responseBody = parseCellFromBase64(
        "te6cckEBAQEAMAAAW9FzVAAAAAAAAAAAAIAXBH9URSpNC3NOQ4Zlvyn7CDbEZhUUMX9EFVY2uHWC4ohtjaVg",
    );
    val eventBody = parseCellFromBase64(
        "te6cckEBAQEASQAAjTb61zaAET2AlidIR0tZyDD4T3wuy2iv551rGLAmynxsGvf3r8oQAuCP6oilSaFuachwzLflP2EG2IzCooYv6IKqxtcOsFxSGEWg5g==",
    );
    val response = TgUsdTakeWalletAddress.fromCell(responseBody);
    val event = TgUsdStakingWalletAddressTakenEvent.fromCell(eventBody);
    expect(response.queryId).toEqual(0);
    expect(response.walletAddress).toBeNotNull();
    expect(response.ownerAddress).toBeNull();
    expect(event.jettonWallet).toBeNotNull();
    expect(event.jettonWallet!).toEqual(response.walletAddress!);
    expect(event.jettonMaster.getWorkchain()).toEqual(0);
    expect(response.toCell().hash()).toEqual(responseBody.hash());
    expect(event.toCell().hash()).toEqual(eventBody.hash());
    println("TGUSD_WALLET_DISCOVERY_TX={} LT={}", txHash, txLt);
}
