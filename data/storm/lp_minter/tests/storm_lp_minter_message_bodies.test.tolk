import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/storm_lp_minter.types"

const LP_OWNER_FROM_MINT = "0:06988127102D8C70DBB219344524BDBCC60198FEA9FF6ADECA3ABC9714CDA651"
const LP_BURN_OWNER = "0:481EC247E54B752FE612974E9A9611DB2E605154202BF500F54052692D41334D"
const LP_BURN_RESPONSE = "0:26D0494E869C50BC9683EAD46ED7891073DB6C97C6A89D8207387F0A8FC065B7"
const LP_DISCOVERY_OWNER = "0:1AD8854A8B369CE472901BCCF8C201FDEA9C8851557E7C81C40430E58500DD3F"
const LP_DISCOVERY_WALLET = "0:7ABBA74347EEF5278EC8645D918371E0B5F9E78D6B07B44A9983252C36856E75"

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

get fun `test storm lp minter decodes real mint request body`() {
    val txHash = "ZpeSRLyhF4tGMQeCPSd6GhnHvtUDu1v1YQ7UjiarFsM=";
    val txLt = "81928332000005";
    val bodyBoc = "te6cckEBAQEANAAAYxZ0sKAAAEqDbSA7A0LygY2YAA0xAk4gWxjht2QyaIpJe3mMAzH9U/7VvZR1eS4pm0yjesNJkA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpMintRequest.fromCell(body);

    expect(decoded.queryId).toEqual(81928332000003);
    expect(decoded.amount).toEqual(791156953);
    expect(decoded.ownerAddress).toEqual(address(LP_OWNER_FROM_MINT));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_MINTER_MINT_REQUEST_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp minter decodes real minted internal transfer body`() {
    val txHash = "ZpeSRLyhF4tGMQeCPSd6GhnHvtUDu1v1YQ7UjiarFsM=";
    val txLt = "81928332000005";
    val bodyBoc = "te6cckEBAQEANQAAZReNRRkAAEqDbSA7A0LygY2SAANMQJOIFsY4bdkMmiKSXt5jAMx/VP+1b2UdXkuKZtMoggn3fS0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpInternalTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(81928332000003);
    expect(decoded.amount).toEqual(791156953);
    expect(decoded.fromAddress).toBeNull();
    expect(decoded.responseAddress).toEqual(address(LP_OWNER_FROM_MINT));
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);

    println("STORM_LP_MINTER_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp minter parses real burn notification prefix and response tail`() {
    val txHash = "s89fHemb/6MoBVr5smK9ponpwYD/CFaVq3ceVHQng18=";
    val txLt = "81928041000001";
    val bodyBoc = "te6cckEBAQEAWAAAq3vdl94AAAAAAAAAAGAXMcZF1mgAkD2Ej8qW6l/MJS6dNSwjtlzAoqhAV+oB6oCk0lqCZpsACbQSU6GnFC8loPq1G7XiRBz22yXxqidggc4fwqPwGW3gZKLtuA==";
    val body = parseCellFromBase64(bodyBoc);
    var parsed = body.beginParse();

    expect(parsed.loadUint(32)).toEqual(0x7bdd97de);
    expect(parsed.loadUint(64)).toEqual(0);
    expect(parsed.loadCoins()).toEqual(1593909206374);
    expect(parsed.loadAddress()).toEqual(address(LP_BURN_OWNER));
    expect(parsed.loadAddress()).toEqual(address(LP_BURN_RESPONSE));
    expectNoTail(mutate parsed);

    println("STORM_LP_MINTER_BURN_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp minter decodes real vault unstake body`() {
    val txHash = "s89fHemb/6MoBVr5smK9ponpwYD/CFaVq3ceVHQng18=";
    val txLt = "81928041000001";
    val bodyBoc = "te6cckEBAQEALgAAV9W16a1gFzHGRdZoAJA9hI/KlupfzCUunTUsI7ZcwKKoQFfqAeqApNJagmabgUASVQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpVaultUnstake.fromCell(body);

    expect(decoded.jettonAmount).toEqual(1593909206374);
    expect(decoded.userAddress).toEqual(address(LP_BURN_OWNER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_MINTER_VAULT_UNSTAKE_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp minter decodes real provide wallet address body`() {
    val txHash = "5a/guxV2Jl3utLQjbACzt70qzvUMkaXC4vUUUVaTziw=";
    val txLt = "79659688000015";
    val bodyBoc = "te6cckEBAQEAMAAAWyx2uXMAAEhzN2f6DYADWxCpUWbTnI5SA3mfGEA/vVORCiqvz5A4gIYcsKAbp+i2ma2z";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpProvideWalletAddress.fromCell(body);

    expect(decoded.queryId).toEqual(79659688000013);
    expect(decoded.ownerAddress).toEqual(address(LP_DISCOVERY_OWNER));
    expect(decoded.includeAddress).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_MINTER_PROVIDE_WALLET_ADDRESS_TX={} LT={}", txHash, txLt);
}

get fun `test storm lp minter decodes real take wallet address body`() {
    val txHash = "5a/guxV2Jl3utLQjbACzt70qzvUMkaXC4vUUUVaTziw=";
    val txLt = "79659688000015";
    val bodyBoc = "te6cckEBAQEAMAAAW9FzVAAAAEhzN2f6DYAPV3ToaP3epPHZDIuyMG48Fr888a1g9olTMGSlhtCtzqjVn9am";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StormLpTakeWalletAddress.fromCell(body);

    expect(decoded.queryId).toEqual(79659688000013);
    expect(decoded.walletAddress).toBeNotNull();
    expect(decoded.walletAddress!).toEqual(address(LP_DISCOVERY_WALLET));
    expect(decoded.ownerAddress).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("STORM_LP_MINTER_TAKE_WALLET_ADDRESS_TX={} LT={}", txHash, txLt);
}
